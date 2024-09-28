import { Client } from "pg";
import { drizzle } from "drizzle-orm/node-postgres";
import * as schema from "../database/schemas";

export const createDb = async () => {
  const client = new Client({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
  });

  await client.connect();

  return drizzle(client, { schema });
};

export type Database = Awaited<ReturnType<typeof createDb>>;
