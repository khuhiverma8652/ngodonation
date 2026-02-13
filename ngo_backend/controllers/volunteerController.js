const Campaign = require('../models/Campaign');
const VolunteerProgress = require('../models/VolunteerProgress');

// VOLUNTEER SCREEN 1: What can I do today?
exports.getTodayOpportunities = async (req, res) => {
  try {
    const { longitude, latitude, maxDistance = 50000 } = req.query;
    
    if (!longitude || !latitude) {
      return res.status(400).json({ message: 'Location coordinates required' });
    }
    
    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));
    
    const opportunities = await Campaign.find({
      status: 'approved',
      startDate: { $lte: endOfDay },
      endDate: { $gte: startOfDay },
      volunteersNeeded: { $gt: 0 },
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
    .populate('ngoId', 'name phone email')
    .lean();
    
    const opportunitiesWithDetails = opportunities.map(opp => {
      const distance = calculateDistance(
        parseFloat(latitude),
        parseFloat(longitude),
        opp.location.coordinates[1],
        opp.location.coordinates[0]
      );
      
      const volunteersNeeded = opp.volunteersNeeded - (opp.volunteersJoined?.length || 0);
      
      return {
        campaignId: opp._id,
        title: opp.title,
        category: opp.category,
        ngoName: opp.ngoId.name,
        ngoPhone: opp.ngoId.phone,
        distance: parseFloat(distance.toFixed(2)),
        startTime: opp.startDate,
        endTime: opp.endDate,
        volunteersNeeded,
        location: {
          address: opp.location.address,
          coordinates: {
            latitude: opp.location.coordinates[1],
            longitude: opp.location.coordinates[0]
          }
        },
        skillsRequired: opp.skillsRequired || [],
        whyMatters: opp.whyMatters
      };
    });
    
    opportunitiesWithDetails.sort((a, b) => a.distance - b.distance);
    
    res.json({
      success: true,
      count: opportunitiesWithDetails.length,
      opportunities: opportunitiesWithDetails,
      message: opportunitiesWithDetails.length > 0 ? 'Opportunities near you today!' : 'No opportunities today'
    });
    
  } catch (error) {
    console.error('Get today opportunities error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// VOLUNTEER SCREEN 2: Nearby Volunteer Opportunities
exports.getNearbyOpportunities = async (req, res) => {
  try {
    const { longitude, latitude, maxDistance = 50000, category } = req.query;

    if (!longitude || !latitude) {
      return res.status(400).json({ message: 'Location coordinates required' });
    }

    const now = new Date();

    const query = {
      status: 'approved',                 // Only admin approved
      volunteersNeeded: { $gt: 0 },       // Must need volunteers
      endDate: { $gte: now },             // Not expired
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(longitude), parseFloat(latitude)]
          },
          $maxDistance: parseInt(maxDistance)
        }
      }
    };

    if (category) {
      query.category = category;
    }

    const opportunities = await Campaign.find(query)
      .populate('ngoId', 'name phone email')
      .lean();

    const opportunitiesWithDetails = opportunities.map(opp => {
      const distance = calculateDistance(
        parseFloat(latitude),
        parseFloat(longitude),
        opp.location.coordinates[1],
        opp.location.coordinates[0]
      );

      const remainingVolunteers =
        opp.volunteersNeeded - (opp.volunteersJoined?.length || 0);

      return {
        campaignId: opp._id,
        title: opp.title,
        category: opp.category,
        ngoName: opp.ngoId.name,
        ngoPhone: opp.ngoId.phone,
        ngoEmail: opp.ngoId.email,
        distance: parseFloat(distance.toFixed(2)),
        startDate: opp.startDate,
        endDate: opp.endDate,
        volunteersNeeded: remainingVolunteers,
        location: {
          address: opp.location.address,
          pincode: opp.location.pincode,
          coordinates: {
            latitude: opp.location.coordinates[1],
            longitude: opp.location.coordinates[0]
          }
        },
        skillsRequired: opp.skillsRequired || [],
        whyMatters: opp.whyMatters
      };
    });

    opportunitiesWithDetails.sort((a, b) => a.distance - b.distance);

    res.json({
      success: true,
      count: opportunitiesWithDetails.length,
      opportunities: opportunitiesWithDetails
    });

  } catch (error) {
    console.error('Get nearby opportunities error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};


// Join as volunteer
exports.joinVolunteer = async (req, res) => {
  try {
    const { campaignId } = req.params;
    const volunteerId = req.user.id;
    
    const campaign = await Campaign.findById(campaignId);
    if (!campaign) {
      return res.status(404).json({ message: 'Campaign not found' });
    }
    
    // Check if already joined
    const alreadyJoined = campaign.volunteersJoined.some(
      v => v.userId.toString() === volunteerId
    );
    
    if (alreadyJoined) {
      return res.status(400).json({ message: 'Already joined as volunteer' });
    }
    
    // Check if spots available
    if (campaign.volunteersJoined.length >= campaign.volunteersNeeded) {
      return res.status(400).json({ message: 'No volunteer spots available' });
    }
    
    // Add volunteer
    campaign.volunteersJoined.push({
      userId: volunteerId,
      joinedAt: new Date(),
      status: 'confirmed'
    });
    
    await campaign.save();
    
    // Update volunteer progress
    let progress = await VolunteerProgress.findOne({ userId: volunteerId });
    if (!progress) {
      progress = new VolunteerProgress({ userId: volunteerId });
    }
    
    progress.addEvent(campaignId, 0, 10); // 10 points for joining
    await progress.save();
    
    res.json({
      success: true,
      message: 'Successfully joined as volunteer!',
      pointsEarned: 10
    });
    
  } catch (error) {
    console.error('Join volunteer error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get volunteer dashboard/progress
exports.getVolunteerProgress = async (req, res) => {
  try {
    const volunteerId = req.user.id;
    
    let progress = await VolunteerProgress.findOne({ userId: volunteerId })
      .populate({
        path: 'eventsParticipated.campaignId',
        select: 'title category ngoId',
        populate: {
          path: 'ngoId',
          select: 'name'
        }
      });
    
    if (!progress) {
      progress = new VolunteerProgress({ userId: volunteerId });
      await progress.save();
    }
    
    // Calculate next badge requirements
    const badgeRequirements = {
      'Beginner': { min: 0, max: 4, next: 'Helper', eventsNeeded: 5 },
      'Helper': { min: 5, max: 9, next: 'Contributor', eventsNeeded: 10 },
      'Contributor': { min: 10, max: 19, next: 'Champion', eventsNeeded: 20 },
      'Champion': { min: 20, max: 29, next: 'Hero', eventsNeeded: 30 },
      'Hero': { min: 30, max: 49, next: 'Legend', eventsNeeded: 50 },
      'Legend': { min: 50, max: Infinity, next: null, eventsNeeded: null }
    };
    
    const currentBadgeInfo = badgeRequirements[progress.currentBadge];
    const eventsToNextBadge = currentBadgeInfo.next 
      ? currentBadgeInfo.eventsNeeded - progress.totalEvents 
      : 0;
    
    res.json({
      success: true,
      progress: {
        currentBadge: progress.currentBadge,
        badgeColor: progress.badgeColor,
        totalEvents: progress.totalEvents,
        totalHours: progress.totalHours,
        totalScore: progress.totalScore,
        currentStreak: progress.currentStreak,
        longestStreak: progress.longestStreak,
        nextBadge: currentBadgeInfo.next,
        eventsToNextBadge,
        badgeHistory: progress.badgeHistory,
        recentEvents: progress.eventsParticipated.slice(-5),
        achievements: progress.achievements
      }
    });
    
  } catch (error) {
    console.error('Get volunteer progress error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get volunteer leaderboard
exports.getLeaderboard = async (req, res) => {
  try {
    const { type = 'overall', limit = 50 } = req.query;
    
    let sortField = 'totalScore';
    if (type === 'monthly') {
      // For monthly, we'd filter by events in current month
      // Simplified version here
      sortField = 'totalEvents';
    }
    
    const leaderboard = await VolunteerProgress.find()
      .populate('userId', 'name email')
      .sort({ [sortField]: -1 })
      .limit(parseInt(limit))
      .lean();
    
    const formattedLeaderboard = leaderboard.map((entry, index) => ({
      rank: index + 1,
      volunteerId: entry.userId._id,
      name: entry.userId.name,
      badge: entry.currentBadge,
      badgeColor: getBadgeColor(entry.currentBadge),
      totalEvents: entry.totalEvents,
      totalHours: entry.totalHours,
      totalScore: entry.totalScore,
      currentStreak: entry.currentStreak
    }));
    
    res.json({
      success: true,
      leaderboard: formattedLeaderboard
    });
    
  } catch (error) {
    console.error('Get leaderboard error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Helper functions
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371;
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

function getBadgeColor(badge) {
  const colors = {
    'Beginner': '#9E9E9E',
    'Helper': '#4CAF50',
    'Contributor': '#2196F3',
    'Champion': '#FF9800',
    'Hero': '#E91E63',
    'Legend': '#9C27B0'
  };
  return colors[badge] || '#9E9E9E';
}

module.exports = exports;