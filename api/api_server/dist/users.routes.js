"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const auth_1 = require("./middleware/auth");
const users_controller_1 = require("./users.controller");
const storage = multer_1.default.diskStorage({
    destination: function (req, file, cb) {
        cb(null, path_1.default.join(__dirname, "../uploads/profiles"));
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + "-" + file.originalname);
    },
});
const upload = (0, multer_1.default)({ storage: storage });
const router = express_1.default.Router();
router.get("/:userId", auth_1.authenticateToken, users_controller_1.getUser);
router.put("/:userId", auth_1.authenticateToken, users_controller_1.updateUser);
router.post("/upload-profile-image", auth_1.authenticateToken, upload.single("image"), users_controller_1.uploadProfileImage);
exports.default = router;
