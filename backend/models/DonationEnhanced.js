const mongoose = require('mongoose');

const donationSchema = new mongoose.Schema({
  donorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  campaignId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Campaign',
    required: true
  },
  ngoId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },

  // Amount
  amount: {
    type: Number,
    required: true,
    min: 1
  },

  // Receipt details
  receiptNumber: {
    type: String,
    unique: true,
    required: true
  },

  // Payment details
  paymentMode: {
    type: String,
    enum: ['razorpay', 'upi', 'card', 'netbanking', 'wallet'],
    required: true
  },
  paymentId: String,
  paymentStatus: {
    type: String,
    enum: ['pending', 'success', 'failed', 'refunded'],
    default: 'pending'
  },

  // Transaction details
  transactionId: String,
  transactionDate: {
    type: Date,
    default: Date.now
  },

  // 80G Details
  is80GEligible: Boolean,
  panNumber: String, // Required for 80G

  // Donor details (for receipt)
  donorName: String,
  donorEmail: String,
  donorPhone: String,
  donorAddress: String,

  // Purpose
  purpose: {
    type: String,
    default: 'Campaign Donation'
  },
  message: String,

  // Anonymous donation
  isAnonymous: {
    type: Boolean,
    default: false
  },

  // Receipt generation
  receiptGenerated: {
    type: Boolean,
    default: false
  },
  receiptUrl: String,
  receiptGeneratedAt: Date,

  // Notifications
  receiptSentViaEmail: {
    type: Boolean,
    default: false
  },
  receiptSentViaWhatsApp: {
    type: Boolean,
    default: false
  },

  // Metadata
  metadata: {
    deviceType: String,
    appVersion: String,
    location: {
      type: {
        type: String,
        enum: ['Point']
      },
      coordinates: [Number]
    }
  }

}, {
  timestamps: true
});

// Generate unique receipt number
donationSchema.pre('validate', async function (next) {
  if (!this.receiptNumber) {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');

    // Count donations today
    const startOfDay = new Date(date.setHours(0, 0, 0, 0));
    const count = await this.constructor.countDocuments({
      createdAt: { $gte: startOfDay }
    });

    const sequence = String(count + 1).padStart(4, '0');
    this.receiptNumber = `NGO${year}${month}${day}${sequence}`;
  }
  next();
});

// Index for queries
donationSchema.index({ donorId: 1, createdAt: -1 });
donationSchema.index({ campaignId: 1 });
donationSchema.index({ receiptNumber: 1 }, { unique: true });

module.exports = mongoose.model('DonationEnhanced', donationSchema);
