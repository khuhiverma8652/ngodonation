const Campaign = require('../models/Campaign');
const User = require('../models/User');
const Donation = require('../models/DonationEnhanced');

// NGO - Quick Campaign Creator (Under 60 seconds)
exports.createCampaign = async (req, res) => {
  try {
    const { title, area, pincode, startDate, endDate, category, targetAmount, needs, whyMatters, longitude, latitude } = req.body;
    // Validate NGO user
    if (req.user.role !== 'ngo') {
      return res.status(403).json({ message: 'Only NGOs can create campaigns' });
    }
    
    // Create campaign
    const campaign = new Campaign({
      ngoId: req.user.id,
      title,
      description: whyMatters,
      category,
      location: {
        type: 'Point',
        coordinates: [parseFloat(longitude), parseFloat(latitude)],
        address: area,
        pincode
      },
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      targetAmount: parseFloat(targetAmount),
      needs: needs || [],
      whyMatters,
      status: 'pending' // Awaiting admin approval
    });
    
    await campaign.save();
    
    res.status(201).json({
      success: true,
      message: 'Campaign created successfully and sent for approval',
      campaign
    });
    
  } catch (error) {
    console.error('Create campaign error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// DONOR SCREEN 1: Nearby Campaigns (MOST IMPORTANT)
// DONOR SCREEN 1: Nearby Campaigns (MOST IMPORTANT)
exports.getNearbyCampaigns = async (req, res) => {
  try {
    const { longitude, latitude } = req.query;
    const now = new Date();

    const campaigns = await Campaign.find({
  status: "approved"
});


    // ✅ Yeh part ab function ke andar hi hai
    const campaignsWithDistance = campaigns.map(campaign => {
      const distance = calculateDistance(
        parseFloat(latitude),
        parseFloat(longitude),
        campaign.location.coordinates[1],
        campaign.location.coordinates[0]
      );

      const fundingPercentage =
        campaign.targetAmount > 0
          ? Math.round((campaign.currentAmount / campaign.targetAmount) * 100)
          : 0;

      const remainingVolunteers =
        (campaign.volunteersNeeded || 0) -
        (campaign.volunteersJoined?.length || 0);

      return {
        ...campaign,
        distance: parseFloat(distance.toFixed(2)),
        fundingPercentage,
        volunteersNeeded: remainingVolunteers
      };
    });

    // Sort by distance
    campaignsWithDistance.sort((a, b) => a.distance - b.distance);
    
    res.json({
      success: true,
      count: campaignsWithDistance.length,
      campaigns: campaignsWithDistance
    });
    
  } catch (error) {
    console.error('Get nearby campaigns error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};
// DONOR SCREEN 2: Map View (Trust Builder)
exports.getMapCampaigns = async (req, res) => {
  try {
    const { longitude, latitude, maxDistance = 100000 } = req.query;
    
    if (!longitude || !latitude) {
      return res.status(400).json({ message: 'Location coordinates required' });
    }
    
    const campaigns = await Campaign.find({
      status: 'live',
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(longitude), parseFloat(latitude)]
          },
          $maxDistance: parseInt(maxDistance)
        }
      }
    })
    .populate('ngoId', 'name')
    .select('title category location startDate endDate currentAmount targetAmount')
    .lean();
    
    // Add status colors
    const mapData = campaigns.map(campaign => {
      const now = new Date();
      const start = new Date(campaign.startDate);
      const end = new Date(campaign.endDate);
      
      let pinColor = '#4CAF50'; // Green for completed
      let status = 'completed';
      
      if (now >= start && now <= end) {
        pinColor = '#F44336'; // Red for today/live
        status = 'live';
      } else if (now < start) {
        pinColor = '#FF9800'; // Orange for upcoming
        status = 'upcoming';
      }
      
      return {
        id: campaign._id,
        title: campaign.title,
        ngoName: campaign.ngoId.name,
        category: campaign.category,
        latitude: campaign.location.coordinates[1],
        longitude: campaign.location.coordinates[0],
        pinColor,
        status,
        fundingPercentage: campaign.targetAmount > 0
          ? Math.round((campaign.currentAmount / campaign.targetAmount) * 100)
          : 0
      };
    });
    
    res.json({
      success: true,
      campaigns: mapData
    });
    
  } catch (error) {
    console.error('Get map campaigns error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// DONOR SCREEN 3: Happening Today
exports.getTodayCampaigns = async (req, res) => {
  try {
    const { longitude, latitude, maxDistance = 50000 } = req.query;
    
    if (!longitude || !latitude) {
      return res.status(400).json({ message: 'Location coordinates required' });
    }
    
    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));

const campaigns = await Campaign.find({
  status: 'approved',
  startDate: { $lte: now },
  endDate: { $gte: now }
})
.populate('ngoId', 'name phone email')
.lean();


    
    const campaignsWithDistance = campaigns.map(campaign => {
      const distance = calculateDistance(
        parseFloat(latitude),
        parseFloat(longitude),
        campaign.location.coordinates[1],
        campaign.location.coordinates[0]
      );
      
      return {
        ...campaign,
        distance: parseFloat(distance.toFixed(2)),
        fundingPercentage: campaign.targetAmount > 0
          ? Math.round((campaign.currentAmount / campaign.targetAmount) * 100)
          : 0, // <--- FIXED: ADDED MISSING COMMA HERE
        volunteersNeeded: (campaign.volunteersNeeded || 0) - (campaign.volunteersJoined?.length || 0)
      };
    });
    
    campaignsWithDistance.sort((a, b) => a.distance - b.distance);
    
    res.json({
      success: true,
      count: campaignsWithDistance.length,
      campaigns: campaignsWithDistance,
      message: campaignsWithDistance.length > 0 ? 'Live events near you!' : 'No live events today'
    });
    
  } catch (error) {
    console.error('Get today campaigns error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// DONOR SCREEN 4: Local Donation Needs
exports.getDonationNeeds = async (req, res) => {
  try {
    const { longitude, latitude, maxDistance = 50000 } = req.query;
    
    if (!longitude || !latitude) {
      return res.status(400).json({ message: 'Location coordinates required' });
    }
    
    const campaigns = await Campaign.find({
      status: 'approved',
      'needs.0': { $exists: true }, // Has at least one need
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(longitude), parseFloat(latitude)]
          },
          $maxDistance: parseInt(maxDistance)
        }
      }
    })
    .populate('ngoId', 'name')
    .select('title category needs location ngoId')
    .lean();
    
    const needsData = campaigns.map(campaign => {
      const distance = calculateDistance(
        parseFloat(latitude),
        parseFloat(longitude),
        campaign.location.coordinates[1],
        campaign.location.coordinates[0]
      );
      
      return {
        campaignId: campaign._id,
        campaignTitle: campaign.title,
        ngoName: campaign.ngoId.name,
        category: campaign.category,
        distance: parseFloat(distance.toFixed(2)),
        needs: campaign.needs.filter(need => !need.fulfilled)
      };
    });
    
    res.json({
      success: true,
      campaigns: needsData
    });
    
  } catch (error) {
    console.error('Get donation needs error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// DONOR SCREEN 6: Your Local Impact
exports.getLocalImpact = async (req, res) => {
  try {
    const donorId = req.user.id;
    const { longitude, latitude } = req.query;
    
    // Get all donations by this donor
    const donations = await Donation.find({
      donorId,
      paymentStatus: 'success'
    })
    .populate({
      path: 'campaignId',
      populate: {
        path: 'ngoId',
        select: 'name'
      }
    })
    .sort({ createdAt: -1 })
    .lean();
    
    // Calculate statistics
    const totalDonated = donations.reduce((sum, d) => sum + (d.amount || 0), 0);
    const campaignsSupported = [...new Set(donations.map(d => d.campaignId?._id.toString()))].filter(Boolean).length;
    
    // Get nearby campaigns user supported
    let nearbyCampaignsSupported = [];
    if (longitude && latitude) {
      nearbyCampaignsSupported = donations
        .filter(d => d.campaignId && d.campaignId.location)
        .map(d => {
          const campaign = d.campaignId;
          const distance = calculateDistance(
            parseFloat(latitude),
            parseFloat(longitude),
            campaign.location.coordinates[1],
            campaign.location.coordinates[0]
          );
          
          return {
            campaignId: campaign._id,
            title: campaign.title,
            ngoName: campaign.ngoId?.name,
            category: campaign.category,
            donatedAmount: d.amount,
            donatedAt: d.createdAt,
            distance: parseFloat(distance.toFixed(2)),
            completionPhotos: campaign.completionPhotos || [],
            impactStory: campaign.impactStory
          };
        })
        .filter(c => c.distance <= 50) // Within 50km
        .sort((a, b) => a.distance - b.distance);
    }
    
    res.json({
      success: true,
      impact: {
        totalDonated,
        campaignsSupported,
        totalDonations: donations.length,
        nearbyCampaignsSupported,
        message: 'You helped your community!'
      }
    });
    
  } catch (error) {
    console.error('Get local impact error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get campaign details
exports.getCampaignDetails = async (req, res) => {
  try {
    const { id } = req.params;
    
    const campaign = await Campaign.findById(id)
      .populate('ngoId', 'name email phone registrationNumber is80GEligible')
      .lean();
    
    if (!campaign) {
      return res.status(404).json({ message: 'Campaign not found' });
    }
    
    // Get donation statistics
    const donations = await Donation.find({
      campaignId: id,
      paymentStatus: 'success'
    });
    
    const donorsCount = [...new Set(donations.map(d => d.donorId.toString()))].length;
    
    const now = new Date();
    const start = new Date(campaign.startDate);
    const end = new Date(campaign.endDate);
    
    let liveStatus = 'upcoming';
    if (now >= start && now <= end) liveStatus = 'live';
    else if (now > end) liveStatus = 'completed';
    
    res.json({
      success: true,
      campaign: {
        ...campaign,
        liveStatus,
        fundingPercentage: campaign.targetAmount > 0
          ? Math.round((campaign.currentAmount / campaign.targetAmount) * 100)
          : 0,
        donorsCount,
        volunteersJoined: campaign.volunteersJoined?.length || 0
      }
    });
    
  } catch (error) {
    console.error('Get campaign details error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Support campaign (like/save)
exports.supportCampaign = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    
    const campaign = await Campaign.findById(id);
    if (!campaign) {
      return res.status(404).json({ message: 'Campaign not found' });
    }
    
    // Check if already supported
    const alreadySupported = campaign.supporters.some(
      s => s.userId.toString() === userId
    );
    
    if (alreadySupported) {
      // Remove support
      campaign.supporters = campaign.supporters.filter(
        s => s.userId.toString() !== userId
      );
    } else {
      // Add support
      campaign.supporters.push({
        userId,
        supportedAt: new Date()
      });
    }
    
    await campaign.save();
    
    res.json({
      success: true,
      message: alreadySupported ? 'Support removed' : 'Campaign supported',
      isSupported: !alreadySupported
    });
    
  } catch (error) {
    console.error('Support campaign error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// ADMIN - Approve/Reject Campaign
exports.updateCampaignStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, rejectionReason } = req.body;
    
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Only admins can update campaign status' });
    }
    
    const campaign = await Campaign.findById(id);
    if (!campaign) {
      return res.status(404).json({ message: 'Campaign not found' });
    }
    
    campaign.status = status;
    if (status === 'approved') {
      campaign.approvedBy = req.user.id;
      campaign.approvedAt = new Date();
    } else if (status === 'rejected') {
      campaign.rejectionReason = rejectionReason;
    }
    
    await campaign.save();
    
    res.json({
      success: true,
      message: `Campaign ${status}`,
      campaign
    });
    
  } catch (error) {
    console.error('Update campaign status error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};
// ADMIN - Get Pending Campaigns
exports.getPendingCampaigns = async (req, res) => {
  try {

    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Only admins can view pending campaigns' });
    }

    const campaigns = await Campaign.find({ status: 'pending' })
      .populate('ngoId', 'name email')
      .sort({ createdAt: -1 });

    console.log("Pending campaigns:", campaigns);

    res.json({
      success: true,
      count: campaigns.length,
      campaigns
    });

  } catch (error) {
    console.error("Get pending campaigns error:", error);
    res.status(500).json({ message: "Server error" });
  }
};


// Helper function to calculate distance using Haversine formula
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in kilometers
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);
  
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function toRadians(degrees) {
  return degrees * (Math.PI / 180);
}