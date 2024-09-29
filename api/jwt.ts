import jwt from "jsonwebtoken";

const secret = process.env.TOKEN_SECRET;

if (!secret) {
  throw Error("TOKEN_SECRET is not set!");
}

export const createToken = async <TData extends Record<string, any>>(
  username: string,
  data: TData | null = null
): Promise<string> => {
  return jwt.sign(data ?? {}, secret, {
    expiresIn: "1h",
    subject: username,
  });
};

export const verifyToken = async <TData>(
  token: string
): Promise<{ username: string } | null> => {
  try {
    const result = jwt.verify(token, secret);
    if (result instanceof String) {
      return null;
    }
    return { username: result.sub as string };
  } catch {
    return null;
  }
};
