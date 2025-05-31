"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAllRecipes = exports.deleteRecipe = exports.createRecipe = exports.getUserRecipes = exports.upload = void 0;
const client_1 = require("@prisma/client");
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const prisma = new client_1.PrismaClient();
const storage = multer_1.default.diskStorage({
    destination: function (req, file, cb) {
        cb(null, path_1.default.join(__dirname, "../uploads/recipes"));
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + "-" + file.originalname);
    },
});
exports.upload = (0, multer_1.default)({ storage: storage });
const getUserRecipes = async (req, res) => {
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
        return res.status(200).json(recipes);
    }
    catch (err) {
        return res.status(500).json({ message: "Sunucu hatası", error: err });
    }
};
exports.getUserRecipes = getUserRecipes;
const createRecipe = async (req, res) => {
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
    }
    catch (err) {
        return res.status(500).json({ message: "Sunucu hatası", error: err });
    }
};
exports.createRecipe = createRecipe;
const deleteRecipe = async (req, res) => {
    const { recipeId } = req.params;
    try {
        await prisma.coffeeRecipe.delete({ where: { id: recipeId } });
        return res.status(200).json({ message: "Tarif silindi" });
    }
    catch (err) {
        return res.status(500).json({ message: "Sunucu hatası", error: err });
    }
};
exports.deleteRecipe = deleteRecipe;
const getAllRecipes = async (req, res) => {
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
    }
    catch (err) {
        return res.status(500).json({ message: "Sunucu hatası", error: err });
    }
};
exports.getAllRecipes = getAllRecipes;
