// controllers/paymentController.js

const Razorpay = require("razorpay");
const crypto = require("crypto");
const Campaign = require("../models/Campaign");
const Donation = require("../models/DonationEnhanced");
const notificationController = require("./notificationController");

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

    if (expectedSignature !== razorpay_signature) {
      return res.status(400).json({ success: false, message: "Invalid signature" });
    }

    // Get campaign to extract NGO
    const campaign = await Campaign.findById(campaignId);
    if (!campaign) {
      return res.status(404).json({ success: false, message: "Campaign not found" });
    }

    // Get donor details for receipt
    const User = require("../models/User");
    const donor = await User.findById(req.user.id);

    // Save donation using YOUR schema
    const donation = await Donation.create({
      donorId: req.user.id,
      campaignId: campaignId,
      ngoId: campaign.ngoId,
      amount: amount,
      paymentMode: "upi",
      transactionId: razorpay_payment_id,
      paymentStatus: "success",
      donorName: donor?.name || "Donor",
      donorEmail: donor?.email || "",
      donorPhone: donor?.phone || "",
      donorAddress: donor?.address || "",
      purpose: `Donation for ${campaign.title}`,
      isVerifiedByNGO: true, // Monetary verified by payment
      receiptGenerated: false
    });

    // Generate Receipt
    const { generateReceipt } = require("./donationEnhancedController");
    const populatedCampaign = await Campaign.findById(campaignId).populate('ngoId');
    const receiptData = await generateReceipt(donation, populatedCampaign, donor);

    donation.receiptGenerated = true;
    donation.receiptUrl = receiptData.url;
    donation.receiptGeneratedAt = new Date();
    await donation.save();

    // Send Email
    const mailService = require("../services/mail.service");
    await mailService.sendDonationReceipt(donation, receiptData.url);

    // Update campaign amount & donors
    await Campaign.findByIdAndUpdate(campaignId, {
      $inc: {
        currentAmount: amount,
        totalDonors: 1
      }
    });

    // Notify Donor
    await notificationController.createNotificationHelper(
      req.user.id,
      'donation',
      'Donation Successful!',
      `Thank you for your donation of ₹${amount} to "${campaign.title}". You're making a difference!`,
      campaignId
    );

    res.json({
      success: true,
      message: "Payment verified and receipt emailed!",
      receiptUrl: receiptData.url
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
