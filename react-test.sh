#!/bin/bash

# Exit the script as soon as something fails.
set -e

# Color utility functions
colorBlue() { 
  echo -e "\033[36m$1\033[0m" 
}
colorGreen() { 
  echo -e "\033[92m$1\033[0m" 
}
colorRed() { 
  echo -e "\033[31m$1\033[0m" 
}

# Prompt for the project name and directory path where the project should be initialized
colorBlue "Project path"
read -r DIRECTORY_PATH

colorBlue "Project name"
read -r PROJECT_NAME

# Navigate to the specified directory or stay in the current one if no path is provided
if [[ -n "$DIRECTORY_PATH" ]]; then
  mkdir -p "$DIRECTORY_PATH"
  cd "$DIRECTORY_PATH"
fi

# Now pass the PROJECT_NAME directly to the Vite creation command
colorGreen "Creating Vite project named $PROJECT_NAME..."
pnpm create vite "$PROJECT_NAME" --template react-ts

# Now navigate into the project directory
cd "$PROJECT_NAME"


# Install Vite plugin for React with SWC for fast refresh
colorGreen "Installing Vite plugin for React with SWC..."
pnpm add -D @vitejs/plugin-react-swc

# Install dev dependencies
colorGreen "Installing other development dependencies..."
pnpm add -D vitest @vitest/coverage-v8 @vitest/ui @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom concurrently prettier eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint-plugin-react eslint-plugin-prettier eslint-config-prettier install prettier-plugin-tailwindcss
  
colorGreen "Installing Tailwind"
pnpm install -D tailwindcss postcss autoprefixer   

cat <<EOF > postcss.config.js
/** @type {import('postcss-load-config').Config} */
const config = {
  plugins: {
    tailwindcss: {},
  },
}

export default config
EOF

cat <<EOF > tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      spacing: {
        '33': '7rem',
      },
      borderRadius: {
        custom: '1.1rem', // Add your custom size here
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic':
          'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
      },
      screens: {
        sm: '700px', // This sets the 'sm' breakpoint to 500px
      },
    },
  },
  plugins: [],
  darkMode: 'class',
}
export default config
EOF

cat <<EOF > src/index.css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;

  color-scheme: light dark;
  color: rgba(255, 255, 255, 0.87);
  background-color: #242424;

  font-synthesis: none;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

a {
  font-weight: 500;
  color: #646cff;
  text-decoration: inherit;
}
a:hover {
  color: #535bf2;
}

body {
  margin: 0;
  display: flex;
  place-items: center;
  min-width: 320px;
  min-height: 100vh;
}

h1 {
  font-size: 3.2em;
  line-height: 1.1;
}

button {
  border-radius: 8px;
  border: 1px solid transparent;
  padding: 0.6em 1.2em;
  font-size: 1em;
  font-weight: 500;
  font-family: inherit;
  background-color: #1a1a1a;
  cursor: pointer;
  transition: border-color 0.25s;
}
button:hover {
  border-color: #646cff;
}
button:focus,
button:focus-visible {
  outline: 4px auto -webkit-focus-ring-color;
}

@media (prefers-color-scheme: light) {
  :root {
    color: #213547;
    background-color: #ffffff;
  }
  a:hover {
    color: #747bff;
  }
  button {
    background-color: #f9f9f9;
  }
}
EOF

node -e "
let pkg = require('./package.json');
pkg.type = 'module';
pkg.scripts = {
  dev: 'vite',
  build: 'vite build',
  test: 'vitest',
  'test:watch': 'vitest --watch',
  'test:coverage': 'vitest --coverage',
  'test:ui': 'vitest --ui',
  lint: 'eslint . --ext .js,.jsx,.ts,.tsx',
  'lint:fix': 'eslint . --ext .js,.jsx,.ts,.tsx --fix',
  'start:tdd': 'concurrently --prefix none \u0027pnpm run dev\u0027 \u0027pnpm run test:watch\u0027'
};
require('fs').writeFileSync('./package.json', JSON.stringify(pkg, null, 2));
"

# Create a Vite configuration file
cat <<EOF > vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@assets': resolve(__dirname, './src/assets'),
      '@hooks': resolve(__dirname, './src/hooks'),
      '@components': resolve(__dirname, './src/components')
    }
  },
  server: {
    open: true, // Automatically opens the default browser
    port: 3000
  },
  plugins: [react()],
  // ...other configurations
})
EOF

# Create ESLint configuration file
cat <<EOF > .eslintrc.json
{
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    },
    "ecmaVersion": 2020,
    "sourceType": "module"
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  },
  "rules": {
    "prettier/prettier": ["error"]
  },
  "env": {
    "browser": true,
    "es2021": true
  }
}
EOF

# Create Prettier configuration file
cat <<EOF > .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "plugins": ["prettier-plugin-tailwindcss"]
}
EOF

# Create a setupTest global file
cat <<EOF > setupTests.ts
import { afterAll, beforeAll, beforeEach } from 'vitest';
import { expect } from 'vitest';
import matchers from '@testing-library/jest-dom/matchers';

expect.extend(matchers);

beforeAll(() => {
  // @ts-expect-error type
  globalThis.something = 'something';
});

beforeAll(async () => {
  await new Promise((resolve) => {
    setTimeout(() => {
      resolve(null);
    }, 300);
  });
});

beforeEach(async () => {
  await new Promise((resolve) => {
    setTimeout(() => {
      resolve(null);
    }, 10);
  });
});

afterAll(() => {
  // @ts-expect-error type
  delete globalThis.something;
});

afterAll(async () => {
  await new Promise((resolve) => {
    setTimeout(() => {
      resolve(null);
    }, 500);
  });
});

EOF


# Change tsconfig.json to include the setupTests file
cat <<EOF > tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "baseUrl": ".",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@assets/*": ["src/assets/*"],
      "@hooks/*": ["src/hooks/*"]
    },
  },
  "include": ["./", "setupTests.ts"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

# Create a Vitest configuration file as a TypeScript module
cat <<EOF > vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./setupTests.ts'],
    include: ['**/*.{test,spec}.{js,jsx,ts,tsx}'],
    exclude: [
      '**/node_modules/**',
      '**/dist/**',
      '**/cypress/**',
      '**/.{idea,git,cache,output,temp}/**',
      '**/{karma,rollup,webpack,vite,vitest,jest,ava,babel,nyc,cypress,tsup,build,eslint,prettier}.config.*',
    ],
    reporters: 'verbose',
    watchExclude: ['**/node_modules/**', '**/dist/**'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      all: true,
      include: ['src/**/*.ts', 'src/**/*.tsx'],
      exclude: [
        '**/*.test.ts',
        '**/*.spec.ts',
        '**/*.test.tsx',
        '**/*.spec.tsx',
      ],
    },
  }
})
EOF

# Output success message
colorBlue "Project setup complete! 👍 cd $DIRECTORY_PATH/$PROJECT_NAME\n"
colorGreen "Dev ➜ pnpm dev\nTest ➜ pnpm test" 
