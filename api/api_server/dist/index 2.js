"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const express_1 = __importDefault(require("express"));
const path_1 = __importDefault(require("path"));
const auth_routes_1 = __importDefault(require("./auth.routes"));
const users_routes_1 = __importDefault(require("./users.routes"));
// import recipesRoutes from "./recipes.routes"; // Bu satırı tamamen YORUMA ALIN
console.log("Log 1: Starting server setup...");
dotenv_1.default.config();
console.log("Log 2: dotenv.config() called.");
const app = (0, express_1.default)();
console.log("Log 3: Express app created.");
console.log("Log 4: Adding cors middleware...");
app.use((0, cors_1.default)({
    origin: "*",
    credentials: true,
}));
console.log("Log 5: cors middleware added.");
console.log("Log 6: Adding express.json middleware...");
app.use(express_1.default.json());
console.log("Log 7: express.json middleware added.");
// Serve static files from the uploads directory
console.log("Log 8: Adding express.static middleware for /uploads...");
app.use("/uploads", express_1.default.static(path_1.default.join(__dirname, "../uploads")));
console.log("Log 9: express.static middleware added for /uploads.");
console.log("Log 10: Adding auth routes...");
app.use("/api/auth", auth_routes_1.default);
console.log("Log 11: auth routes added.");
console.log("Adding users routes...");
app.use("/api/users", users_routes_1.default);
console.log("users routes added.");
// console.log("Log 12: Adding recipes routes..."); // Log 12 (app.use satırı zaten yorumdaydı, bu log da görünmeyecek)
// app.use("/api/recipes", recipesRoutes); // Bu satır yorumda kalacak
// console.log("Log 13: recipes routes added."); // Log 13 (bu log da görünmeyecek)
console.log("Log 14: Defining root endpoint...");
app.get("/", (req, res) => {
    res.send("BeanSocial API çalışıyor!");
});
console.log("Log 15: Root endpoint added.");
console.log("Log 16: Getting PORT from environment variables...");
const PORT = process.env.PORT || 3000;
console.log(`Log 17: Attempting to listen on port ${PORT}`);
app.listen(PORT, () => {
    console.log(`Log 18: Server is running on port ${PORT}`);
});
console.log("Log 19: app.listen called. Waiting for server to start...");
