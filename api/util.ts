export const validateRequired = <
  TData extends Record<string, any>,
  TKeys extends readonly (keyof TData)[]
>(
  keys: { key: TKeys[number]; name: string }[],
  data: TData
): string[] | TData => {
  const errors = [] as string[];
  for (let key of keys) {
    if (!(key.key in data)) {
      errors.push(`${key.name} es obligatorio`);
    }
  }
  if (errors.length > 0) {
    return errors;
  }
  return data;
};
