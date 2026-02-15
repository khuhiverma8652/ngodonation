const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const sendOTP = require('../utils/sendOTP');
const crypto = require('crypto');

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

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      phone,
      role,
      ngoName,
      ngoAddress,
      otp, // Save OTP to database
      isVerified: false
    });

    // Send OTP via Email
    try {
      await sendOTP({ to: email, otp });
    } catch (emailError) {
      console.error("EMAIL SEND ERROR:", emailError);
      // We still registered the user, but email failed.
    }

    res.json({
      success: true,
      message: 'Registered successfully. Please check your email for OTP.',
      user: {
        id: user._id,
        name: user.name,
        email: user.email
      }
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

    // 🔥 VERIFIED CHECK
    if (!user.isVerified) {
      // Generate new OTP and send if not verified
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      user.otp = otp;
      await user.save();

      try {
        await sendOTP({ to: email, otp });
      } catch (e) { }

      return res.status(401).json({
        success: false,
        verified: false,
        message: "Account not verified. New OTP sent to email.",
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

// ================= RESEND OTP =================
exports.resendOTP = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ success: false, message: "Email required" });

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ success: false, message: "User not found" });

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.otp = otp;
    await user.save();

    await sendOTP({ to: email, otp });

    res.json({ success: true, message: "OTP resent to email" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Failed to resend OTP" });
  }
};
// ================= PROFILE =================
exports.getMe = async (req, res) => {
  res.json({
    success: true,
    message: 'Profile route working',
  });
};

// ================= FORGOT PASSWORD =================
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, message: "Email required" });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.otp = otp;
    await user.save();

    // Send OTP via Email
    try {
      await sendOTP({ to: email, otp });
    } catch (emailError) {
      console.error("FORGOT PASSWORD EMAIL ERROR:", emailError);
      return res.status(500).json({ success: false, message: "Failed to send OTP email" });
    }

    res.json({
      success: true,
      message: 'Password reset OTP sent to email',
    });

  } catch (error) {
    console.error("FORGOT PASSWORD ERROR:", error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
};

// ================= RESET PASSWORD =================
exports.resetPassword = async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;

    if (!email || !otp || !newPassword) {
      return res.status(400).json({
        success: false,
        message: "Email, OTP and new password required",
      });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (user.otp !== otp) {
      return res.status(400).json({
        success: false,
        message: "Invalid OTP",
      });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    user.otp = null; // Clear OTP
    await user.save();

    res.json({
      success: true,
      message: "Password reset successfully",
    });

  } catch (error) {
    console.error("RESET PASSWORD ERROR:", error);
    res.status(500).json({
      success: false,
      message: "Failed to reset password",
    });
  }
};

