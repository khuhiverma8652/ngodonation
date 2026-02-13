const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },

  email: {
    type: String,
    required: true,
    unique: true,
  },

  password: {
    type: String,
    required: true,
  },

  role: {
    type: String,
    enum: ['donor', 'ngo', 'admin', 'volunteer'],
    default: 'donor',
  },

  phone: {
    type: String,
  },

  // ✅ NEW NGO FIELDS (INSIDE SCHEMA)
  ngoName: {
    type: String,
    required: function () {
      return this.role === 'ngo';
    }
  },

  ngoAddress: {
    type: String,
  },

  otp: {
    type: String,
  },

  isVerified: {
    type: Boolean,
    default: false,
  },

  isActive: {
    type: Boolean,
    default: true,
  }

}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
