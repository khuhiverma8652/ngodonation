const express = require('express');
const router = express.Router();

const adminController = require('../controllers/adminController');
const { protect } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

// ================= ADMIN DASHBOARD =================

// Get platform stats
// GET /api/admin/stats
router.get(
  '/stats',
  protect,
  authorize('admin'),
  adminController.getStats
);

// Get analytics
// GET /api/admin/analytics
router.get(
  '/analytics',
  protect,
  authorize('admin'),
  adminController.getAnalytics
);

// ================= USER MANAGEMENT =================

// Get all users
// GET /api/admin/users
router.get(
  '/users',
  protect,
  authorize('admin'),
  adminController.getAllUsers
);

// Activate / Deactivate user
// PUT /api/admin/users/:id/status
router.put(
  '/users/:id/status',
  protect,
  authorize('admin'),
  adminController.updateUserStatus
);

// Update user details
// PUT /api/admin/users/:id
router.put(
  '/users/:id',
  protect,
  authorize('admin'),
  adminController.updateUser
);

// Delete user
// DELETE /api/admin/users/:id
router.delete(
  '/users/:id',
  protect,
  authorize('admin'),
  adminController.deleteUser
);

// ================= NGO MANAGEMENT =================

// Verify NGO
// PUT /api/admin/ngo/:id/verify
router.put(
  '/ngo/:id/verify',
  protect,
  authorize('admin'),
  adminController.verifyNGO
);

// ================= CAMPAIGN MANAGEMENT =================

// Get pending campaigns
// GET /api/admin/campaigns/pending
router.get(
  '/campaigns/pending',
  protect,
  authorize('admin'),
  adminController.getPendingCampaigns
);

// Approve / Reject campaign
// PUT /api/admin/campaigns/:id/status
router.put(
  '/campaigns/:id/status',
  protect,
  authorize('admin'),
  adminController.updateCampaignStatus
);
// Get campaign details
router.get(
  '/campaigns/:id',
  protect,
  authorize('admin'),
  adminController.getCampaignDetails
);

// Get all donations
router.get(
  '/donations',
  protect,
  authorize('admin'),
  adminController.getAllDonations
);
// Approve campaign (alternative route)
router.put(
  "/:id/approve",
  protect,
  authorize("admin"),
  adminController.updateCampaignStatus
);

module.exports = router;
