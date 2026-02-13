const mongoose = require('mongoose');

const campaignSchema = new mongoose.Schema({

  // ================= BASIC INFO =================
  ngoId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },

  title: {
    type: String,
    required: true,
    trim: true
  },

  description: {
    type: String,
    required: true
  },

  category: {
    type: String,
    enum: ['Food', 'Medical', 'Education', 'Emergency', 'Other'],
    required: true,
    index: true
  },

  // ================= LOCATION =================
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      required: true
    },
    address: String,
    pincode: String,
    area: String,
    city: String,
    state: String
  },

  // ================= DATE =================
  startDate: {
    type: Date,
    required: true,
    index: true
  },

  endDate: {
    type: Date,
    required: true
  },

  // ================= FUNDING =================
  targetAmount: {
    type: Number,
    required: true
  },

  currentAmount: {
    type: Number,
    default: 0
  },

  // 🔥 Link donations directly
  donations: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Donation'
  }],

  // ================= ITEMIZED NEEDS =================
  needs: [{
    item: String,
    quantity: Number,
    estimatedCost: Number,
    fulfilled: {
      type: Boolean,
      default: false
    }
  }],

  // ================= VOLUNTEERS =================
  volunteersNeeded: {
    type: Number,
    default: 0
  },

  volunteersJoined: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    joinedAt: {
      type: Date,
      default: Date.now
    },
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'completed'],
      default: 'confirmed'
    }
  }],

  // ================= STATUS =================
  status: {
    type: String,
    enum: ['pending', 'approved', 'live', 'completed', 'cancelled', 'rejected'],
    default: 'pending',
    index: true
  },

  rejectionReason: String,

  approvedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },

  approvedAt: Date,

  // ================= MEDIA =================
  images: [String],
  videos: [String],

  // ================= IMPACT =================
  impactStory: String,
  beneficiariesCount: Number,
  completionPhotos: [String],

  // ================= ENGAGEMENT =================
  supporters: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    supportedAt: {
      type: Date,
      default: Date.now
    }
  }],

  views: {
    type: Number,
    default: 0
  },

  // ================= TAX =================
  is80GEligible: {
    type: Boolean,
    default: false
  },

  // ================= STORY =================
  whyMatters: {
    type: String,
    required: true
  }

}, {
  timestamps: true
});


// ================= INDEXES =================

// Geospatial
campaignSchema.index({ location: '2dsphere' });

// Fast filtering
campaignSchema.index({ status: 1, startDate: 1 });
campaignSchema.index({ status: 1, category: 1 });
campaignSchema.index({ ngoId: 1 });


// ================= VIRTUALS =================

// Funding %
campaignSchema.virtual('fundingPercentage').get(function () {
  return this.targetAmount > 0
    ? Math.round((this.currentAmount / this.targetAmount) * 100)
    : 0;
});

// Auto status by date
campaignSchema.virtual('liveStatus').get(function () {
  const now = new Date();
  if (now < this.startDate) return 'upcoming';
  if (now >= this.startDate && now <= this.endDate) return 'live';
  return 'completed';
});

// Total donations count
campaignSchema.virtual('totalDonations').get(function () {
  return this.donations?.length || 0;
});


// ================= METHODS =================

// Distance calculation
campaignSchema.methods.getDistance = function (longitude, latitude) {
  const [campaignLng, campaignLat] = this.location.coordinates;

  const R = 6371;
  const dLat = (campaignLat - latitude) * Math.PI / 180;
  const dLon = (campaignLng - longitude) * Math.PI / 180;

  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(latitude * Math.PI / 180) *
    Math.cos(campaignLat * Math.PI / 180) *
    Math.sin(dLon / 2) ** 2;

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};


// Include virtuals
campaignSchema.set('toJSON', { virtuals: true });
campaignSchema.set('toObject', { virtuals: true });


module.exports = mongoose.model('Campaign', campaignSchema);
