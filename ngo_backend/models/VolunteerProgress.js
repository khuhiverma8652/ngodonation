const mongoose = require('mongoose');

const volunteerProgressSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  
  // Statistics
  totalEvents: {
    type: Number,
    default: 0
  },
  totalHours: {
    type: Number,
    default: 0
  },
  totalScore: {
    type: Number,
    default: 0
  },
  
  // Badge system
  currentBadge: {
    type: String,
    enum: ['Beginner', 'Helper', 'Contributor', 'Champion', 'Hero', 'Legend'],
    default: 'Beginner'
  },
  
  badgeHistory: [{
    badge: String,
    achievedAt: Date,
    eventCount: Number
  }],
  
  // Event participation
  eventsParticipated: [{
    campaignId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Campaign'
    },
    joinedAt: Date,
    completedAt: Date,
    hoursContributed: Number,
    scoreEarned: Number,
    feedback: String,
    rating: Number
  }],
  
  // Skills
  skills: [String],
  
  // Availability
  preferredCategories: [String],
  availability: {
    weekdays: [String], // ['Monday', 'Wednesday']
    weekends: Boolean,
    timeSlots: [String] // ['Morning', 'Evening']
  },
  
  // Location preferences
  preferredLocations: [{
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: [Number],
    radius: Number // in km
  }],
  
  // Achievements
  achievements: [{
    title: String,
    description: String,
    icon: String,
    achievedAt: Date
  }],
  
  // Rankings
  monthlyRank: Number,
  overallRank: Number,
  
  // Streak
  currentStreak: {
    type: Number,
    default: 0
  },
  longestStreak: {
    type: Number,
    default: 0
  },
  lastActiveDate: Date

}, {
  timestamps: true
});

// Calculate badge based on total events
volunteerProgressSchema.methods.updateBadge = function() {
  const events = this.totalEvents;
  let newBadge;
  
  if (events >= 50) newBadge = 'Legend';
  else if (events >= 30) newBadge = 'Hero';
  else if (events >= 20) newBadge = 'Champion';
  else if (events >= 10) newBadge = 'Contributor';
  else if (events >= 5) newBadge = 'Helper';
  else newBadge = 'Beginner';
  
  if (newBadge !== this.currentBadge) {
    this.badgeHistory.push({
      badge: newBadge,
      achievedAt: new Date(),
      eventCount: events
    });
    this.currentBadge = newBadge;
  }
};

// Add event participation
volunteerProgressSchema.methods.addEvent = function(campaignId, hours = 0, score = 0) {
  this.eventsParticipated.push({
    campaignId,
    joinedAt: new Date(),
    hoursContributed: hours,
    scoreEarned: score
  });
  
  this.totalEvents += 1;
  this.totalHours += hours;
  this.totalScore += score;
  
  this.updateBadge();
  this.updateStreak();
};

// Update streak
volunteerProgressSchema.methods.updateStreak = function() {
  const today = new Date();
  const lastActive = this.lastActiveDate ? new Date(this.lastActiveDate) : null;
  
  if (lastActive) {
    const daysDiff = Math.floor((today - lastActive) / (1000 * 60 * 60 * 24));
    
    if (daysDiff === 1) {
      this.currentStreak += 1;
      if (this.currentStreak > this.longestStreak) {
        this.longestStreak = this.currentStreak;
      }
    } else if (daysDiff > 1) {
      this.currentStreak = 1;
    }
  } else {
    this.currentStreak = 1;
  }
  
  this.lastActiveDate = today;
};

// Virtual for badge color
volunteerProgressSchema.virtual('badgeColor').get(function() {
  const colors = {
    'Beginner': '#9E9E9E',
    'Helper': '#4CAF50',
    'Contributor': '#2196F3',
    'Champion': '#FF9800',
    'Hero': '#E91E63',
    'Legend': '#9C27B0'
  };
  return colors[this.currentBadge] || '#9E9E9E';
});

volunteerProgressSchema.set('toJSON', { virtuals: true });
volunteerProgressSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('VolunteerProgress', volunteerProgressSchema);