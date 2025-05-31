import { PrismaClient } from "@prisma/client";
import { Request, Response } from "express";
import fs from "fs";
import path from "path";

const prisma = new PrismaClient();

export const getUser = async (req: Request, res: Response) => {
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
  } catch (error) {
    console.error("Get user error:", error);
    res.status(500).json({ message: "Sunucu hatası" });
  }
};

export const updateUser = async (req: Request, res: Response) => {
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
        message:
          "Bu email veya kullanıcı adı başka bir kullanıcı tarafından kullanılıyor",
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
  } catch (error) {
    console.error("Update user error:", error);
    res.status(500).json({ message: "Sunucu hatası" });
  }
};

export const uploadProfileImage = async (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "Dosya yüklenmedi" });
    }

    const userId = (req as any).user.id;
    const imageUrl = `/uploads/profiles/${req.file.filename}`;

    // Kullanıcının eski profil resmini sil
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { profileImage: true },
    });

    if (user?.profileImage) {
      const oldImagePath = path.join(__dirname, "..", user.profileImage);
      if (fs.existsSync(oldImagePath)) {
        fs.unlinkSync(oldImagePath);
      }
    }

    // Yeni profil resmini kaydet
    await prisma.user.update({
      where: { id: userId },
      data: { profileImage: imageUrl },
    });

    res.json({ imageUrl });
  } catch (error) {
    console.error("Upload profile image error:", error);
    res.status(500).json({ message: "Sunucu hatası" });
  }
};
