const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

const Campaign = require('../models/Campaign');
const Donation = require('../models/Donation');
const DonationEnhanced = require('../models/DonationEnhanced');
const Pickup = require('../models/Pickup');
const VolunteerProgress = require('../models/VolunteerProgress');

async function clearData() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/ngo_donation', {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log('✓ Connected to MongoDB');

        console.log('Purging collections...');

        const campaignResult = await Campaign.deleteMany({});
        console.log(`- Deleted ${campaignResult.deletedCount} campaigns`);

        const donationResult = await Donation.deleteMany({});
        console.log(`- Deleted ${donationResult.deletedCount} legacy donations`);

        const donationEnhancedResult = await DonationEnhanced.deleteMany({});
        console.log(`- Deleted ${donationEnhancedResult.deletedCount} enhanced donations`);

        const pickupResult = await Pickup.deleteMany({});
        console.log(`- Deleted ${pickupResult.deletedCount} pickups`);

        console.log('Cleaning volunteer participation...');
        const volunteerResult = await VolunteerProgress.updateMany(
            {},
            {
                $set: {
                    totalEvents: 0,
                    totalHours: 0,
                    totalScore: 0,
                    currentBadge: 'Beginner',
                    badgeHistory: [],
                    eventsParticipated: [],
                    currentStreak: 0,
                    longestStreak: 0,
                    achievements: []
                }
            }
        );
        console.log(`- Reset progress for ${volunteerResult.modifiedCount} volunteers`);

        console.log('\n✓ Data clear completed successfully');
        process.exit(0);
    } catch (err) {
        console.error('✗ Error clearing data:', err);
        process.exit(1);
    }
}

clearData();
