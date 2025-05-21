import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";
import { Request, Response } from "express";
import fs from "fs";
import jwt from "jsonwebtoken";
import multer from "multer";
import path from "path";

const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || "default_secret";

// Configure multer for image upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, "../../uploads");
    // Create uploads directory if it doesn't exist
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, "profile-" + uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ["image/jpeg", "image/png", "image/gif", "image/jpg"];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error("Invalid file type. Only JPEG, PNG and GIF are allowed."));
    }
  },
}).single("image");

export const signup = async (req: Request, res: Response) => {
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
    const hashedPassword = await bcrypt.hash(password, 10);
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
  } catch (err) {
    return res.status(500).json({ message: "Sunucu hatası", error: err });
  }
};

export const login = async (req: Request, res: Response) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: "Email ve şifre zorunlu." });
  }
  try {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      return res.status(400).json({ message: "Kullanıcı bulunamadı." });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Şifre yanlış." });
    }
    const token = jwt.sign({ userId: user.id, email: user.email }, JWT_SECRET, {
      expiresIn: "7d",
    });
    return res.status(200).json({
      message: "Giriş başarılı",
      token,
      user: { id: user.id, email: user.email, name: user.name },
    });
  } catch (err) {
    return res.status(500).json({ message: "Sunucu hatası", error: err });
  }
};

export const getAllUsers = async (req: Request, res: Response) => {
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
  } catch (err) {
    return res.status(500).json({ message: "Sunucu hatası", error: err });
  }
};

export const getUserById = async (req: Request, res: Response) => {
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
    if (!user) return res.status(404).json({ message: "Kullanıcı bulunamadı" });
    return res.status(200).json(user);
  } catch (err) {
    return res.status(500).json({ message: "Sunucu hatası", error: err });
  }
};

export const updateUser = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { name, email, profileImage, bio } = req.body;
  try {
    const updated = await prisma.user.update({
      where: { id },
      data: { name, email, profileImage, bio },
    });
    return res.status(200).json({ message: "Güncellendi", user: updated });
  } catch (err) {
    return res.status(500).json({ message: "Sunucu hatası", error: err });
  }
};

export const uploadProfileImage = async (req: Request, res: Response) => {
  upload(req, res, async (err) => {
    if (err instanceof multer.MulterError) {
      return res.status(400).json({ message: err.message });
    } else if (err) {
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

      if (user?.profileImage) {
        const oldImagePath = path.join(
          __dirname,
          "../../uploads",
          path.basename(user.profileImage)
        );
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath);
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
    } catch (error) {
      res.status(500).json({ message: "Error uploading profile image", error });
    }
  });
};
