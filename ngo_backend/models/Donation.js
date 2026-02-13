const mongoose = require('mongoose');

const donationSchema = new mongoose.Schema({
  donor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  campaign: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Campaign',
    required: true
  },
  ngo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'NGO',
    required: true
  },
  amount: {
    type: Number,
    required: [true, 'Donation amount is required'],
    min: [1, 'Minimum donation amount is ₹1']
  },
  paymentMethod: {
    type: String,
    enum: ['card', 'upi', 'netbanking', 'wallet', 'cash'],
    required: true
  },
  transactionId: {
    type: String,
    unique: true,
    sparse: true
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'refunded'],
    default: 'pending'
  },
  receiptNumber: {
    type: String,
    unique: true
  },
  donationType: {
    type: String,
    enum: ['monetary', 'in-kind'],
    default: 'monetary'
  },
  items: [{
    name: String,
    quantity: Number,
    value: Number
  }],
  isAnonymous: {
    type: Boolean,
    default: false
  },
  message: {
    type: String,
    maxlength: [500, 'Message cannot exceed 500 characters']
  },
  taxExemption: {
    eligible: { type: Boolean, default: true },
    certificateGenerated: { type: Boolean, default: false },
    certificateUrl: String
  },
  refund: {
    requested: { type: Boolean, default: false },
    requestedAt: Date,
    reason: String,
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected', 'completed']
    },
    processedAt: Date,
    processedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }
  },
  metadata: {
    ipAddress: String,
    userAgent: String,
    deviceType: String
  }
}, {
  timestamps: true
});

// Indexes
donationSchema.index({ donor: 1, createdAt: -1 });
donationSchema.index({ campaign: 1, createdAt: -1 });
donationSchema.index({ ngo: 1, createdAt: -1 });
donationSchema.index({ paymentStatus: 1 });
donationSchema.index({ transactionId: 1 });

// Generate receipt number before saving
donationSchema.pre('save', async function(next) {
  if (!this.receiptNumber && this.paymentStatus === 'completed') {
    const count = await mongoose.model('Donation').countDocuments();
    this.receiptNumber = `RCP${Date.now()}${count + 1}`;
  }
  next();
});

const Donation = mongoose.model('Donation', donationSchema);

module.exports = Donation;