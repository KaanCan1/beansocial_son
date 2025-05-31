"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authenticateTokenAdvanced = exports.extractBearerToken = exports.authenticateToken = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const authenticateToken = (req, res, next) => {
    try {
        const authHeader = req.headers["authorization"];
        console.log("Auth header:", authHeader);
        // Bearer token kontrolü
        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            return res.status(401).json({
                message: "Access denied. Bearer token required.",
                error: "MISSING_BEARER_TOKEN",
            });
        }
        // "Bearer " kısmını çıkar ve token'ı al
        const token = authHeader.substring(7); // "Bearer ".length = 7
        console.log("Extracted token:", token);
        if (!token || token.trim() === "") {
            return res.status(401).json({
                message: "Access denied. Token is empty.",
                error: "EMPTY_TOKEN",
            });
        }
        try {
            const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET || "your-secret-key");
            console.log("Decoded token:", decoded);
            req.user = decoded;
            next();
        }
        catch (err) {
            console.error("Token verification error:", err);
            // JWT hata tipini kontrol et
            if (err instanceof jsonwebtoken_1.default.TokenExpiredError) {
                return res.status(401).json({
                    message: "Token has expired.",
                    error: "TOKEN_EXPIRED",
                });
            }
            else if (err instanceof jsonwebtoken_1.default.JsonWebTokenError) {
                return res.status(403).json({
                    message: "Invalid token format.",
                    error: "INVALID_TOKEN_FORMAT",
                });
            }
            else {
                return res.status(403).json({
                    message: "Token verification failed.",
                    error: "TOKEN_VERIFICATION_FAILED",
                });
            }
        }
    }
    catch (error) {
        console.error("Authentication error:", error);
        return res.status(500).json({
            message: "Internal server error during authentication.",
            error: "AUTH_INTERNAL_ERROR",
        });
    }
};
exports.authenticateToken = authenticateToken;
// Alternatif: Daha esnek token extraction fonksiyonu
const extractBearerToken = (authHeader) => {
    if (!authHeader)
        return null;
    // Case-insensitive Bearer kontrolü
    const bearerMatch = authHeader.match(/^Bearer\s+(.+)$/i);
    return bearerMatch ? bearerMatch[1] : null;
};
exports.extractBearerToken = extractBearerToken;
// Gelişmiş versiyon - Multiple token source desteği
const authenticateTokenAdvanced = (req, res, next) => {
    var _a;
    let token = null;
    // 1. Authorization header'dan Bearer token
    const authHeader = req.headers["authorization"];
    token = (0, exports.extractBearerToken)(authHeader);
    // 2. Cookie'den token (fallback)
    if (!token && ((_a = req.cookies) === null || _a === void 0 ? void 0 : _a.token)) {
        token = req.cookies.token;
    }
    // 3. Query parameter'dan token (fallback - güvenlik riski, sadece development)
    if (!token && req.query.token && process.env.NODE_ENV === "development") {
        token = req.query.token;
    }
    if (!token) {
        return res.status(401).json({
            message: "Access denied. Bearer token required in Authorization header.",
            error: "NO_TOKEN_PROVIDED",
            hint: "Use: Authorization: Bearer <your-token>",
        });
    }
    try {
        const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET || "your-secret-key");
        req.user = {
            id: decoded.id,
            email: decoded.email,
        };
        next();
    }
    catch (err) {
        if (err instanceof jsonwebtoken_1.default.TokenExpiredError) {
            return res.status(401).json({
                message: "Token has expired. Please login again.",
                error: "TOKEN_EXPIRED",
                expiredAt: err.expiredAt,
            });
        }
        else if (err instanceof jsonwebtoken_1.default.JsonWebTokenError) {
            return res.status(403).json({
                message: "Invalid token. Please login again.",
                error: "INVALID_TOKEN",
            });
        }
        else {
            return res.status(500).json({
                message: "Token verification failed.",
                error: "VERIFICATION_ERROR",
            });
        }
    }
};
exports.authenticateTokenAdvanced = authenticateTokenAdvanced;
