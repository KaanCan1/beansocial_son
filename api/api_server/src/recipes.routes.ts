import express from "express";
import {
  createRecipe,
  deleteRecipe,
  getAllRecipes,
  getUserRecipes,
  upload,
} from "./recipes.controller";

const router = express.Router();

router.get("/all", getAllRecipes);
router.get("/user/:userId", getUserRecipes);
router.get("/", getAllRecipes);
router.post("/", upload.single("image"), createRecipe);
router.post("/create", upload.single("image"), createRecipe);
router.delete("/:recipeId", deleteRecipe);

export default router;
