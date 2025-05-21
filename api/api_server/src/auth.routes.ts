import { Router } from "express";
import {
  getAllUsers,
  getUserById,
  login,
  signup,
  updateUser,
  uploadProfileImage,
} from "./auth.controller";

const router = Router();

router.post("/signup", signup);
router.post("/login", login);
router.get("/users", getAllUsers);
router.get("/user/:id", getUserById);
router.put("/user/:id", updateUser);
router.post("/upload-profile-image", uploadProfileImage);

export default router;
