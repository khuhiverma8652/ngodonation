const Donation = require('../models/DonationEnhanced');
const Campaign = require('../models/Campaign');
const User = require('../models/User');

// @desc    Create new donation
// @route   POST /api/donations/create
// @access  Private
exports.createDonation = async (req, res) => {
  try {

    const {
      campaignId,
      amount,
      paymentMethod,
      transactionId,
      donationType,
      items
    } = req.body;

    console.log("Received body:", req.body);

    const campaign = await Campaign.findById(campaignId);

    if (!campaign) {
      return res.status(404).json({
        success: false,
        message: 'Campaign not found',
      });
    }

    let donationData = {
      donorId: req.user._id,
      campaignId: campaignId,
      ngoId: campaign.ngoId,
      donationType: donationType || "monetary",
      paymentStatus: "success",
      paymentMode: paymentMethod || "manual",
      receiptGenerated: false
    };

    // 🟢 Monetary Donation
    if (donationType === "monetary") {
      // Security: Monetary donations should only be created via payment verification
      return res.status(400).json({
        success: false,
        message: 'Monetary donations must be processed via payment gateway'
      });
    }

    // 🟢 In-Kind Donation (Food / Clothes / Items)
    if (donationType === "in-kind") {

      donationData.items = items || [];

      donationData.amount = 0; // optional
    }

    const donation = await Donation.create(donationData);

    // Update campaign stats
    await Campaign.findByIdAndUpdate(campaignId, {
      $inc: {
        currentAmount: donationData.amount || 0,
        totalDonors: 1
      }
    });

    await donation.populate("donorId campaignId ngoId");

    res.status(201).json({
      success: true,
      message: "Donation created successfully",
      data: donation,
    });

  } catch (error) {
    console.error("Create donation error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to create donation",
      error: error.message,
    });
  }
};
// @desc    Get donation receipt
// @route   GET /api/donations/receipt/:id
// @access  Private
exports.getReceipt = async (req, res) => {
  try {
    const donation = await Donation.findById(req.params.id)
      .populate('donorId', 'name email phone')
      .populate('campaignId', 'title')
      .populate('ngoId', 'name registrationNumber');

    if (!donation) {
      return res.status(404).json({
        success: false,
        message: 'Donation not found',
      });
    }

    // Check if user owns this donation
    if (donation.donorId._id.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this receipt',
      });
    }

    res.status(200).json({
      success: true,
      data: donation,
    });
  } catch (error) {
    console.error('Get receipt error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get receipt',
      error: error.message,
    });
  }
};

// @desc    Get donation history for user
// @route   GET /api/donations/history
// @access  Private
exports.getDonationHistory = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const donations = await Donation.find({ donorId: req.user.id })
      .populate('campaignId', 'title category')
      .populate('ngoId', 'name')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Donation.countDocuments({ donorId: req.user.id });

    // Calculate total donated
    const stats = await Donation.aggregate([
      { $match: { donorId: req.user._id } },
      {
        $group: {
          _id: null,
          totalDonated: { $sum: '$amount' },
          totalDonations: { $sum: 1 },
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: {
        donations,
        pagination: {
          current: page,
          pages: Math.ceil(total / limit),
          total,
        },
        statistics: stats[0] || { totalDonated: 0, totalDonations: 0 },
      },
    });
  } catch (error) {
    console.error('Get donation history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get donation history',
      error: error.message,
    });
  }
};

// @desc    Get all donations (Admin/NGO)
// @route   GET /api/donations/all
// @access  Private (Admin/NGO)
exports.getAllDonations = async (req, res) => {
  try {
    const query = {};

    // If NGO, only show their donations
    if (req.user.role === 'ngo') {
      query.ngoId = req.user.id;
    }

    const donations = await Donation.find(query)
      .populate('donorId', 'name email')
      .populate('campaignId', 'title')
      .populate('ngoId', 'name')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: donations.length,
      data: donations,
    });
  } catch (error) {
    console.error('Get all donations error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get donations',
      error: error.message,
    });
  }
};

// @desc    Get donation statistics
// @route   GET /api/donations/stats
// @access  Private
exports.getDonationStats = async (req, res) => {
  try {
    const query = req.user.role === 'ngo' ? { ngoId: req.user.id } : {};

    const stats = await Donation.aggregate([
      { $match: query },
      {
        $group: {
          _id: null,
          totalAmount: { $sum: '$amount' },
          totalDonations: { $sum: 1 },
          avgDonation: { $avg: '$amount' },
        },
      },
    ]);

    // Get donations by category
    const byCategory = await Donation.aggregate([
      { $match: query },
      {
        $lookup: {
          from: 'campaigns',
          localField: 'campaign',
          foreignField: '_id',
          as: 'campaignData',
        },
      },
      { $unwind: '$campaignData' },
      {
        $group: {
          _id: '$campaignData.category',
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: {
        overall: stats[0] || { totalAmount: 0, totalDonations: 0, avgDonation: 0 },
        byCategory,
      },
    });
  } catch (error) {
    console.error('Get donation stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get donation statistics',
      error: error.message,
    });
  }
};

// @desc    Download receipt PDF
// @route   GET /api/donations/download-receipt/:id
// @access  Private
exports.downloadReceipt = async (req, res) => {
  try {
    const donation = await Donation.findById(req.params.id)
      .populate('donor', 'name email phone')
      .populate('campaign', 'title')
      .populate('ngo', 'name registrationNumber');

    if (!donation) {
      return res.status(404).json({
        success: false,
        message: 'Donation not found',
      });
    }

    // Check authorization
    if (donation.donor._id.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized',
      });
    }

    // TODO: Generate PDF receipt using PDFKit or similar
    // For now, return donation data
    res.status(200).json({
      success: true,
      message: 'Receipt generated',
      data: donation,
    });
  } catch (error) {
    console.error('Download receipt error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to download receipt',
      error: error.message,
    });
  }
};
exports.getDonorImpact = async (req, res) => {
  try {
    const donorId = req.user.id;

    const donations = await Donation.find({
      donorId: donorId,
      paymentStatus: 'success'
    })
      .populate({
        path: 'campaignId',
        populate: {
          path: 'ngoId',
          select: 'name'
        }
      })
      .lean();

    const totalDonated = donations.reduce((sum, d) => sum + d.amount, 0);

    const campaignsSupported = [
      ...new Set(donations.map(d => d.campaignId?._id.toString()))
    ].length;

    const totalItems = donations
      .filter(d => d.donationType === 'in-kind')
      .reduce((sum, d) => sum + (d.items?.length || 0), 0);

    // Simple badge system
    let badge = "Starter";
    if (totalDonated > 1000) badge = "Supporter";
    if (totalDonated > 5000) badge = "Change Maker";
    if (totalDonated > 20000) badge = "Community Hero";

    res.json({
      success: true,
      impact: {
        totalDonated,
        campaignsSupported,
        totalItems,
        badge,
        donations
      }
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
