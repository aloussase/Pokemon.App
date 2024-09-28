export const validateRequired = <
  TKeys extends string[],
  TData extends Record<TKeys[number], any>
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
