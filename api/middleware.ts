import { NextFunction, Request, Response } from "express";
import { verifyToken } from "./jwt";

export const protect = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<any> => {
  const authHeader = req.header("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return res.status(401).json({
      status: "error",
      errors: ["No se encontró el token de autenticación"],
    });
  }

  const token = authHeader.split("Bearer ")[1];
  const result = await verifyToken(token);

  if (result === null) {
    return res.status(401).json({
      status: "error",
      errors: ["El token de autenticación es inválido"],
    });
  }

  const { username } = result;
  req.username = username;

  next();
};
