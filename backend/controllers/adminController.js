const User = require('../models/User');
const Campaign = require('../models/Campaign');
const Donation = require('../models/DonationEnhanced');
const NGO = require('../models/NGO');
const notificationController = require('./notificationController');


// @desc    Get admin dashboard stats
// @route   GET /api/admin/stats
// @access  Private (Admin only)
exports.getStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const totalDonors = await User.countDocuments({ role: 'donor' });
    const totalNGOs = await User.countDocuments({ role: 'ngo' });
    const totalVolunteers = await User.countDocuments({ role: 'volunteer' });

    const pendingNGOs = await NGO.countDocuments({ verified: false });

    const totalCampaigns = await Campaign.countDocuments();
    const pendingCampaigns = await Campaign.countDocuments({ status: 'pending' });
    const activeCampaigns = await Campaign.countDocuments({ status: 'approved' });

    const totalAmountAgg = await Donation.aggregate([
      { $match: { paymentStatus: "success" } },
      {
        $group: {
          _id: null,
          total: { $sum: "$amount" }
        }
      }
    ]);

    const totalRaised = totalAmountAgg[0]?.total || 0;

    const totalDonations = await Donation.countDocuments({ paymentStatus: 'success' });

    res.json({
      success: true,
      stats: {
        totalUsers,
        totalDonors,
        totalNGOs,
        totalVolunteers,
        pendingNGOs,
        totalCampaigns,
        pendingCampaigns,
        activeCampaigns,
        totalDonations,
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
    const { page = 1, limit = 50, role, search } = req.query;

    const query = {};
    if (role && role !== 'all') query.role = role;
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    const users = await User.find(query)
      .select('-password -otp')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });

    const count = await User.countDocuments(query);

    res.json({
      success: true,
      users: users,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      totalCount: count
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
    ).select('-password -otp');

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

// @desc    Update user details
// @route   PUT /api/admin/users/:id
// @access  Private (Admin only)
exports.updateUser = async (req, res) => {
  try {
    const { name, email, phone, role, ngoName, ngoAddress } = req.body;

    const updateData = {};
    if (name) updateData.name = name;
    if (email) updateData.email = email;
    if (phone) updateData.phone = phone;
    if (role) updateData.role = role;
    if (ngoName !== undefined) updateData.ngoName = ngoName;
    if (ngoAddress !== undefined) updateData.ngoAddress = ngoAddress;

    const user = await User.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    ).select('-password -otp');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: 'User updated successfully',
      data: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete user
// @route   DELETE /api/admin/users/:id
// @access  Private (Admin only)
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    if (user.role === 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Cannot delete an admin user'
      });
    }

    await User.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'User deleted successfully'
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
      .populate("ngoId", "name email phone ngoName ngoAddress address city state pincode")
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
    if (status === 'approved') {
      campaign.approvedBy = req.user._id;
      campaign.approvedAt = new Date();

      // Notify all donors about the new campaign
      const donors = await User.find({ role: 'donor' }).select('_id');
      for (const donor of donors) {
        await notificationController.createNotificationHelper(
          donor._id,
          'campaign',
          'New Campaign Alert!',
          `A new campaign "${campaign.title}" is now live. Support the cause!`,
          campaign._id
        );
      }
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
      paymentStatus: 'success'
    });

    const totalDonations = donations.length;
    const totalAmount = donations.reduce((sum, d) => sum + d.amount, 0);

    // Top categories
    const categoryStats = await Campaign.aggregate([
      { $match: { status: 'approved' } },
      {
        $group: {
          _id: '$category',
          count: { $sum: 1 },
          totalRaised: { $sum: '$currentAmount' }
        }
      },
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
      .populate('ngoId', 'name email phone address city state pincode location')
      .populate({
        path: 'donations',
        populate: {
          path: 'donorId',
          select: 'name email phone address location'
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
    const donations = await Donation.find({ paymentStatus: 'success' })
      .populate('donorId', 'name email phone address location')
      .populate('campaignId', 'title category')
      .populate('ngoId', 'name email phone')
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

    // Notify all donors about the new campaign
    const donors = await User.find({ role: 'donor' }).select('_id');
    for (const donor of donors) {
      await notificationController.createNotificationHelper(
        donor._id,
        'campaign',
        'New Campaign Alert!',
        `A new campaign "${campaign.title}" is now live. Support the cause!`,
        campaign._id
      );
    }

    res.json({ success: true, message: "Campaign approved" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};