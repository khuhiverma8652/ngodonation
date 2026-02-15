const mongoose = require('mongoose');
const dotenv = require('dotenv');
const DonationEnhanced = require('./models/DonationEnhanced');

dotenv.config();

const check = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        const donations = await DonationEnhanced.find().select('donorId').lean();
        console.log('Donor IDs in DonationEnhanced:', donations.map(d => d.donorId));

        process.exit();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
};
check();
