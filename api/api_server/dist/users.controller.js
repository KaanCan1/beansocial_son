"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.uploadProfileImage = exports.updateUser = exports.getUser = void 0;
const client_1 = require("@prisma/client");
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const prisma = new client_1.PrismaClient();
const getUser = async (req, res) => {
    try {
        const userId = req.params.userId;
        const user = await prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                name: true,
                email: true,
                username: true,
                profileImage: true,
            },
        });
        if (!user) {
            return res.status(404).json({ message: "Kullanıcı bulunamadı" });
        }
        res.json(user);
    }
    catch (error) {
        console.error("Get user error:", error);
        res.status(500).json({ message: "Sunucu hatası" });
    }
};
exports.getUser = getUser;
const updateUser = async (req, res) => {
    try {
        const userId = req.params.userId;
        const { name, email, username } = req.body;
        // Kullanıcının mevcut olup olmadığını kontrol et
        const existingUser = await prisma.user.findUnique({
            where: { id: userId },
        });
        if (!existingUser) {
            return res.status(404).json({ message: "Kullanıcı bulunamadı" });
        }
        // Email veya kullanıcı adı başka bir kullanıcı tarafından kullanılıyor mu kontrol et
        const duplicateCheck = await prisma.user.findFirst({
            where: {
                OR: [
                    { email, id: { not: userId } },
                    { username, id: { not: userId } },
                ],
            },
        });
        if (duplicateCheck) {
            return res.status(400).json({
                message: "Bu email veya kullanıcı adı başka bir kullanıcı tarafından kullanılıyor",
            });
        }
        // Kullanıcıyı güncelle
        const updatedUser = await prisma.user.update({
            where: { id: userId },
            data: {
                name,
                email,
                username,
            },
            select: {
                id: true,
                name: true,
                email: true,
                username: true,
                profileImage: true,
            },
        });
        res.json({ user: updatedUser });
    }
    catch (error) {
        console.error("Update user error:", error);
        res.status(500).json({ message: "Sunucu hatası" });
    }
};
exports.updateUser = updateUser;
const uploadProfileImage = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: "Dosya yüklenmedi" });
        }
        const userId = req.user.id;
        const imageUrl = `/uploads/profiles/${req.file.filename}`;
        // Kullanıcının eski profil resmini sil
        const user = await prisma.user.findUnique({
            where: { id: userId },
            select: { profileImage: true },
        });
        if (user === null || user === void 0 ? void 0 : user.profileImage) {
            const oldImagePath = path_1.default.join(__dirname, "..", user.profileImage);
            if (fs_1.default.existsSync(oldImagePath)) {
                fs_1.default.unlinkSync(oldImagePath);
            }
        }
        // Yeni profil resmini kaydet
        await prisma.user.update({
            where: { id: userId },
            data: { profileImage: imageUrl },
        });
        res.json({ imageUrl });
    }
    catch (error) {
        console.error("Upload profile image error:", error);
        res.status(500).json({ message: "Sunucu hatası" });
    }
};
exports.uploadProfileImage = uploadProfileImage;
