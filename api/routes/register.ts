import { Request, Response } from "express";
import { Database } from "../config/db";
import { eq } from "drizzle-orm";
import { NewUser, users } from "../database/schemas";
import bcrypt from "bcrypt";
import { createToken } from "../jwt";
import { validateRequired } from "../util";

export const register =
  (db: Database) =>
  async (req: Request, res: Response): Promise<any> => {
    const validationResult = validateRequired(
      [
        { key: "username", name: "nombre de usuario" },
        { key: "password", name: "contraseña" },
      ],
      req.body as NewUser
    );

    if (Array.isArray(validationResult)) {
      return res.status(400).json({
        status: "error",
        errors: validationResult,
      });
    }

    const { username, password } = validationResult;

    const user = await db.query.users.findFirst({
      where: eq(users.username, username),
    });

    if (user) {
      return res.status(400).json({
        status: "error",
        errors: ["Un usuario con ese nombre de usuario ya existe"],
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = await db
      .insert(users)
      .values({
        username,
        password: hashedPassword,
      })
      .returning();

    const token = await createToken(newUser[0].username);

    return res.status(201).json({
      status: "success",
      data: {
        accessToken: token,
        username: newUser[0].username,
        id: newUser[0].id,
      },
    });
  };
