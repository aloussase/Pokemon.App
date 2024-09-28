import { Request, Response } from "express";
import { Database } from "../config/db";
import { pokemon, users } from "../database/schemas";
import { validateRequired } from "../util";
import { eq } from "drizzle-orm";

export const savePokemon =
  (db: Database) =>
  async (req: Request, res: Response): Promise<any> => {
    const validationResult = validateRequired(
      [{ key: "pokemonId", name: "id del Pokemon" }],
      req.body as { pokemonId: number }
    );

    if (Array.isArray(validationResult)) {
      return res.status(400).json({
        status: "error",
        errors: validationResult,
      });
    }

    const { pokemonId } = validationResult;

    const user = await db.query.users.findFirst({
      where: eq(users.username, req.username!),
    });

    const response = await fetch(
      `https://pokeapi.co/api/v2/pokemon/${pokemonId}/`
    );

    if (!response.ok) {
      return res.status(response.status).json({
        status: "error",
        errors: ["Hubo un error al consultar la API de Pokemon"],
      });
    }

    let {
      name,
      types,
      sprites: {
        other: {
          "official-artwork": { front_default: imageUrl },
        },
      },
    } = await response.json();

    types = types.map((type: any) => type.type.name).join(", ");

    const newPokemon = await db
      .insert(pokemon)
      .values({ id: pokemonId, userId: user!.id, imageUrl, types, name })
      .returning();

    return res.status(201).json({
      status: "success",
      data: { ...newPokemon[0] },
    });
  };
