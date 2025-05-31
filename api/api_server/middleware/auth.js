const jwt = require("jsonwebtoken");

const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      return res.status(401).json({
        message: "Access denied. Bearer token required.",
        error: "MISSING_BEARER_TOKEN",
      });
    }

    try {
      const decoded = jwt.verify(
        token,
        process.env.JWT_SECRET || "your-secret-key"
      );
      req.user = {
        id: decoded.userId || decoded.id,
        email: decoded.email,
      };
      next();
    } catch (err) {
      console.error("Token verification error:", err);
      return res.status(403).json({
        message: "Invalid token format.",
        error: "INVALID_TOKEN_FORMAT",
      });
    }
  } catch (error) {
    console.error("Authentication error:", error);
    res.status(500).json({
      message: "Internal server error during authentication.",
      error: "AUTH_INTERNAL_ERROR",
    });
  }
};

module.exports = { authenticateToken };
