import { defineConfig } from 'eslint/config';
import nextPlugin from 'eslint-config-next';
import tseslint from 'typescript-eslint';

export default defineConfig([
  ...nextPlugin,
  ...tseslint.configs.recommended,
  {
    rules: {
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'warn',
    },
  },
]);