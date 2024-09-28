import { Request, Response } from "express";
import { Database } from "../config/db";
import { pokemon, users } from "../database/schemas";
import { eq } from "drizzle-orm";

export const getPokemon =
  (db: Database) =>
  async (req: Request, res: Response): Promise<any> => {
    const pkmn = await db
      .select({
        id: pokemon.id,
        name: pokemon.name,
        imageUrl: pokemon.imageUrl,
        types: pokemon.types,
      })
      .from(users)
      .innerJoin(pokemon, eq(users.id, pokemon.userId))
      .where(eq(users.username, req.username!));
    return res.status(200).json({
      status: "success",
      data: pkmn,
    });
  };
