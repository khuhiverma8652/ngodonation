const mongoose = require('mongoose');
const Donation = require('./models/DonationEnhanced');

async function check() {
    await mongoose.connect('mongodb://127.0.0.1:27017/ngo_donation');
    const all = await Donation.find({});
    console.log('Total donations:', all.length);
    all.forEach((d, i) => {
        console.log(`${i}: Type=${d.donationType}, Receipt=${d.receiptNumber}`);
    });
    mongoose.connection.close();
}

check();
