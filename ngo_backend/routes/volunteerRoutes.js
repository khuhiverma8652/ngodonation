const express = require('express');
const router = express.Router();

const volunteerController = require('../controllers/volunteerController');
const { protect } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

// Get today's opportunities
router.get(
  '/today',
  protect,
  authorize('volunteer'),
  volunteerController.getTodayOpportunities
);

// Get nearby opportunities
router.get(
  '/nearby',
  protect,
  authorize('volunteer'),
  volunteerController.getNearbyOpportunities
);

// Join campaign
router.post(
  '/join/:campaignId',
  protect,
  authorize('volunteer'),
  volunteerController.joinVolunteer   // ✅ FIXED NAME
);

// Get volunteer progress
router.get(
  '/progress',
  protect,
  authorize('volunteer'),
  volunteerController.getVolunteerProgress
);

// Leaderboard
router.get(
  '/leaderboard',
  protect,
  authorize('volunteer'),
  volunteerController.getLeaderboard
);

module.exports = router;
