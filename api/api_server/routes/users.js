const express = require("express");
const router = express.Router();
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const { authenticateToken } = require("../middleware/auth");

// 📁 Upload klasörünü oluştur
const uploadDir =
  "/Users/kaancankurt/Desktop/Bitirme Projesi/kod_bitirme/beansocial/api/api_server/uploads";
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// 📷 Multer konfigürasyonu
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, "profile-" + uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ["image/jpeg", "image/png", "image/gif", "image/webp"];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(
        new Error(
          "Desteklenmeyen dosya türü. Sadece JPEG, PNG, GIF ve WEBP kabul edilir."
        ),
        false
      );
    }
  },
});

// 📤 Profil fotoğrafı yükleme endpoint'i
router.post(
  "/upload-profile-image",
  authenticateToken,
  upload.single("image"),
  async (req, res) => {
    try {
      const userId = req.user.id;
      let imageUrl = null;

      // Web'den base64 ile gelirse
      if (req.body.imageData) {
        // Base64 prefix'ini kaldır
        const base64Data = req.body.imageData.replace(
          /^data:image\/\w+;base64,/,
          ""
        );
        const fileName = `profile-${Date.now()}-${Math.round(
          Math.random() * 1e9
        )}.jpg`;
        const filePath = path.join(uploadDir, fileName);
        fs.writeFileSync(filePath, base64Data, { encoding: "base64" });
        imageUrl = `/uploads/${fileName}`;
      } else if (req.file) {
        imageUrl = `/uploads/${req.file.filename}`;
      } else {
        return res.status(400).json({ error: "Dosya yüklenemedi" });
      }

      const user = await prisma.user.update({
        where: { id: userId },
        data: { profileImage: imageUrl },
      });

      res.json({
        imageUrl,
        message: "Profil fotoğrafı başarıyla güncellendi",
      });
    } catch (error) {
      console.error("Profil fotoğrafı yükleme hatası:", error);
      res
        .status(500)
        .json({ error: "Profil fotoğrafı yüklenirken bir hata oluştu" });
    }
  }
);

// 👤 Kullanıcı bilgilerini getir
router.get("/:userId", authenticateToken, async (req, res) => {
  try {
    const userId = req.params.userId;

    if (req.user.id !== userId) {
      return res.status(403).json({
        error: "Bu bilgilere erişim yetkiniz yok",
        details: "Token'daki kullanıcı ID'si ile istek yapılan ID eşleşmiyor",
      });
    }

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
      return res.status(404).json({ error: "Kullanıcı bulunamadı" });
    }

    res.json(user);
  } catch (error) {
    console.error("Error fetching user:", error);
    res
      .status(500)
      .json({ error: "Kullanıcı bilgileri alınırken bir hata oluştu" });
  }
});

// ✏️ Kullanıcı bilgilerini güncelle
router.put("/:userId", authenticateToken, async (req, res) => {
  try {
    const { name, username, email } = req.body;
    const userId = req.params.userId;

    if (req.user.id !== userId) {
      return res.status(403).json({
        error: "Bu işlem için yetkiniz yok",
        details:
          "Token'daki kullanıcı ID'si ile güncellenmek istenen kullanıcı ID'si eşleşmiyor",
      });
    }

    // Email formatı kontrolü
    const emailRegExp = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
    if (email && !emailRegExp.test(email)) {
      return res.status(400).json({
        error: "Geçersiz email formatı",
        details: "Lütfen geçerli bir email adresi giriniz",
      });
    }

    // Email benzersizliği
    if (email) {
      const existingUserWithEmail = await prisma.user.findUnique({
        where: { email },
      });
      if (existingUserWithEmail && existingUserWithEmail.id !== userId) {
        return res.status(400).json({
          error: "Bu email adresi zaten kullanımda",
          details: "Lütfen başka bir email adresi deneyiniz",
        });
      }
    }

    // Username benzersizliği
    if (username) {
      const existingUserWithUsername = await prisma.user.findUnique({
        where: { username },
      });
      if (existingUserWithUsername && existingUserWithUsername.id !== userId) {
        return res.status(400).json({
          error: "Bu kullanıcı adı zaten kullanımda",
          details: "Lütfen başka bir kullanıcı adı deneyiniz",
        });
      }
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: { name, email, username },
      select: {
        id: true,
        name: true,
        email: true,
        username: true,
        profileImage: true,
      },
    });

    res.json({
      message: "Kullanıcı bilgileri başarıyla güncellendi",
      user: updatedUser,
    });
  } catch (error) {
    console.error("Error updating user:", error);
    res.status(500).json({
      error: "Kullanıcı bilgileri güncellenirken bir hata oluştu",
      details: error.message,
    });
  }
});

module.exports = router;
