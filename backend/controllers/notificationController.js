const Notification = require('../models/Notification');
const Campaign = require('../models/Campaign');

// @desc    Get user notifications
// @route   GET /api/notifications
// @access  Private
exports.getNotifications = async (req, res) => {
    try {
        const notifications = await Notification.find({ userId: req.user._id })
            .populate('relatedCampaign', 'title category')
            .sort({ createdAt: -1 })
            .limit(50);

        const unreadCount = await Notification.countDocuments({
            userId: req.user._id,
            read: false,
        });

        res.json({
            success: true,
            notifications,
            unreadCount,
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Mark notification as read
// @route   PUT /api/notifications/:id/read
// @access  Private
exports.markAsRead = async (req, res) => {
    try {
        const notification = await Notification.findOneAndUpdate(
            { _id: req.params.id, userId: req.user._id },
            { read: true },
            { new: true }
        );

        if (!notification) {
            return res.status(404).json({ success: false, message: 'Not found' });
        }

        res.json({ success: true, notification });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Mark all notifications as read
// @route   PUT /api/notifications/read-all
// @access  Private
exports.markAllRead = async (req, res) => {
    try {
        await Notification.updateMany(
            { userId: req.user._id, read: false },
            { read: true }
        );
        res.json({ success: true, message: 'All notifications marked as read' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Create a notification (internal helper, also used as API)
// @route   POST /api/notifications
// @access  Private
exports.createNotification = async (req, res) => {
    try {
        const { userId, type, title, message, relatedCampaign } = req.body;

        const notification = await Notification.create({
            userId: userId || req.user._id,
            type: type || 'info',
            title,
            message,
            relatedCampaign,
        });

        res.status(201).json({ success: true, notification });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Delete a notification
// @route   DELETE /api/notifications/:id
// @access  Private
exports.deleteNotification = async (req, res) => {
    try {
        const notification = await Notification.findOneAndDelete({
            _id: req.params.id,
            userId: req.user._id,
        });

        if (!notification) {
            return res.status(404).json({ success: false, message: 'Not found' });
        }

        res.json({ success: true, message: 'Notification deleted' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Helper function to create notification programmatically (for use by other controllers)
exports.createNotificationHelper = async (userId, type, title, message, relatedCampaign = null) => {
    try {
        return await Notification.create({
            userId,
            type,
            title,
            message,
            relatedCampaign,
        });
    } catch (error) {
        console.error('Failed to create notification:', error.message);
        return null;
    }
};
