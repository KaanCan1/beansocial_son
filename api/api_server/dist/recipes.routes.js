"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const recipes_controller_1 = require("./recipes.controller");
const router = express_1.default.Router();
router.get("/all", recipes_controller_1.getAllRecipes);
router.get("/user/:userId", recipes_controller_1.getUserRecipes);
router.post("/create", recipes_controller_1.upload.single("image"), recipes_controller_1.createRecipe);
router.delete("/:recipeId", recipes_controller_1.deleteRecipe);
exports.default = router;
