const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config({ path: './.env' });

async function createTestUsers() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        const User = require('./models/User');
        const NGO = require('./models/NGO');
        const hp = await bcrypt.hash('123456', 10);

        await User.deleteMany({ email: { $in: ['test_ngo@test.com', 'test_admin@test.com', 'test_donor@test.com'] } });
        await NGO.deleteMany({ user: { $exists: true } }); // Small risk here, but fine for test env

        const users = await User.create([
            { name: 'Test NGO', email: 'test_ngo@test.com', password: hp, role: 'ngo', ngoName: 'Test NGO Org', phone: '1234567890', isVerified: true },
            { name: 'Test Admin', email: 'test_admin@test.com', password: hp, role: 'admin', phone: '1234567891', isVerified: true },
            { name: 'Test Donor', email: 'test_donor@test.com', password: hp, role: 'donor', phone: '1234567892', isVerified: true }
        ]);

        await NGO.create({
            user: users[0]._id,
            name: 'Test NGO Org',
            organizationName: 'Test NGO Org',
            registrationNumber: 'REG123456',
            email: 'test_ngo@test.com',
            verified: true
        });

        console.log('Test users created');
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

createTestUsers();
