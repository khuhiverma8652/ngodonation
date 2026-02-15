const nodemailer = require('nodemailer');
const path = require('path');
const fs = require('fs');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});

exports.sendDonationReceipt = async (donation, receiptUrl) => {
    try {
        const filePath = path.join(__dirname, '../uploads', receiptUrl);

        const mailOptions = {
            from: `"NGO Donation Platform" <${process.env.EMAIL_USER}>`,
            to: donation.donorEmail,
            subject: `Donation Receipt - ${donation.receiptNumber || 'NGO Donation'}`,
            text: `Dear ${donation.donorName},\n\nThank you for your generous donation to ${donation.purpose}. Please find your donation receipt attached to this email.\n\nYour support makes a huge difference!\n\nBest regards,\nNGO Donation Team`,
            attachments: [
                {
                    filename: `receipt_${donation.receiptNumber || 'donation'}.pdf`,
                    path: filePath,
                },
            ],
        };

        await transporter.sendMail(mailOptions);
        console.log(`Receipt sent to ${donation.donorEmail}`);
        return true;
    } catch (error) {
        console.error('Error sending donation receipt email:', error);
        return false;
    }
};

exports.sendItemDonationNotification = async (donation) => {
    try {
        const mailOptions = {
            from: `"NGO Donation Platform" <${process.env.EMAIL_USER}>`,
            to: donation.donorEmail,
            subject: 'Item Donation Submitted',
            text: `Dear ${donation.donorName},\n\nYour item donation for ${donation.purpose} has been submitted. It is currently awaiting verification from the NGO. Once the NGO receives and verifies the items, you will receive your final donation receipt.\n\nThank you for your support!\n\nBest regards,\nNGO Donation Team`,
        };

        await transporter.sendMail(mailOptions);
        return true;
    } catch (error) {
        console.error('Error sending item donation notification:', error);
        return false;
    }
};
