const express = require("express");
const router = express.Router();
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Upload klasörünü oluştur
const uploadDir = path.join(__dirname, "../uploads/recipes");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Base64'ten dosyaya kaydetme fonksiyonu
function saveBase64Image(base64String) {
  try {
    // Base64 prefix'ini kaldır
    const base64Data = base64String.replace(/^data:image\/\w+;base64,/, "");

    // Rastgele dosya adı oluştur
    const fileName = `recipe-${Date.now()}-${Math.round(
      Math.random() * 1e9
    )}.jpg`;
    const filePath = path.join(uploadDir, fileName);

    // Dosyaya kaydet
    fs.writeFileSync(filePath, base64Data, { encoding: "base64" });

    return `/uploads/recipes/${fileName}`;
  } catch (error) {
    console.error("Error saving base64 image:", error);
    return null;
  }
}

// Multer konfigürasyonu
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, "recipe-" + uniqueSuffix + path.extname(file.originalname));
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

// Kullanıcının tariflerini getir
router.get("/user/:userId", async (req, res) => {
  try {
    console.log("Fetching recipes for user:", req.params.userId);
    const recipes = await prisma.coffeeRecipe.findMany({
      where: {
        authorId: req.params.userId,
      },
      include: {
        author: {
          select: {
            id: true,
            username: true,
            profileImage: true,
          },
        },
      },
      orderBy: {
        createdAt: "desc",
      },
    });
    console.log("Found recipes:", recipes);
    res.json({
      success: true,
      message: "Tarifler başarıyla getirildi",
      recipes,
    });
  } catch (error) {
    console.error("Error fetching user recipes:", error);
    res.status(500).json({
      success: false,
      message: "Tarifler alınırken bir hata oluştu",
      error: error.message,
    });
  }
});

// Yeni tarif oluştur
router.post("/", upload.single("image"), async (req, res) => {
  try {
    console.log("Creating new recipe with data:", req.body);
    const { name, type, description, parameters, authorId, imageData } =
      req.body;

    // Gerekli alanların kontrolü
    if (!name || !type || !description || !authorId) {
      return res.status(400).json({
        success: false,
        message: "Lütfen tüm gerekli alanları doldurun",
      });
    }

    // Parametrelerin kontrolü
    let parsedParameters;
    try {
      parsedParameters =
        typeof parameters === "string" ? JSON.parse(parameters) : parameters;
    } catch (error) {
      console.error("Parameter parsing error:", error);
      return res.status(400).json({
        success: false,
        message: "Geçersiz parametre formatı",
        error: error.message,
      });
    }

    // Resim işleme
    let imageUrl = null;
    try {
      if (req.file) {
        imageUrl = `/uploads/recipes/${req.file.filename}`;
      } else if (imageData) {
        imageUrl = saveBase64Image(imageData);
        if (!imageUrl) {
          throw new Error("Resim kaydedilemedi");
        }
      }
    } catch (error) {
      console.error("Image processing error:", error);
      return res.status(400).json({
        success: false,
        message: "Resim işlenirken bir hata oluştu",
        error: error.message,
      });
    }

    // Tarif oluşturma
    const recipe = await prisma.coffeeRecipe.create({
      data: {
        name,
        type,
        description,
        parameters: parsedParameters,
        authorId,
        imageUrl,
      },
      include: {
        author: {
          select: {
            username: true,
            profileImage: true,
          },
        },
      },
    });

    console.log("Created recipe:", recipe);
    res.status(201).json({
      success: true,
      message: "Tarif başarıyla oluşturuldu",
      recipe,
    });
  } catch (error) {
    console.error("Error creating recipe:", error);
    // Yüklenen dosyayı sil
    if (req.file) {
      fs.unlink(path.join(uploadDir, req.file.filename), (err) => {
        if (err) console.error("Error deleting file:", err);
      });
    }
    res.status(500).json({
      success: false,
      message: "Tarif oluşturulurken bir hata oluştu",
      error: error.message,
    });
  }
});

// Tarif güncelle
router.put("/:recipeId", upload.single("image"), async (req, res) => {
  try {
    const { name, type, description, parameters } = req.body;
    const recipeId = req.params.recipeId;

    // Tarifin var olup olmadığını kontrol et
    const existingRecipe = await prisma.coffeeRecipe.findUnique({
      where: { id: recipeId },
    });

    if (!existingRecipe) {
      return res.status(404).json({ error: "Tarif bulunamadı" });
    }

    // Parametrelerin kontrolü
    let parsedParameters;
    try {
      parsedParameters =
        typeof parameters === "string" ? JSON.parse(parameters) : parameters;
    } catch (error) {
      return res.status(400).json({ error: "Geçersiz parametre formatı" });
    }

    const updatedRecipe = await prisma.coffeeRecipe.update({
      where: { id: recipeId },
      data: {
        name,
        type,
        description,
        parameters: parsedParameters,
        imageUrl: req.file
          ? `/uploads/recipes/${req.file.filename}`
          : existingRecipe.imageUrl,
      },
      include: {
        author: {
          select: {
            username: true,
            profileImage: true,
          },
        },
      },
    });

    // Eski resmi sil
    if (req.file && existingRecipe.imageUrl) {
      const oldImagePath = path.join(__dirname, "..", existingRecipe.imageUrl);
      fs.unlink(oldImagePath, (err) => {
        if (err) console.error("Error deleting old image:", err);
      });
    }

    res.json({
      message: "Tarif başarıyla güncellendi",
      recipe: updatedRecipe,
    });
  } catch (error) {
    console.error("Error updating recipe:", error);
    if (req.file) {
      fs.unlink(path.join(uploadDir, req.file.filename), (err) => {
        if (err) console.error("Error deleting file:", err);
      });
    }
    res.status(500).json({ error: "Tarif güncellenirken bir hata oluştu" });
  }
});

// Tarif sil
router.delete("/:recipeId", async (req, res) => {
  try {
    const recipeId = req.params.recipeId;

    // Tarifin var olup olmadığını kontrol et
    const existingRecipe = await prisma.coffeeRecipe.findUnique({
      where: { id: recipeId },
    });

    if (!existingRecipe) {
      return res.status(404).json({ error: "Tarif bulunamadı" });
    }

    // Resmi sil
    if (existingRecipe.imageUrl) {
      const imagePath = path.join(__dirname, "..", existingRecipe.imageUrl);
      fs.unlink(imagePath, (err) => {
        if (err) console.error("Error deleting image:", err);
      });
    }

    await prisma.coffeeRecipe.delete({
      where: { id: recipeId },
    });

    res.json({ message: "Tarif başarıyla silindi" });
  } catch (error) {
    console.error("Error deleting recipe:", error);
    res.status(500).json({ error: "Tarif silinirken bir hata oluştu" });
  }
});

module.exports = router;
