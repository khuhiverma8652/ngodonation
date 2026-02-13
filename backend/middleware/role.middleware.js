// middleware/role.middleware.js

exports.authorize = (...roles) => {
  return (req, res, next) => {
    // Make sure user exists (protect middleware must run first)
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: "Not authenticated",
      });
    }

    // Check if user role is allowed
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: "Access denied. You do not have permission.",
      });
    }

    next();
  };
};
