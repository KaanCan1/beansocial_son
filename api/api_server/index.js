const express = require("express");
const cors = require("cors");
const path = require("path");
const multer = require("multer");
const fs = require("fs");
const { PrismaClient } = require("@prisma/client");
const { authenticateToken } = require("./middleware/auth");
const app = express();
const prisma = new PrismaClient();

// CORS ayarları
app.use(cors());
app.use(express.json());

// Uploads klasörünü oluştur
const uploadDir = path.join(__dirname, "..", "uploads");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Uploads klasörünü statik dosya olarak sun
app.use("/uploads", express.static(uploadDir));
console.log("Uploads directory:", uploadDir);

// Multer konfigürasyonu
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
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ["image/jpeg", "image/png", "image/gif", "image/webp"];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(
        new Error(
          "Desteklenmeyen dosya türü. Sadece JPEG, PNG, GIF ve WEBP formatları kabul edilir."
        ),
        false
      );
    }
  },
});

// Route'ları içe aktar
const { router: authRoutes } = require("./routes/auth");
const userRoutes = require("./routes/users");
const recipeRoutes = require("./routes/recipes");

// Public route'lar (token gerektirmeyen)
app.use("/api/auth", authRoutes);

// Protected route'lar (token gerektiren)
app.use("/api/users", authenticateToken, userRoutes);
app.use("/api/recipes", recipeRoutes);

// Profil fotoğrafı yükleme endpoint'i
app.post(
  "/api/users/profile-image",
  authenticateToken,
  upload.single("image"),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: "Dosya yüklenemedi" });
      }

      const userId = req.user.id; // Token'dan gelen kullanıcı ID'sini kullan

      const imageUrl = `/uploads/${req.file.filename}`;
      console.log("Uploaded file:", req.file);
      console.log("Image URL:", imageUrl);
      console.log("Full path:", path.join(uploadDir, req.file.filename));

      const user = await prisma.user.update({
        where: { id: userId },
        data: { profileImage: imageUrl },
      });

      res.json({
        profileImage: imageUrl,
        message: "Profil fotoğrafı başarıyla güncellendi",
      });
    } catch (error) {
      console.error("Profil fotoğrafı yükleme hatası:", error);
      if (req.file) {
        // Hata durumunda yüklenen dosyayı sil
        fs.unlink(path.join(uploadDir, req.file.filename), (err) => {
          if (err) console.error("Dosya silinirken hata oluştu:", err);
        });
      }
      res
        .status(500)
        .json({ error: "Profil fotoğrafı yüklenirken bir hata oluştu" });
    }
  }
);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
