const mongoose = require('mongoose');

const pickupSchema = new mongoose.Schema({
  donor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  campaign: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Campaign'
  },
  ngo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'NGO',
    required: true
  },
  donationType: {
    type: String,
    enum: ['food', 'clothes', 'books', 'furniture', 'electronics', 'medical', 'other'],
    required: true
  },
  items: [{
    name: {
      type: String,
      required: true
    },
    quantity: {
      type: Number,
      required: true
    },
    unit: {
      type: String,
      enum: ['kg', 'pieces', 'boxes', 'bags', 'liters', 'units'],
      default: 'pieces'
    },
    estimatedValue: Number,
    description: String
  }],
  pickupAddress: {
    street: {
      type: String,
      required: true
    },
    city: {
      type: String,
      required: true
    },
    state: {
      type: String,
      required: true
    },
    pincode: {
      type: String,
      required: true
    },
    landmark: String,
    contactPerson: {
      name: String,
      phone: String
    }
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      required: true
    }
  },
  preferredDate: {
    type: Date,
    required: true
  },
  preferredTimeSlot: {
    type: String,
    enum: ['morning', 'afternoon', 'evening'],
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'scheduled', 'in-transit', 'completed', 'cancelled'],
    default: 'pending'
  },
  scheduledDate: Date,
  scheduledTimeSlot: String,
  assignedTo: {
    name: String,
    phone: String,
    vehicleNumber: String
  },
  pickupOTP: {
    type: String
  },
  actualPickupTime: Date,
  completedAt: Date,
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters']
  },
  photos: [{
    url: String,
    uploadedAt: {
      type: Date,
      default: Date.now
    }
  }],
  rating: {
    score: {
      type: Number,
      min: 1,
      max: 5
    },
    feedback: String,
    ratedAt: Date
  },
  cancellation: {
    cancelledBy: {
      type: String,
      enum: ['donor', 'ngo', 'system']
    },
    reason: String,
    cancelledAt: Date
  }
}, {
  timestamps: true
});

// Indexes
pickupSchema.index({ location: '2dsphere' });
pickupSchema.index({ donor: 1, createdAt: -1 });
pickupSchema.index({ ngo: 1, status: 1 });
pickupSchema.index({ status: 1, preferredDate: 1 });

// Generate OTP before saving when scheduled
pickupSchema.pre('save', function(next) {
  if (this.isModified('status') && this.status === 'scheduled' && !this.pickupOTP) {
    this.pickupOTP = Math.floor(1000 + Math.random() * 9000).toString();
  }
  next();
});

const Pickup = mongoose.model('Pickup', pickupSchema);

module.exports = Pickup;