import { integer, pgTable, serial, text } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: text("username").notNull(),
  password: text("password").notNull(),
});

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;

export const pokemon = pgTable("pokemon", {
  pokemonId: integer("pokemon_id").notNull(),
  userId: integer("user_id").notNull(),
});

export type Pokemon = typeof pokemon.$inferSelect;
export type NewPokemon = typeof pokemon.$inferInsert;
