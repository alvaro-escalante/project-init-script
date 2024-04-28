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
pnpm add -D vitest @vitest/coverage-v8 @vitest/ui @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom concurrently prettier eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint-plugin-react eslint-plugin-prettier eslint-config-prettier

pnpm add -D cypress    
  
pnpm install -D tailwindcss postcss autoprefixer   

pnpm dlx tailwindcss init -p

# Adding scripts to package.json for TDD and testing using the correct jq syntax
# Modify the package.json to add additional scripts
jq '.scripts.dev = "vite" |
  .scripts.build = "vite build" |
  .scripts["cypress:open"] = "cypress open" |
  .scripts["cypress:run"] = "cypress run" |
  .scripts.test = "vitest" |
  .scripts["test:watch"] = "vitest --watch" |
  .scripts["test:coverage"] = "vitest --coverage" |
  .scripts["test:ui"] = "vitest --ui" |
  .scripts.lint = "eslint . --ext .js,.jsx,.ts,.tsx" |
  .scripts["lint:fix"] = "eslint . --ext .js,.jsx,.ts,.tsx --fix" |
  .scripts["start:tdd"] = "concurrently --prefix none \u0027pnpm run dev\u0027 \u0027pnpm run test:watch\u0027"' package.json > package.json.tmp && mv package.json.tmp package.json

# Create a Vite configuration file
cat <<EOF > vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
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
  "semi": false,
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2
}
EOF

# Create a Jest setup file to configure additional matchers
echo "import '@testing-library/jest-dom';" > src/setupTests.ts

# Create a Vitest configuration file as a TypeScript module
cat <<EOF > vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/setupTests.ts'],
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
colorGreen "Dev ➜ pnpm dev\nTest ➜ pnpm test\nTDD ➜ pnpm start:tdd\n" 
