import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import path from "path";
import authRoutes from "./auth.routes";
import usersRoutes from "./users.routes";
// import recipesRoutes from "./recipes.routes"; // Bu satırı tamamen YORUMA ALIN

console.log("Log 1: Starting server setup...");

dotenv.config();
console.log("Log 2: dotenv.config() called.");

const app = express();
console.log("Log 3: Express app created.");

console.log("Log 4: Adding cors middleware...");
app.use(
  cors({
    origin: "*",
    credentials: true,
  })
);
console.log("Log 5: cors middleware added.");

console.log("Log 6: Adding express.json middleware...");
app.use(express.json());
console.log("Log 7: express.json middleware added.");

// Serve static files from the uploads directory
console.log("Log 8: Adding express.static middleware for /uploads...");
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));
console.log("Log 9: express.static middleware added for /uploads.");

console.log("Log 10: Adding auth routes...");
app.use("/api/auth", authRoutes);
console.log("Log 11: auth routes added.");

console.log("Adding users routes...");
app.use("/api/users", usersRoutes);
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
