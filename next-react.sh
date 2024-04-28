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
yes "No" | pnpm dlx create-next-app@latest "$PROJECT_NAME" --ts --eslint --tailwind --app --use-pnpm

# Now navigate into the project directory
cd "$PROJECT_NAME"

# Install Other needed packages
colorGreen "Installing basic packages for Next.js"
pnpm add clsx framer-motion sharp react-icons react-intersection-observer

# Install Jest and React Testing Library
colorGreen "Installing Testing plugins for Next.js"
pnpm add -D jest jest-environment-jsdom @testing-library/react @testing-library/jest-dom @testing-library/user-event @types/jest ts-node

# Add scripts to the package.json
colorGreen "Adding testing scripts to package.json"
jq '.scripts.test = "jest" | .scripts["test:watch"] = "jest --watchAll"' package.json > package.json.tmp && mv package.json.tmp package.json

# Create a Jest configuration file
colorGreen "Create Jest configuration file"
cat <<'EOF' > jest.config.ts
import type { Config } from 'jest'
import nextJest from 'next/jest.js'

const createJestConfig = nextJest({
	// Provide the path to your Next.js app to load next.config.js and .env files in your test environment
	dir: './'
})

// Add any custom config to be passed to Jest
const config: Config = {
	coverageProvider: 'v8',
	testEnvironment: 'jsdom',
	// Add more setup options before each test is run
	setupFilesAfterEnv: ['./jest.setup.ts'],
	testMatch: [
		'**/__tests__/**/*.[jt]s?(x)',
		'**/?(*.)+(spec|test).[jt]s?(x)'
	]
}

// createJestConfig is exported this way to ensure that next/jest can load the Next.js config which is async
export default createJestConfig(config)
EOF

# Create a Jest setup file to configure additional matchers
colorGreen "Create Jest setup file"
cat <<EOF > jest.setup.ts
import { ImageProps } from 'next/image'
import '@testing-library/jest-dom'

jest.mock('next/image', () => {
	return {
		__esModule: true,
		default: (props: ImageProps) => {
			// Ensure src is a string
			let src = typeof props.src === 'string' ? props.src : ''
			return `<img src="${src}" alt="${props.alt}" width="${props.width}" height="${props.height}" />`
		}
	}
})
EOF

# Create ESLint configuration file
cat <<EOF > .eslintrc.json
{
  "extends": [
    "next/core-web-vitals",
    "eslint:recommended",
    "plugin:testing-library/react",
    "plugin:jest-dom/recommended",
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
colorGreen "Dev ➜ pnpm dev\nTest ➜ pnpm test\nTDD ➜ pnpm test:watch\n" 

