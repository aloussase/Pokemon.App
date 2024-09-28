import { Request, Response } from "express";
import { Database } from "../config/db";

export const getPokemon =
  (db: Database) =>
  async (req: Request, res: Response): Promise<any> => {
    return null;
  };
