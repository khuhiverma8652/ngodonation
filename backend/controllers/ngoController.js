const NGO = require('../models/NGO');
const User = require('../models/User');
const Campaign = require('../models/Campaign');
const Donation = require('../models/DonationEnhanced');

// @desc    Get NGO dashboard stats
// @route   GET /api/ngo/dashboard
// @access  Private (NGO only)
exports.getDashboard = async (req, res) => {
  try {
    const ngo = await NGO.findOne({ user: req.user._id });

    if (!ngo) {
      // It's possible the user is an NGO role but hasn't completed the NGO profile yet.
      // However, we can still show them their campaigns and donations if they have any linked to their user ID.
      // Or we can return partial data. For now, we'll proceed but bear in mind the profile might be missing.
    }

    // 📊 Real-time stats calculation
    const campaigns = await Campaign.find({ ngoId: req.user._id }).sort({ createdAt: -1 });
    const totalCampaigns = campaigns.length;
    const activeCampaigns = campaigns.filter(c => c.status === 'approved').length;

    // Aggregate donations for this NGO (only successful ones for total raised)
    const donationStats = await Donation.aggregate([
      {
        $match: {
          ngoId: req.user._id,
          paymentStatus: { $in: ['success', 'completed', 'received'] }
        }
      },
      {
        $group: {
          _id: null,
          totalRaised: { $sum: '$amount' },
          donors: { $addToSet: '$donorId' }
        }
      }
    ]);

    const totalRaised = donationStats[0]?.totalRaised || 0;
    const totalDonors = donationStats[0]?.donors?.length || 0;

    // 🟢 Fetch ALL Recent Donations (including pending items for verification)
    const recentDonations = await Donation.find({
      ngoId: req.user._id
    })
      .sort({ createdAt: -1 })
      .limit(50)
      .populate('donorId', 'name email phone profileImage')
      .populate('campaignId', 'title category');

    res.json({
      success: true,
      stats: {
        totalCampaigns,
        activeCampaigns,
        totalRaised,
        totalDonors
      },
      campaigns,
      donations: recentDonations
    });
  } catch (error) {
    console.error("Dashboard Error:", error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get all NGOs
// @route   GET /api/ngo
// @access  Public
exports.getAllNGOs = async (req, res) => {
  try {
    const { page = 1, limit = 10, verified } = req.query;

    const query = { isActive: true };
    if (verified) query.verified = verified === 'true';

    const ngos = await NGO.find(query)
      .populate('user', 'name email phone')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });

    const count = await NGO.countDocuments(query);

    res.json({
      success: true,
      data: ngos,
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

// @desc    Get NGO by ID
// @route   GET /api/ngo/:id
// @access  Public
exports.getNGOById = async (req, res) => {
  try {
    const ngo = await NGO.findById(req.params.id)
      .populate('user', 'name email phone')
      .populate('reviews.user', 'name profileImage');

    if (!ngo) {
      return res.status(404).json({
        success: false,
        message: 'NGO not found'
      });
    }

    res.json({
      success: true,
      data: ngo
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Create or update NGO profile
// @route   POST /api/ngo/profile
// @access  Private (NGO only)
exports.createOrUpdateProfile = async (req, res) => {
  try {
    const {
      organizationName,
      registrationNumber,
      description,
      website,
      established,
      address,
      contactPerson,
      categories
    } = req.body;

    let ngo = await NGO.findOne({ user: req.user._id });

    if (ngo) {
      // Update existing
      ngo.organizationName = organizationName || ngo.organizationName;
      ngo.registrationNumber = registrationNumber || ngo.registrationNumber;
      ngo.description = description || ngo.description;
      ngo.website = website || ngo.website;
      ngo.established = established || ngo.established;
      ngo.address = address || ngo.address;
      ngo.contactPerson = contactPerson || ngo.contactPerson;
      ngo.categories = categories || ngo.categories;

      await ngo.save();

      res.json({
        success: true,
        message: 'NGO profile updated successfully',
        data: ngo
      });
    } else {
      // Create new
      ngo = await NGO.create({
        user: req.user._id,
        organizationName,
        registrationNumber,
        description,
        website,
        established,
        address,
        contactPerson,
        categories
      });

      res.status(201).json({
        success: true,
        message: 'NGO profile created successfully',
        data: ngo
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Add review to NGO
// @route   POST /api/ngo/:id/review
// @access  Private
exports.addReview = async (req, res) => {
  try {
    const { rating, comment } = req.body;

    const ngo = await NGO.findById(req.params.id);

    if (!ngo) {
      return res.status(404).json({
        success: false,
        message: 'NGO not found'
      });
    }

    // Check if already reviewed
    const alreadyReviewed = ngo.reviews.find(
      r => r.user.toString() === req.user._id.toString()
    );

    if (alreadyReviewed) {
      return res.status(400).json({
        success: false,
        message: 'You have already reviewed this NGO'
      });
    }

    const review = {
      user: req.user._id,
      rating,
      comment
    };

    ngo.reviews.push(review);

    // Update average rating
    const totalRating = ngo.reviews.reduce((sum, r) => sum + r.rating, 0);
    ngo.rating = totalRating / ngo.reviews.length;

    await ngo.save();

    res.json({
      success: true,
      message: 'Review added successfully',
      data: ngo
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};