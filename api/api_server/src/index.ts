import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import path from "path";
import authRoutes from "./auth.routes";
import recipeRoutes from "./recipes.routes";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(
  cors({
    origin: "*",
    credentials: true,
  })
);
app.use(express.json());

// Serve static files from the uploads directory
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));
app.use("/api/recipes", recipeRoutes);
app.use("/api/auth", authRoutes);

app.get("/", (req, res) => {
  res.send("BeanSocial API çalışıyor!");
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
