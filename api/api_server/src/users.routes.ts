import express from "express";
import multer from "multer";
import path from "path";
import { getUser, updateUser, uploadProfileImage } from "./users.controller";

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, "../uploads/profiles"));
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

const upload = multer({ storage: storage });

const router = express.Router();

router.get("/:userId", getUser);
router.put("/:userId", updateUser);
router.post(
  "/upload-profile-image",
  upload.single("image"),
  uploadProfileImage
);

export default router;
