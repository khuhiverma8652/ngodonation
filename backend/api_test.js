const axios = require('axios');
const baseUrl = 'http://localhost:5000/api';

async function testFlow() {
    let ngoToken, adminToken, donorToken;
    let campaignId, orderId;

    try {
        console.log('--- Phase 1: Authentication ---');

        // Login as NGO
        console.log('Logging in as NGO...');
        const ngoLogin = await axios.post(`${baseUrl}/auth/login`, {
            email: 'test_ngo@test.com',
            password: '123456',
            role: 'ngo'
        });
        ngoToken = ngoLogin.data.data.token;
        console.log('NGO Login Successful');

        // Login as Admin
        console.log('Logging in as Admin...');
        const adminLogin = await axios.post(`${baseUrl}/auth/login`, {
            email: 'test_admin@test.com',
            password: '123456',
            role: 'admin'
        });
        adminToken = adminLogin.data.data.token;
        console.log('Admin Login Successful');

        // Login as Donor
        console.log('Logging in as Donor...');
        const donorLogin = await axios.post(`${baseUrl}/auth/login`, {
            email: 'test_donor@test.com',
            password: '123456',
            role: 'donor'
        });
        donorToken = donorLogin.data.data.token;
        console.log('Donor Login Successful');

        console.log('\n--- Phase 2: Campaign Creation ---');
        const newCampaign = await axios.post(`${baseUrl}/campaigns`, {
            title: 'API Test Campaign ' + Date.now(),
            category: 'Food',
            whyMatters: 'Testing API data flow',
            area: 'Test Area',
            pincode: '123456',
            targetAmount: 1000,
            startDate: new Date(),
            endDate: new Date(Date.now() + 86400000),
            longitude: 77.209,
            latitude: 28.6139
        }, { headers: { Authorization: `Bearer ${ngoToken}` } });

        campaignId = newCampaign.data.campaign._id;
        console.log('Campaign Created:', campaignId);

        console.log('\n--- Phase 3: Admin Approval ---');
        console.log('Fetching Pending Campaigns...');
        const pending = await axios.get(`${baseUrl}/admin/campaigns/pending`, {
            headers: { Authorization: `Bearer ${adminToken}` }
        });
        console.log('Pending Campaigns Count:', pending.data.count);

        console.log('Approving Campaign...');
        await axios.put(`${baseUrl}/admin/campaigns/${campaignId}/status`, {
            status: 'approved'
        }, { headers: { Authorization: `Bearer ${adminToken}` } });
        console.log('Campaign Approved');

        console.log('\n--- Phase 4: Donor Interaction ---');
        console.log('Fetching Nearby Campaigns...');
        const nearby = await axios.get(`${baseUrl}/campaigns/nearby?longitude=77.209&latitude=28.6139`, {
            headers: { Authorization: `Bearer ${donorToken}` }
        });
        const found = nearby.data.campaigns.find(c => c._id === campaignId);
        console.log('Campaign Found in Nearby:', found ? 'Yes' : 'No');

        console.log('Creating Payment Order...');
        const order = await axios.post(`${baseUrl}/payments/create-order`, {
            campaignId: campaignId,
            amount: 100
        }, { headers: { Authorization: `Bearer ${donorToken}` } });
        orderId = order.data.orderId;
        console.log('Order Created:', orderId);

        console.log('Verifying Payment...');
        await axios.post(`${baseUrl}/payments/verify`, {
            razorpay_order_id: orderId,
            razorpay_payment_id: 'pay_test_' + Date.now(),
            razorpay_signature: 'dummy_signature', // Note: This will fail if signature check is real!
            campaignId: campaignId,
            amount: 100
        }, { headers: { Authorization: `Bearer ${donorToken}` } });
        console.log('Payment Verified');

        console.log('\n--- Phase 5: NGO Dashboard Verification ---');
        const ngoDash = await axios.get(`${baseUrl}/ngo/dashboard/stats`, {
            headers: { Authorization: `Bearer ${ngoToken}` }
        });
        console.log('NGO Stats:', JSON.stringify(ngoDash.data.stats, null, 2));

    } catch (error) {
        console.error('Error during test sequence:');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', JSON.stringify(error.response.data, null, 2));
        } else {
            console.error(error.message);
        }
    }
}

testFlow();
