import { Response, Request } from "express";
import { Database } from "../config/db";
import { validateRequired } from "../util";
import { NewUser, users } from "../database/schemas";
import { eq } from "drizzle-orm";
import bcrypt from "bcrypt";
import { createToken } from "../jwt";

export const login =
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

    if (!user) {
      return res.status(404).json({
        status: "error",
        errors: ["El usuario no se encuentra registrado"],
      });
    }

    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({
        status: "error",
        errors: ["El usuario o la contraseña son incorrectos"],
      });
    }

    const token = await createToken(user.username);

    return res.status(200).json({
      status: "success",
      data: {
        accessToken: token,
        username: user.username,
        id: user.id,
      },
    });
  };
