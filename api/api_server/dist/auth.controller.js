"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.uploadProfileImage = exports.updateUser = exports.getUserById = exports.getAllUsers = exports.login = exports.signup = void 0;
const client_1 = require("@prisma/client");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const fs_1 = __importDefault(require("fs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const prisma = new client_1.PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || "default_secret";
// Configure multer for image upload
const storage = multer_1.default.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = path_1.default.join(__dirname, "../../uploads");
        // Create uploads directory if it doesn't exist
        if (!fs_1.default.existsSync(uploadDir)) {
            fs_1.default.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        cb(null, "profile-" + uniqueSuffix + path_1.default.extname(file.originalname));
    },
});
const upload = (0, multer_1.default)({
    storage: storage,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB limit
    },
    fileFilter: (req, file, cb) => {
        const allowedTypes = ["image/jpeg", "image/png", "image/gif", "image/jpg"];
        if (allowedTypes.includes(file.mimetype)) {
            cb(null, true);
        }
        else {
            cb(new Error("Invalid file type. Only JPEG, PNG and GIF are allowed."));
        }
    },
}).single("image");
const signup = async (req, res) => {
    console.log("Gelen body:", req.body);
    const { email, password, name } = req.body;
    if (!email || !password || !name) {
        return res.status(400).json({ message: "Tüm alanlar zorunludur." });
    }
    try {
        const existingUser = await prisma.user.findUnique({ where: { email } });
        if (existingUser) {
            return res
                .status(400)
                .json({ message: "Bu email ile kayıtlı kullanıcı var." });
        }
        const hashedPassword = await bcryptjs_1.default.hash(password, 10);
        const user = await prisma.user.create({
            data: {
                email,
                password: hashedPassword,
                name,
                username: email.split("@")[0],
            },
        });
        return res.status(200).json({
            message: "Kayıt başarılı",
            user: { id: user.id, email: user.email, name: user.name },
        });
    }
    catch (err) {
        return res.status(500).json({ message: "Sunucu hatası", error: err });
    }
};
exports.signup = signup;
const login = async (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).json({ message: "Email ve şifre zorunlu." });
    }
    try {
        const user = await prisma.user.findUnique({ where: { email } });
        if (!user) {
            return res.status(400).json({ message: "Kullanıcı bulunamadı." });
        }
        const isMatch = await bcryptjs_1.default.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: "Şifre yanlış." });
        }
        const token = jsonwebtoken_1.default.sign({ userId: user.id, email: user.email }, JWT_SECRET, {
            expiresIn: "7d",
        });
        return res.status(200).json({
            message: "Giriş başarılı",
            token,
            user: { id: user.id, email: user.email, name: user.name },
        });
    }
    catch (err) {
        return res.status(500).json({ message: "Sunucu hatası", error: err });
    }
};
exports.login = login;
const getAllUsers = async (req, res) => {
    try {
        const users = await prisma.user.findMany({
            select: {
                id: true,
                email: true,
                name: true,
                username: true,
                createdAt: true,
                updatedAt: true,
                profileImage: true,
                bio: true,
            },
        });
        return res.status(200).json(users);
    }
    catch (err) {
        return res.status(500).json({ message: "Sunucu hatası", error: err });
    }
};
exports.getAllUsers = getAllUsers;
const getUserById = async (req, res) => {
    const { id } = req.params;
    try {
        const user = await prisma.user.findUnique({
            where: { id },
            select: {
                id: true,
                email: true,
                name: true,
                username: true,
                profileImage: true,
                bio: true,
            },
        });
        if (!user)
            return res.status(404).json({ message: "Kullanıcı bulunamadı" });
        return res.status(200).json(user);
    }
    catch (err) {
        return res.status(500).json({ message: "Sunucu hatası", error: err });
    }
};
exports.getUserById = getUserById;
const updateUser = async (req, res) => {
    const { id } = req.params;
    const { name, email, profileImage, bio } = req.body;
    try {
        const updated = await prisma.user.update({
            where: { id },
            data: { name, email, profileImage, bio },
        });
        return res.status(200).json({ message: "Güncellendi", user: updated });
    }
    catch (err) {
        return res.status(500).json({ message: "Sunucu hatası", error: err });
    }
};
exports.updateUser = updateUser;
const uploadProfileImage = async (req, res) => {
    upload(req, res, async (err) => {
        if (err instanceof multer_1.default.MulterError) {
            return res.status(400).json({ message: err.message });
        }
        else if (err) {
            return res.status(400).json({ message: err.message });
        }
        if (!req.file) {
            return res.status(400).json({ message: "No file uploaded" });
        }
        const userId = req.body.userId;
        if (!userId) {
            return res.status(400).json({ message: "User ID is required" });
        }
        try {
            // Delete old profile image if exists
            const user = await prisma.user.findUnique({
                where: { id: userId },
                select: { profileImage: true },
            });
            if (user === null || user === void 0 ? void 0 : user.profileImage) {
                const oldImagePath = path_1.default.join(__dirname, "../../uploads", path_1.default.basename(user.profileImage));
                if (fs_1.default.existsSync(oldImagePath)) {
                    fs_1.default.unlinkSync(oldImagePath);
                }
            }
            // Update user profile image in database
            const imageUrl = `/uploads/${req.file.filename}`;
            await prisma.user.update({
                where: { id: userId },
                data: { profileImage: imageUrl },
            });
            res.status(200).json({
                message: "Profile image uploaded successfully",
                imageUrl: imageUrl,
            });
        }
        catch (error) {
            res.status(500).json({ message: "Error uploading profile image", error });
        }
    });
};
exports.uploadProfileImage = uploadProfileImage;
