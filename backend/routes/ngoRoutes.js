const express = require('express');
const router = express.Router();
const {
  getDashboard,
  getAllNGOs,
  getNGOById,
  createOrUpdateProfile,
  addReview
} = require('../controllers/ngoController');
const { protect, authorize } = require('../middleware/auth.middleware');

// Public routes
router.get('/', getAllNGOs);
router.get('/:id', getNGOById);

// Protected routes
router.get('/dashboard/stats', protect, authorize('ngo'), getDashboard);
router.post('/profile', protect, authorize('ngo'), createOrUpdateProfile);
router.post('/:id/review', protect, addReview);

module.exports = router;