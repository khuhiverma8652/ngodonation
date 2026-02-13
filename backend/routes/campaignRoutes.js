const express = require('express');
const router = express.Router();
console.log("Campaign routes loaded");

const campaignController = require('../controllers/campaignController');
const { protect } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

/* ======================
   NGO ROUTES
====================== */

// CREATE CAMPAIGN
router.post(
  '/',
  protect,
  authorize('ngo'),
  campaignController.createCampaign
);

/* ======================
   DONOR ROUTES
====================== */

router.get('/nearby', protect, campaignController.getNearbyCampaigns);
router.get('/map', protect, campaignController.getMapCampaigns);
router.get('/today', protect, campaignController.getTodayCampaigns);
router.get('/donation-needs', protect, campaignController.getDonationNeeds);
router.get('/local-impact', protect, campaignController.getLocalImpact);

/* ======================
   CAMPAIGN DETAILS
====================== */

router.get('/:id', protect, campaignController.getCampaignDetails);

/* ======================
   SUPPORT
====================== */

router.post('/:id/support', protect, campaignController.supportCampaign);

/* ======================
   ADMIN
====================== */

router.put(
  '/:id/status',
  protect,
  authorize('admin'),
  campaignController.updateCampaignStatus
);

module.exports = router;
