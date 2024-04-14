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

# Create a .nvmrc file with the desired Node version
colorGreen "Creating .nvmrc file with Node..."
echo "v20.9.0" > .nvmrc

# Install Vite plugin for React with SWC for fast refresh
colorGreen "Installing Vite plugin for React with SWC..."
pnpm add -D @vitejs/plugin-react-swc

# Install the correct version of ESLint and related plugins
colorGreen "Installing the correct version of ESLint and related plugins..."
pnpm add -D eslint@8.56.0 @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint-plugin-react


# Install other dependencies
colorGreen "Installing other development dependencies..."
pnpm add -D vitest @vitest/ui @types/jest @testing-library/react @testing-library/jest-dom @testing-library/user-event ts-jest jsdom concurrently prettier eslint-plugin-prettier eslint-config-prettier

# Adding scripts to package.json for TDD and testing using the correct jq syntax
# Modify the package.json to add additional scripts
jq '.scripts.dev = "vite" |
  .scripts.build = "vite build" |
  .scripts.test = "vitest" |
  .scripts["test:watch"] = "vitest watch" |
  .scripts["test:coverage"] = "vitest coverage" |
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
    // ... other configurations
  }
})
EOF

# Output success message
colorBlue "Project setup complete! 👍  'cd $DIRECTORY_PATH$PROJECT_NAME' 'pnpm run start:tdd"
