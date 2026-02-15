const mongoose = require('mongoose');
const dotenv = require('dotenv');
const DonationEnhanced = require('./models/DonationEnhanced');
const User = require('./models/User');

dotenv.config();

const checkDB = async () => {
    try {
        const uri = process.env.MONGODB_URI;
        console.log(`Connecting to: ${uri}`);
        await mongoose.connect(uri);
        console.log('MongoDB Connected');

        // 1. Get a random donor user
        const donor = await User.findOne({ role: 'donor' });
        if (!donor) {
            console.log("No donors found in DB!");
            process.exit();
        }
        console.log(`Checking impact for donor: ${donor.name} (${donor._id})`);

        // 2. Count donations
        const count = await DonationEnhanced.countDocuments({ donorId: donor._id });
        console.log(`Total Donations: ${count}`);

        // 3. Count SUCCESS donations
        const successCount = await DonationEnhanced.countDocuments({
            donorId: donor._id,
            paymentStatus: 'success'
        });
        console.log(`Success Donations: ${successCount}`);

        // 4. Sample a document to check structure
        const sample = await DonationEnhanced.findOne({ donorId: donor._id }).lean();
        if (sample) {
            console.log("Sample Donation:", JSON.stringify(sample, null, 2));
        } else {
            console.log("No donations found for this user.");
        }

        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

checkDB();
