const express = require("express");
const router = express.Router();

const { createPaymentOrder, verifyPayment } = require("../controllers/paymentController");
const { protect } = require("../middleware/auth.Middleware");

router.post("/create-order", protect, createPaymentOrder);
router.post("/verify", protect, verifyPayment);

module.exports = router;
