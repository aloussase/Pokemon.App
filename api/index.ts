import { config } from "dotenv";
config();

import express from "express";
import { createDb } from "./config/db";
import { register } from "./routes/register";
import { login } from "./routes/login";
import { savePokemon } from "./routes/save-pokemon";
import { protect } from "./middleware";
import { getPokemon } from "./routes/get-pokemon";

(async function main() {
  const db = await createDb();
  const app = express();

  app.use(express.json());

  app.post("/api/register", register(db));
  app.post("/api/login", login(db));
  app.post("/api/pokemon", protect, savePokemon(db));
  app.get("/api/pokemon", protect, getPokemon(db));

  const port = process.env.PORT || 3000;

  app.listen(port, () =>
    console.table({
      port,
    })
  );
})();
