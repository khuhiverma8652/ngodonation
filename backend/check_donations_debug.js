const mongoose = require('mongoose');
const dotenv = require('dotenv');
const DonationEnhanced = require('./models/DonationEnhanced');
const User = require('./models/User');

dotenv.config();

const checkDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('MongoDB Connected');

        const count = await DonationEnhanced.countDocuments();
        console.log(`Total DonationEnhanced documents: ${count}`);

        const donations = await DonationEnhanced.find().limit(5).lean();
        console.log('Sample Donations:', JSON.stringify(donations, null, 2));

        const users = await User.find().limit(1).lean();
        console.log('Sample User:', JSON.stringify(users, null, 2));

        // Check if any match the user
        if (users.length > 0) {
            const userId = users[0]._id;
            const userDonations = await DonationEnhanced.find({ donorId: userId }).countDocuments();
            console.log(`Donations for user ${userId}: ${userDonations}`);
            const successDonations = await DonationEnhanced.find({ donorId: userId, paymentStatus: 'success' }).countDocuments();
            console.log(`Success Donations for user ${userId}: ${successDonations}`);
        }

        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

checkDB();
