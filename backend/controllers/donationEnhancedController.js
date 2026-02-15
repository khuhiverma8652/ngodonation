const Donation = require('../models/DonationEnhanced');
const Campaign = require('../models/Campaign');
const User = require('../models/User');
const notificationController = require('./notificationController');
const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');


// Create donation
exports.createDonation = async (req, res) => {
  try {
    const {
      campaignId,
      amount,
      paymentMode,
      paymentId,
      message,
      isAnonymous,
      panNumber,
      donationType,
      items
    } = req.body;

    const donorId = req.user.id || req.user._id;

    // Get campaign and NGO details
    const campaign = await Campaign.findById(campaignId).populate('ngoId');
    if (!campaign) {
      return res.status(404).json({ success: false, message: 'Campaign not found' });
    }

    // Get donor details
    const donor = await User.findById(donorId);
    if (!donor) {
      return res.status(404).json({ success: false, message: 'Donor not found' });
    }

    const isMonetary = donationType === 'monetary' || !donationType;

    // Create donation data
    const donationData = {
      donorId,
      campaignId,
      ngoId: campaign.ngoId ? campaign.ngoId._id : campaign.ngoId,
      donationType: donationType || 'monetary',
      amount: isMonetary ? parseFloat(amount || 0) : 0,
      paymentMode: isMonetary ? (paymentMode || 'manual') : 'in-kind',
      paymentId: paymentId || '',
      paymentStatus: isMonetary ? 'success' : 'pending',
      donorName: isAnonymous ? 'Anonymous' : (donor ? donor.name : 'Unknown Donor'),
      donorEmail: donor ? donor.email : '',
      donorPhone: donor ? donor.phone : '',
      donorAddress: (donor && donor.address) ? donor.address : '',
      purpose: `Donation for ${campaign.title}`,
      message,
      isAnonymous,
      isVerifiedByNGO: isMonetary, // Monetary verified by payment gateway
      is80GEligible: isMonetary ? !!campaign.is80GEligible : false,
      panNumber: (isMonetary && campaign.is80GEligible) ? panNumber : null,
      receiptGenerated: false,
      items: (donationType === 'in-kind') ? (items || []) : []
    };

    // 🟢 SMART LOGIC: Auto-verify Food donations
    if (campaign.category === 'Food' && donationData.donationType === 'in-kind') {
      donationData.paymentStatus = 'received';
      donationData.isVerifiedByNGO = true;
      donationData.verifiedAt = new Date();
      donationData.receiverName = 'System (Auto-Food)';
    }

    const donation = new Donation(donationData);
    await donation.save();

    // Update campaign stats
    if (isMonetary || donation.isVerifiedByNGO) {
      if (isMonetary) campaign.currentAmount += parseFloat(amount || 0);
      campaign.totalDonors = (campaign.totalDonors || 0) + 1;
      await campaign.save();
    }

    // Generate receipt if verified
    if (donation.isVerifiedByNGO) {
      try {
        const { generateReceipt } = require('./donationEnhancedController');
        const receiptData = await generateReceipt(donation, campaign, donor);
        donation.receiptGenerated = true;
        donation.receiptUrl = receiptData.url;
        donation.receiptGeneratedAt = new Date();
        await donation.save();

        const mailService = require('../services/mail.service');
        await mailService.sendDonationReceipt(donation, receiptData.url);
      } catch (receiptErr) {
        console.error('Receipt generation error:', receiptErr);
      }
    } else {
      // Send submission notification for pending items
      const mailService = require('../services/mail.service');
      await mailService.sendItemDonationNotification(donation);

      // Notify Donor via App
      await notificationController.createNotificationHelper(
        donorId,
        'donation',
        'Donation Received!',
        `Your request to donate items to "${campaign.title}" has been received and is pending NGO verification.`,
        campaignId
      );
    }

    res.status(201).json({
      success: true,
      message: donation.isVerifiedByNGO ? 'Donation successful!' : 'Donation pending verification.',
      donation
    });

  } catch (error) {
    console.error('Create donation error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// NGO - Verify In-Kind Donation
exports.verifyInKindDonation = async (req, res) => {
  try {
    const { id } = req.params;
    const { receiverName, itemValues } = req.body; // itemValues is optional: { "Item Name": 500 }

    const donation = await Donation.findOne({ _id: id, ngoId: req.user._id });
    if (!donation) {
      return res.status(404).json({ success: false, message: 'Donation not found' });
    }

    if (donation.donationType !== 'in-kind') {
      return res.status(400).json({ success: false, message: 'Only in-kind donations need verification' });
    }

    if (donation.isVerifiedByNGO) {
      return res.status(400).json({ success: false, message: 'Donation already verified' });
    }

    // Update donation status
    donation.paymentStatus = 'received';
    donation.isVerifiedByNGO = true;
    donation.verifiedAt = new Date();
    donation.receiverName = receiverName || req.user.name;

    // Optional: Update item values and campaign amount
    if (itemValues) {
      let totalValue = 0;
      donation.items.forEach(item => {
        if (itemValues[item.name]) {
          item.value = itemValues[item.name];
          totalValue += item.value;
        }
      });
      donation.amount = totalValue;

      // Update campaign stats
      const campaign = await Campaign.findById(donation.campaignId);
      if (campaign) {
        campaign.currentAmount += totalValue;
        await campaign.save();
      }
    }

    // Generate unique receipt number for In-Kind (now that it's verified)
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const count = await Donation.countDocuments({
      createdAt: { $gte: new Date(date.setHours(0, 0, 0, 0)) },
      donationType: 'in-kind',
      isVerifiedByNGO: true
    });
    donation.receiptNumber = `IKD${year}${month}${day}${String(count + 1).padStart(4, '0')}`;

    await donation.save();

    // Population for receipt
    const campaign = await Campaign.findById(donation.campaignId).populate('ngoId');
    const donor = await require('../models/User').findById(donation.donorId);

    // Generate PDF
    const receiptData = await generateReceipt(donation, campaign, donor);
    donation.receiptGenerated = true;
    donation.receiptUrl = receiptData.url;
    donation.receiptGeneratedAt = new Date();
    await donation.save();

    // Send Email
    const mailService = require('../services/mail.service');
    await mailService.sendDonationReceipt(donation, receiptData.url);

    // Notify Donor via App
    await notificationController.createNotificationHelper(
      donation.donorId,
      'success',
      'Donation Verified!',
      `The NGO has verified and received your item donation for "${campaign.title}". Thank you!`,
      donation.campaignId
    );

    res.json({
      success: true,
      message: 'Donation verified, receipt generated and emailed!',
      donation
    });

  } catch (error) {
    console.error('Verify donation error:', error);
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// Generate PDF receipt
const generateReceipt = async (donation, campaign, donor) => {
  // Exporting for use in other controllers
  exports.generateReceipt = generateReceipt;
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: 'A4', margin: 50 });

      const filename = `receipt_${donation.receiptNumber}.pdf`;
      const filepath = path.join(__dirname, '../uploads/receipts', filename);

      // Ensure directory exists
      const dir = path.dirname(filepath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      const stream = fs.createWriteStream(filepath);
      doc.pipe(stream);

      // Header
      doc.fontSize(20).text('DONATION RECEIPT', { align: 'center' });
      doc.moveDown();

      // Receipt details
      doc.fontSize(12);
      doc.text(`Receipt Number: ${donation.receiptNumber}`, { bold: true });
      doc.text(`Date: ${new Date(donation.transactionDate).toLocaleDateString('en-IN')}`);
      doc.moveDown();

      // NGO Details
      doc.fontSize(14).text('NGO Details:', { underline: true });
      doc.fontSize(12);
      doc.text(`Name: ${campaign.ngoId.name}`);
      doc.text(`Registration Number: ${campaign.ngoId.registrationNumber || 'N/A'}`);
      doc.text(`Email: ${campaign.ngoId.email}`);
      doc.text(`Phone: ${campaign.ngoId.phone}`);
      doc.moveDown();

      // Donor Details
      doc.fontSize(14).text('Donor Details:', { underline: true });
      doc.fontSize(12);
      doc.text(`Name: ${donation.donorName}`);
      if (!donation.isAnonymous) {
        doc.text(`Email: ${donation.donorEmail}`);
        doc.text(`Phone: ${donation.donorPhone}`);
      }
      doc.moveDown();

      // Donation Details
      doc.fontSize(14).text('Donation Details:', { underline: true });
      doc.fontSize(12);
      doc.text(`Campaign: ${campaign.title}`);
      doc.text(`Category: ${campaign.category}`);

      if (donation.donationType === 'in-kind') {
        doc.text(`Donation Type: IN-KIND (Items)`);
        doc.moveDown(0.5);
        doc.text('Items Donated:');
        donation.items.forEach((item, index) => {
          doc.text(`${index + 1}. ${item.name} - Qty: ${item.quantity} ${item.description ? `(${item.description})` : ''}`);
        });
      } else {
        doc.text(`Amount: ₹${donation.amount.toLocaleString('en-IN')}`);
        doc.text(`Payment Mode: ${donation.paymentMode.toUpperCase()}`);
        doc.text(`Transaction ID: ${donation.paymentId || 'N/A'}`);
      }
      doc.moveDown();

      // 80G Eligibility
      if (donation.is80GEligible) {
        doc.fontSize(14).fillColor('green').text('80G TAX EXEMPTION ELIGIBLE', { underline: true });
        doc.fontSize(11).fillColor('black').text('This donation is eligible for tax deduction under Section 80G of the Income Tax Act, 1961.');
        if (donation.panNumber) {
          doc.text(`PAN Number: ${donation.panNumber}`);
        }
        doc.moveDown();
      }

      // Footer
      doc.fontSize(10).fillColor('gray');
      doc.text('This is a computer-generated receipt and does not require a signature.', { align: 'center' });
      doc.text('Thank you for your generous contribution!', { align: 'center' });

      doc.end();

      stream.on('finish', () => {
        const receipt = {
          receiptNumber: donation.receiptNumber,
          ngoName: campaign.ngoId.name,
          ngoRegistration: campaign.ngoId.registrationNumber,
          date: donation.transactionDate,
          amount: donation.amount,
          paymentMode: donation.paymentMode,
          campaignName: campaign.title,
          is80GEligible: donation.is80GEligible,
          donorName: donation.donorName,
          donorEmail: donation.donorEmail
        };

        resolve({
          url: `/receipts/${filename}`,
          receipt
        });
      });

    } catch (error) {
      reject(error);
    }
  });
}

// Get donation receipt
exports.getReceipt = async (req, res) => {
  try {
    const { id } = req.params;

    const donation = await Donation.findById(id)
      .populate('campaignId')
      .populate('ngoId', 'name registrationNumber');

    if (!donation) {
      return res.status(404).json({ message: 'Donation not found' });
    }

    // Check if user is authorized
    if (donation.donorId.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized' });
    }

    res.json({
      success: true,
      receipt: {
        receiptNumber: donation.receiptNumber,
        ngoName: donation.ngoId.name,
        ngoRegistration: donation.ngoId.registrationNumber,
        date: donation.transactionDate,
        amount: donation.amount,
        paymentMode: donation.paymentMode,
        campaignName: donation.campaignId.title,
        is80GEligible: donation.is80GEligible,
        donorName: donation.donorName,
        donorEmail: donation.donorEmail,
        receiptUrl: donation.receiptUrl
      }
    });

  } catch (error) {
    console.error('Get receipt error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get donor's donation history
exports.getDonationHistory = async (req, res) => {
  try {
    const donorId = req.user.id;
    const { page = 1, limit = 20 } = req.query;

    const donations = await Donation.find({
      donorId,
      paymentStatus: 'success'
    })
      .populate('campaignId', 'title category')
      .populate('ngoId', 'name')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit))
      .lean();

    const total = await Donation.countDocuments({ donorId, paymentStatus: 'success' });
    const totalDonated = await Donation.aggregate([
      { $match: { donorId: mongoose.Types.ObjectId(donorId), paymentStatus: 'success' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);

    res.json({
      success: true,
      donations,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      },
      statistics: {
        totalDonated: totalDonated[0]?.total || 0,
        totalDonations: total
      }
    });

  } catch (error) {
    console.error('Get donation history error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

exports.getAllDonations = async (req, res) => {
  try {
    const donations = await Donation.find()
      .populate('campaignId', 'title')
      .populate('ngoId', 'name')
      .populate('donorId', 'name email')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      donations
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getDonationStats = async (req, res) => {
  try {
    const stats = await Donation.aggregate([
      {
        $group: {
          _id: null,
          totalAmount: { $sum: '$amount' },
          totalDonations: { $sum: 1 }
        }
      }
    ]);

    res.json({
      success: true,
      stats: stats[0] || { totalAmount: 0, totalDonations: 0 }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.downloadReceipt = async (req, res) => {
  try {
    const { id } = req.params;

    const donation = await Donation.findById(id);
    if (!donation || !donation.receiptUrl) {
      return res.status(404).json({ message: 'Receipt not found' });
    }

    const filePath = path.join(__dirname, '../uploads', donation.receiptUrl);

    res.download(filePath);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};