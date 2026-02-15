const mongoose = require('mongoose');
const dotenv = require('dotenv');
const DonationEnhanced = require('./models/DonationEnhanced');

dotenv.config();

const check = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        const stats = await DonationEnhanced.aggregate([
            { $group: { _id: "$paymentStatus", count: { $sum: 1 } } }
        ]);
        console.log('Payment Status Counts in DonationEnhanced:', stats);

        process.exit();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
};
check();
