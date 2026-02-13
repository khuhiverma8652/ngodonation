const User = require('../models/User');
const Campaign = require('../models/Campaign');
const Donation = require('../models/Donation');
const NGO = require('../models/NGO');


// @desc    Get admin dashboard stats
// @route   GET /api/admin/stats
// @access  Private (Admin only)
exports.getStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const totalCampaigns = await Campaign.countDocuments();
    const pendingCampaigns = await Campaign.countDocuments({ status: 'pending' });
    
    const donations = await Donation.find({ paymentStatus: 'completed' });
    const totalRaised = donations.reduce((sum, d) => sum + d.amount, 0);
// 🔵 Donation Summary
const totalDonations = await Donation.countDocuments({
  paymentStatus: "completed"
});

const totalAmountAgg = await Donation.aggregate([
  { $match: { paymentStatus: "completed" } },
  {
    $group: {
      _id: null,
      total: { $sum: "$amount" }
    }
  }
]);

const totalAmount = totalAmountAgg[0]?.total || 0;

// attach to stats
stats.totalDonations = totalDonations;
stats.totalAmount = totalAmount;


    res.json({
      success: true,
      stats: {
        totalUsers,
        totalCampaigns,
        pendingCampaigns,
        totalRaised
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get all users
// @route   GET /api/admin/users
// @access  Private (Admin only)
exports.getAllUsers = async (req, res) => {
  try {
    const { page = 1, limit = 20, role } = req.query;
    
    const query = {};
    if (role) query.role = role;

    const users = await User.find(query)
      .select('-password')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });

    const count = await User.countDocuments(query);

    res.json({
      success: true,
      data: users,
      totalPages: Math.ceil(count / limit),
      currentPage: page
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update user status
// @route   PUT /api/admin/users/:id/status
// @access  Private (Admin only)
exports.updateUserStatus = async (req, res) => {
  try {
    const { isActive } = req.body;

    const user = await User.findByIdAndUpdate(
      req.params.id,
      { isActive },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: `User ${isActive ? 'activated' : 'deactivated'} successfully`,
      data: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Verify NGO
// @route   PUT /api/admin/ngo/:id/verify
// @access  Private (Admin only)
exports.verifyNGO = async (req, res) => {
  try {
    const ngo = await NGO.findByIdAndUpdate(
      req.params.id,
      {
        verified: true,
        verifiedAt: new Date(),
        verifiedBy: req.user._id
      },
      { new: true }
    );

    if (!ngo) {
      return res.status(404).json({
        success: false,
        message: 'NGO not found'
      });
    }

    res.json({
      success: true,
      message: 'NGO verified successfully',
      data: ngo
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get pending campaigns for approval
// @route   GET /api/admin/campaigns/pending
// @access  Private (Admin only)
exports.getPendingCampaigns = async (req, res) => {
  try {
    const campaigns = await Campaign.find({ status: "pending" })
  .populate("ngoId", "name email phone ngoName ngoAddress")
  .lean();
    res.json({
      success: true,
      count: campaigns.length,
      campaigns
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
// @desc    Approve/Reject campaign
// @route   PUT /api/admin/campaigns/:id/status
// @access  Private (Admin only)
exports.updateCampaignStatus = async (req, res) => {
  try {
    const { status, reason } = req.body;

    const campaign = await Campaign.findById(req.params.id);

    if (!campaign) {
      return res.status(404).json({
        success: false,
        message: 'Campaign not found'
      });
    }

    campaign.status = status;
    if (status === 'rejected' && reason) {
      campaign.rejectionReason = reason;
    }
    if (status === 'live') {
      campaign.approvedBy = req.user._id;
      campaign.approvedAt = new Date();
    }

    await campaign.save();

    res.json({
      success: true,
      message: `Campaign ${status} successfully`,
      data: campaign
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get platform analytics
// @route   GET /api/admin/analytics
// @access  Private (Admin only)
exports.getAnalytics = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    const dateFilter = {};
    if (startDate) dateFilter.$gte = new Date(startDate);
    if (endDate) dateFilter.$lte = new Date(endDate);

    const query = {};
    if (Object.keys(dateFilter).length > 0) {
      query.createdAt = dateFilter;
    }

    // User registrations
    const newUsers = await User.countDocuments(query);

    // Campaigns created
    const newCampaigns = await Campaign.countDocuments(query);

    // Donations
    const donations = await Donation.find({
      ...query,
      paymentStatus: 'completed'
    });

    const totalDonations = donations.length;
    const totalAmount = donations.reduce((sum, d) => sum + d.amount, 0);

    // Top categories
    const categoryStats = await Campaign.aggregate([
      { $match: { status: 'live' } },
      { $group: {
        _id: '$category',
        count: { $sum: 1 },
        totalRaised: { $sum: '$currentAmount' }
      }},
      { $sort: { totalRaised: -1 } },
      { $limit: 5 }
    ]);

    res.json({
      success: true,
      data: {
        newUsers,
        newCampaigns,
        totalDonations,
        totalAmount,
        categoryStats
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
// @desc    Get single campaign with NGO + donations
// @route   GET /api/admin/campaigns/:id
// @access  Private (Admin only)
exports.getCampaignDetails = async (req, res) => {
  try {
    const campaign = await Campaign.findById(req.params.id)
      .populate('ngoId', 'name email location')
      .populate({
        path: 'donations',
        populate: {
          path: 'donorId',
          select: 'name email location'
        }
      });

    if (!campaign) {
      return res.status(404).json({
        success: false,
        message: 'Campaign not found'
      });
    }

    res.json({
      success: true,
      data: campaign
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
// @desc    Get all donations (admin)
// @route   GET /api/admin/donations
// @access  Private (Admin only)
exports.getAllDonations = async (req, res) => {
  try {
    const donations = await Donation.find({ paymentStatus: 'completed' })
      .populate('donorId', 'name email location')
      .populate('campaignId', 'title category')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: donations.length,
      data: donations
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
exports.approveCampaign = async (req, res) => {
  try {
    const campaign = await Campaign.findById(req.params.id);

    if (!campaign) {
      return res.status(404).json({ message: "Campaign not found" });
    }

    campaign.status = "approved";
    await campaign.save();

    res.json({ success: true, message: "Campaign approved" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};