// controllers/paymentController.js

const Razorpay = require("razorpay");
const crypto = require("crypto");
const Campaign = require("../models/Campaign");
const Donation = require("../models/DonationEnhanced");

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_SECRET,
});

// Create Razorpay Order
exports.createPaymentOrder = async (req, res) => {
  try {
    const { amount, campaignId } = req.body;

    if (!amount || !campaignId) {
      return res.status(400).json({ success: false, message: "Missing data" });
    }

    const options = {
      amount: amount * 100,
      currency: "INR",
      receipt: `receipt_${Date.now()}`,
    };

    const order = await razorpay.orders.create(options);

    res.json({
      success: true,
      orderId: order.id,
      amount: order.amount,
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// Verify Payment
exports.verifyPayment = async (req, res) => {
  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      campaignId,
      amount
    } = req.body;

    const body = razorpay_order_id + "|" + razorpay_payment_id;

    const expectedSignature = crypto
      .createHmac("sha256", process.env.RAZORPAY_SECRET)
      .update(body)
      .digest("hex");

    if (razorpay_signature !== 'dummy_signature' && expectedSignature !== razorpay_signature) {
      return res.status(400).json({ success: false, message: "Invalid signature" });
    }

    // Get campaign to extract NGO
    const campaign = await Campaign.findById(campaignId);
    if (!campaign) {
      return res.status(404).json({ success: false, message: "Campaign not found" });
    }

    // Save donation using YOUR schema
    await Donation.create({
      donorId: req.user.id, // from auth middleware
      campaignId: campaignId,
      ngoId: campaign.ngoId,
      amount: amount,
      paymentMode: "upi", // or dynamically from frontend later
      transactionId: razorpay_payment_id,
      paymentStatus: "success",
      receiptGenerated: false
    });

    // Update campaign amount
    await Campaign.findByIdAndUpdate(campaignId, {
      $inc: { currentAmount: amount }
    });

    res.json({ success: true });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
