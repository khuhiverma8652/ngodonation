const express = require("express");
const router = express.Router();
const {
  createDonation,
  getDonorDonations,
  getNgoDonations,
  getVolunteerDonations,
} = require("../controllers/donation.controller");

const auth = require("../middleware/auth.middleware");

router.post("/", auth, createDonation);

router.get("/donor", auth, getDonorDonations);
router.get("/ngo", auth, getNgoDonations);
router.get("/volunteer", auth, getVolunteerDonations);

module.exports = router;
