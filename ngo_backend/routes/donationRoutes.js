const express = require('express');
const router = express.Router();
const donationController = require('../controllers/donationEnhancedController');
const { protect } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');
const { getDonorImpact } = require('../controllers/donationController');
const Donation = require('../models/Donation');




// All routes are protected (require authentication)
router.use(protect);

// Create donation and generate receipt
router.post('/create', protect, donationController.createDonation);
router.post(
  '/donate',
  protect,
  authorize('donor'),
  donationController.createDonation
);
// Get donation receipt
router.get('/receipt/:id', donationController.getReceipt);

// Get donation history for logged-in user
router.get('/history', donationController.getDonationHistory);

// Get all donations (for NGO/Admin)
router.get('/all', donationController.getAllDonations);

// Get donation statistics
router.get('/stats', donationController.getDonationStats);

// Download receipt PDF
router.get('/download-receipt/:id', donationController.downloadReceipt);
router.get('/impact', protect, getDonorImpact);
router.get('/admin/all', protect, authorize('admin'), async (req, res) => {
  const donations = await Donation.find()
    .populate("donor", "name email")
    .populate("campaign", "title")
    .populate("ngo", "name");

  res.json({ success: true, donations });
});
// 🔵 NGO - View My Donations
router.get(
  '/ngo/my-donations',
  protect,
  authorize('ngo'),
  async (req, res) => {
    try {
      const donations = await Donation.find({ ngo: req.user._id })
        .populate("donor", "name email")
        .populate("campaign", "title");

      res.json({
        success: true,
        count: donations.length,
        donations
      });

    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }
);

router.get(
  '/admin/all-donations',
  protect,
  authorize('admin'),
  async (req, res) => {
    const donations = await Donation.find()
      .populate("donor", "name email")
      .populate("ngo", "name")
      .populate("campaign", "title");

    res.json({
      success: true,
      count: donations.length,
      donations
    });
  }
);


module.exports = router;