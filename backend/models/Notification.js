const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    type: {
        type: String,
        enum: ['campaign', 'donation', 'volunteer', 'urgent', 'success', 'info'],
        default: 'info',
    },
    title: {
        type: String,
        required: true,
    },
    message: {
        type: String,
        required: true,
    },
    relatedCampaign: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Campaign',
    },
    read: {
        type: Boolean,
        default: false,
    },
}, { timestamps: true });

notificationSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);
