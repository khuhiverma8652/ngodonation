const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// ================= JWT =================
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'secret', {
    expiresIn: '7d',
  });
};

// ================= REGISTER =================
exports.register = async (req, res) => {
  try {
    const { name, email, password, phone, role, ngoName, ngoAddress } = req.body;


    if (!name || !email || !password || !role) {
      return res.status(400).json({
        success: false,
        message: 'Missing fields',
      });
    }

    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({
        success: false,
        message: 'User already exists',
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const allowedRoles = ['donor', 'ngo', 'volunteer', 'admin'];

   const user = await User.create({
  name,
  email,
  password,
  phone,
  role,
  ngoName,
  ngoAddress
});


    res.json({
      success: true,
      message: 'Registered successfully. Use OTP 123456',
      user
    });

  } catch (error) {
    console.error("REGISTER ERROR:", error);
    res.status(500).json({
      success: false,
      message: 'Registration failed',
    });
  }
};

// ================= VERIFY OTP =================
// ================= VERIFY OTP =================
exports.verifyOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;

    console.log("VERIFY BODY:", req.body);

    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: "Email and OTP required",
      });
    }

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    console.log("USER BEFORE VERIFY:", user.isVerified);

    if (user.otp !== otp) {
      return res.status(400).json({
        success: false,
        message: "Invalid OTP",
      });
    }

    // FORCE UPDATE
    await User.updateOne(
      { email },
      {
        $set: {
          isVerified: true,
          otp: null,
        },
      }
    );

    const updatedUser = await User.findOne({ email });
    console.log("USER AFTER VERIFY:", updatedUser.isVerified);

    return res.json({
      success: true,
      message: "OTP verified successfully",
    });

  } catch (error) {
    console.error("VERIFY ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "OTP verification failed",
    });
  }
};
// ================= LOGIN =================
// ================= LOGIN =================
exports.login = async (req, res) => {
  try {
    const { email, password, role } = req.body;

    if (!email || !password || !role) {
      return res.status(400).json({
        success: false,
        message: "Email, password and role required",
      });
    }

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "User not found",
      });
    }

    // 🔥 ROLE CHECK
    if (user.role !== role) {
      return res.status(403).json({
        success: false,
        message: `You are not registered as ${role}`,
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    const token = generateToken(user._id);

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,  // 🔥 send role
        },
      },
    });

  } catch (error) {
    console.error("LOGIN ERROR:", error);
    res.status(500).json({
      success: false,
      message: "Login failed",
    });
  }
};
// ================= PROFILE =================
exports.getMe = async (req, res) => {
  res.json({
    success: true,
    message: 'Profile route working',
  });
};

