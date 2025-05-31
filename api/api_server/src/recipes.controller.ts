import { PrismaClient } from "@prisma/client";
import { Request, Response } from "express";
import multer from "multer";
import path from "path";

const prisma = new PrismaClient();

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, "../uploads/recipes"));
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

export const upload = multer({ storage: storage });

export const getUserRecipes = async (req: Request, res: Response) => {
  const { userId } = req.params;
  try {
    const recipes = await prisma.coffeeRecipe.findMany({
      where: { authorId: userId },
      orderBy: { createdAt: "desc" },
      include: {
        author: {
          select: {
            name: true,
            username: true,
            profileImage: true,
          },
        },
      },
    });
    return res.status(200).json({
      success: true,
      message: "Tarifler başarıyla getirildi",
      recipes,
    });
  } catch (error) {
    console.error("getUserRecipes error:", error);
    res.status(500).json({
      success: false,
      message: "Sunucu hatası",
      error: error instanceof Error ? error.message : error,
    });
  }
};

export const createRecipe = async (req: Request, res: Response) => {
  const { name, type, description, parameters, authorId } = req.body;
  try {
    const imageUrl = req.file ? `/uploads/recipes/${req.file.filename}` : null;

    const recipe = await prisma.coffeeRecipe.create({
      data: {
        name,
        type,
        description,
        parameters,
        authorId,
        imageUrl,
      },
      include: {
        author: {
          select: {
            name: true,
            username: true,
            profileImage: true,
          },
        },
      },
    });
    return res.status(201).json(recipe);
  } catch (err) {
    return res.status(500).json({ message: "Sunucu hatası", error: err });
  }
};

export const deleteRecipe = async (req: Request, res: Response) => {
  const { recipeId } = req.params;
  try {
    await prisma.coffeeRecipe.delete({ where: { id: recipeId } });
    return res.status(200).json({ message: "Tarif silindi" });
  } catch (err) {
    return res.status(500).json({ message: "Sunucu hatası", error: err });
  }
};

export const getAllRecipes = async (req: Request, res: Response) => {
  try {
    const recipes = await prisma.coffeeRecipe.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        author: {
          select: {
            name: true,
            username: true,
            profileImage: true,
          },
        },
      },
    });
    return res.status(200).json(recipes);
  } catch (err) {
    return res.status(500).json({ message: "Sunucu hatası", error: err });
  }
};
