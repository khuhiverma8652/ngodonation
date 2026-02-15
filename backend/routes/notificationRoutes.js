const express = require('express');
const router = express.Router();
const {
    getNotifications,
    markAsRead,
    markAllRead,
    createNotification,
    deleteNotification,
} = require('../controllers/notificationController');
const { protect } = require('../middleware/auth.middleware');

// All routes protected
router.use(protect);

router.get('/', getNotifications);
router.post('/', createNotification);
router.put('/read-all', markAllRead);
router.put('/:id/read', markAsRead);
router.delete('/:id', deleteNotification);

module.exports = router;
