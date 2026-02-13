const Donation = require('../models/DonationEnhanced');
const Campaign = require('../models/Campaign');
const User = require('../models/User');
const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');


// Create donation with instant receipt
exports.createDonation = async (req, res) => {
  try {
    const {
      campaignId,
      amount,
      paymentMode,
      paymentId,
      message,
      isAnonymous,
      panNumber
    } = req.body;
    
    const donorId = req.user.id;
    
    // Get campaign and NGO details
    const campaign = await Campaign.findById(campaignId).populate('ngoId');
    if (!campaign) {
      return res.status(404).json({ message: 'Campaign not found' });
    }
    
    // Get donor details
    const donor = await User.findById(donorId);
    
    // Create donation
    const donation = new Donation({
      donorId,
      campaignId,
      ngoId: campaign.ngoId._id,
      amount: parseFloat(amount),
      paymentMode,
      paymentId,
      paymentStatus: 'success', // Assuming payment successful
      donorName: isAnonymous ? 'Anonymous' : donor.name,
      donorEmail: donor.email,
      donorPhone: donor.phone,
      donorAddress: donor.address || '',
      purpose: `Donation for ${campaign.title}`,
      message,
      isAnonymous,
      is80GEligible: campaign.is80GEligible,
      panNumber: campaign.is80GEligible ? panNumber : null,
      receiptGenerated: false
    });
    
    await donation.save();
    
    // Update campaign amount
    campaign.currentAmount += parseFloat(amount);
    await campaign.save();
    
    // Generate receipt immediately
    const receiptData = await generateReceipt(donation, campaign, donor);
    
    donation.receiptGenerated = true;
    donation.receiptUrl = receiptData.url;
    donation.receiptGeneratedAt = new Date();
    await donation.save();
    
    res.status(201).json({
      success: true,
      message: 'Donation successful! Receipt generated.',
      donation: {
        id: donation._id,
        receiptNumber: donation.receiptNumber,
        amount: donation.amount,
        receiptUrl: receiptData.url,
        is80GEligible: donation.is80GEligible
      },
      receipt: receiptData.receipt
    });
    
  } catch (error) {
    console.error('Create donation error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Generate PDF receipt
async function generateReceipt(donation, campaign, donor) {
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
      doc.text(`Amount: ₹${donation.amount.toLocaleString('en-IN')}`);
      doc.text(`Payment Mode: ${donation.paymentMode.toUpperCase()}`);
      doc.text(`Transaction ID: ${donation.paymentId || 'N/A'}`);
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
exports.createDonation = async (req, res) => {
  try {
    const {
      campaignId,
      amount,
      donationType,
      items,
      name,
      email,
      phone
    } = req.body;

    const campaign = await Campaign.findById(campaignId).populate("ngoId");

    if (!campaign) {
      return res.status(404).json({ success: false, message: "Campaign not found" });
    }

    const donation = await Donation.create({
      donor: req.user.id,
      campaign: campaignId,
      ngo: campaign.ngoId._id,
      amount: donationType === "monetary" ? amount : 0,
      donationType,
      items,
      paymentStatus: donationType === "monetary" ? "pending" : "completed",
      paymentMethod: donationType === "monetary" ? "online" : "in-kind"
    });

    res.status(201).json({
      success: true,
      donation
    });

  } catch (error) {
    console.error("Create donation error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.createDonation = async (req, res) => {
  try {
    const {
      campaignId,
      amount,
      donationType,
      items
    } = req.body;

    const campaign = await Campaign.findById(campaignId);
    if (!campaign) {
      return res.status(404).json({ success: false, message: "Campaign not found" });
    }

    const donation = await Donation.create({
      donor: req.user._id,
      campaign: campaign._id,
      ngo: campaign.ngoId,
      amount: donationType === "monetary" ? amount : 0,
      donationType,
      items: donationType === "in-kind" ? items : [],
      paymentStatus: donationType === "monetary" ? "completed" : "pending",
      paymentMethod: donationType === "monetary" ? "upi" : "manual"
    });

    // Only update amount for money
    if (donationType === "monetary") {
      campaign.raisedAmount += amount;
      await campaign.save();
    }

    res.json({
      success: true,
      message: "Donation recorded",
      donation
    });

  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = exports;