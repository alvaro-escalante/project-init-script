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



# Now pass the PROJECT_NAME directly to the Next.js creation command
colorGreen "Creating Next.js project named $PROJECT_NAME..."
yes '' | pnpm dlx create-next-app@latest "$PROJECT_NAME" --ts --eslint --tailwind --app --use-pnpm --src-dir

# Now navigate into the project directory
cd "$PROJECT_NAME"

# Create additional folders
mkdir -p src/app/api
mkdir -p src/lib
mkdir -p src/components

# Install Other needed packages
colorGreen "Installing basic packages for Next.js"
pnpm add clsx framer-motion sharp react-icons 


# Create ESLint configuration file
cat <<EOF > .eslintrc.json
{
  "extends": [
    "next/core-web-vitals",
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

# Output success message
colorBlue "Project setup complete! 👍 cd $DIRECTORY_PATH/$PROJECT_NAME\n"
colorGreen "pnpm dev" 

