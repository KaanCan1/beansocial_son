const express = require("express");
const router = express.Router();
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
const bcrypt = require("bcryptjs");
const crypto = require("crypto");

// Bearer token'ları saklamak için bir Map
const tokenStore = new Map();

// Bearer token oluşturma fonksiyonu
function generateBearerToken(userId, email) {
  const randomBytes = crypto.randomBytes(32);
  const timestamp = Date.now().toString();
  const dataToHash = `${email}:${timestamp}:${randomBytes.toString("hex")}`;
  const hash = crypto
    .createHash("sha256")
    .update(dataToHash)
    .digest("base64url");
  const token = hash;

  // Token'ı sakla
  tokenStore.set(token, {
    userId,
    email,
    createdAt: new Date(),
    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 gün
  });

  return token;
}

// Token doğrulama middleware'i
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).json({ error: "Token gerekli" });
  }

  const tokenData = tokenStore.get(token);
  if (!tokenData) {
    return res.status(403).json({ error: "Geçersiz token" });
  }

  if (tokenData.expiresAt < new Date()) {
    tokenStore.delete(token);
    return res.status(401).json({ error: "Token süresi dolmuş" });
  }

  req.user = { id: tokenData.userId, email: tokenData.email };
  next();
};

// Kullanıcı girişi
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email ve şifre gerekli" });
    }

    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      return res.status(404).json({ error: "Kullanıcı bulunamadı" });
    }

    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: "Geçersiz şifre" });
    }

    const token = generateBearerToken(user.id, user.email);

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        username: user.username || "",
        name: user.name || "",
        profileImage: user.profileImage || "",
      },
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Giriş yapılırken bir hata oluştu" });
  }
});

// Çıkış yapma
router.post("/logout", async (req, res) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (token) {
    tokenStore.delete(token);
  }

  res.json({ message: "Başarıyla çıkış yapıldı" });
});

// Kullanıcı bilgilerini getir
router.get("/user/:userId", authenticateToken, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: {
        id: req.params.userId,
      },
      select: {
        id: true,
        name: true,
        email: true,
        username: true,
        profileImage: true,
        bio: true,
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

// Kullanıcı bilgilerini güncelle
router.put("/user/:userId", authenticateToken, async (req, res) => {
  try {
    const { name, email, username } = req.body;
    const userId = req.params.userId;

    // Kullanıcının kendi bilgilerini güncelleyip güncellemediğini kontrol et
    if (req.user.id !== userId) {
      return res.status(403).json({ error: "Bu işlem için yetkiniz yok" });
    }

    // Email ve kullanıcı adının benzersiz olduğunu kontrol et
    if (email) {
      const existingUserWithEmail = await prisma.user.findUnique({
        where: { email },
      });
      if (existingUserWithEmail && existingUserWithEmail.id !== userId) {
        return res
          .status(400)
          .json({ error: "Bu email adresi zaten kullanımda" });
      }
    }

    if (username) {
      const existingUserWithUsername = await prisma.user.findUnique({
        where: { username },
      });
      if (existingUserWithUsername && existingUserWithUsername.id !== userId) {
        return res
          .status(400)
          .json({ error: "Bu kullanıcı adı zaten kullanımda" });
      }
    }

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
        bio: true,
      },
    });

    res.json({
      message: "Kullanıcı bilgileri başarıyla güncellendi",
      user: updatedUser,
    });
  } catch (error) {
    console.error("Error updating user:", error);
    res
      .status(500)
      .json({ error: "Kullanıcı bilgileri güncellenirken bir hata oluştu" });
  }
});

// Kullanıcı bilgilerini güncelle (Bearer token ile)
router.put("/users", async (req, res) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      return res.status(401).json({ error: "Token gerekli" });
    }

    const tokenData = tokenStore.get(token);
    if (!tokenData) {
      return res.status(403).json({ error: "Geçersiz token" });
    }

    if (tokenData.expiresAt < new Date()) {
      tokenStore.delete(token);
      return res.status(401).json({ error: "Token süresi dolmuş" });
    }

    const { name, email, username } = req.body;
    const userId = tokenData.userId; // Token'dan kullanıcı ID'sini al

    // Email ve kullanıcı adının benzersiz olduğunu kontrol et
    if (email) {
      const existingUserWithEmail = await prisma.user.findUnique({
        where: { email },
      });
      if (existingUserWithEmail && existingUserWithEmail.id !== userId) {
        return res
          .status(400)
          .json({ error: "Bu email adresi zaten kullanımda" });
      }
    }

    if (username) {
      const existingUserWithUsername = await prisma.user.findUnique({
        where: { username },
      });
      if (existingUserWithUsername && existingUserWithUsername.id !== userId) {
        return res
          .status(400)
          .json({ error: "Bu kullanıcı adı zaten kullanımda" });
      }
    }

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

    res.json({
      message: "Kullanıcı bilgileri başarıyla güncellendi",
      user: updatedUser,
    });
  } catch (error) {
    console.error("Error updating user:", error);
    res
      .status(500)
      .json({ error: "Kullanıcı bilgileri güncellenirken bir hata oluştu" });
  }
});

module.exports = { router, tokenStore, generateBearerToken };
