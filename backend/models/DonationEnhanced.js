const mongoose = require('mongoose');

const donationSchema = new mongoose.Schema({
  // Donor IDs
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

  // Donation Type
  donationType: {
    type: String,
    enum: ['monetary', 'in-kind'],
    default: 'monetary'
  },

  // Amount (Required for monetary)
  amount: {
    type: Number,
    required: function () { return this.donationType === 'monetary'; },
    min: 0 // Allow 0 for in-kind
  },

  // Items (For in-kind)
  items: [{
    name: String,
    quantity: Number,
    value: Number,
    description: String
  }],

  // Receipt details
  receiptNumber: {
    type: String,
    required: function () { return this.donationType === 'monetary'; }
  },

  // Payment details
  paymentMode: {
    type: String,
    enum: ['razorpay', 'upi', 'card', 'netbanking', 'wallet', 'manual', 'in-kind'],
    required: function () { return this.donationType === 'monetary'; }
  },
  paymentId: String,
  paymentStatus: {
    type: String,
    enum: ['pending', 'success', 'failed', 'refunded', 'completed', 'received'],
    default: 'pending'
  },

  // NGO Verification details
  isVerifiedByNGO: {
    type: Boolean,
    default: false
  },
  verifiedAt: Date,
  receiverName: String,

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
  isThanked: {
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
  if (this.donationType === 'monetary' && !this.receiptNumber) {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');

    // Count donations today
    const startOfDay = new Date(date.setHours(0, 0, 0, 0));
    try {
      const count = await this.model('DonationEnhanced').countDocuments({
        createdAt: { $gte: startOfDay },
        donationType: 'monetary'
      });

      const sequence = String(count + 1).padStart(4, '0');
      this.receiptNumber = `NGO${year}${month}${day}${sequence}`;
    } catch (err) {
      return next(err);
    }
  }
  next();
});

// Index for queries
donationSchema.index({ donorId: 1, createdAt: -1 });
donationSchema.index({ campaignId: 1 });
donationSchema.index({ receiptNumber: 1 }, { sparse: true });

module.exports = mongoose.model('DonationEnhanced', donationSchema);
