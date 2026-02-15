const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Donation = require('./models/Donation');
const DonationEnhanced = require('./models/DonationEnhanced');

dotenv.config();

const check = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        const countOld = await Donation.countDocuments();
        const countEnhanced = await DonationEnhanced.countDocuments();
        console.log(`Donation (Old) count: ${countOld}`);
        console.log(`DonationEnhanced count: ${countEnhanced}`);

        if (countOld > 0) {
            const sampleOld = await Donation.findOne().populate('donor').lean();
            console.log('Sample Old Donation:', JSON.stringify(sampleOld, null, 2));
        }

        if (countEnhanced > 0) {
            const sampleEnhanced = await DonationEnhanced.findOne().lean();
            console.log('Sample Enhanced Donation:', JSON.stringify(sampleEnhanced, null, 2));
        }

        process.exit();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
};
check();
