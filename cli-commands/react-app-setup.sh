#!/bin/bash

# Use color codes for output formatting
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${BLUE}Enter your preferred package manager (npm/yarn):${NC}"
read -r PACKAGE_MANAGER

if [ "$PACKAGE_MANAGER" != "npm" ] && [ "$PACKAGE_MANAGER" != "yarn" ]; then
	echo -e "${RED}Invalid package manager.${NC} Please use 'npm' or 'yarn'."
	exit 1
fi

echo -e "${BLUE}Enter your project name:${NC}"
read -r PROJECT_NAME

while [ -d "$PROJECT_NAME" ]; do
	echo -e "${RED}The directory '$PROJECT_NAME' already exists.${NC} Please enter a new project name:"
	read -r PROJECT_NAME
done

start_time=$(date +%s)

echo -e "${GREEN}📁 Creating project folder...${NC}"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

echo -e "${GREEN}🚀 Initializing project...${NC}"
$PACKAGE_MANAGER init -y

echo -e "${GREEN}📦 Installing dependencies...${NC}"
$PACKAGE_MANAGER add react react-dom

if [ "$PACKAGE_MANAGER" = "npm" ]; then
	$PACKAGE_MANAGER add --include=dev webpack webpack-cli webpack-dev-server html-webpack-plugin babel-loader @babel/core @babel/preset-env @babel/preset-react @babel/preset-typescript css-loader sass-loader sass style-loader typescript @types/react @types/react-dom
else
	$PACKAGE_MANAGER add --dev webpack webpack-cli webpack-dev-server html-webpack-plugin babel-loader @babel/core @babel/preset-env @babel/preset-react @babel/preset-typescript css-loader sass-loader sass style-loader typescript @types/react @types/react-dom
fi

echo -e "${GREEN}⚙️ Initializing TypeScript...${NC}"
$PACKAGE_MANAGER tsc --init

echo -e "${GREEN}📂 Creating folders and files...${NC}"
mkdir src public
touch src/index.tsx src/App.tsx src/App.scss public/index.html webpack.config.js .babelrc

# Create the Webpack configuration
cat >webpack.config.js <<EOL
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
	entry: './src/index.tsx',
	output: {
		path: path.resolve(__dirname, 'dist'),
		filename: 'bundle.js',
	},
	module: {
		rules: [
			{
				test: /\.(ts|tsx)$/,
				exclude: /node_modules/,
				use: {
					loader: 'babel-loader',
				},
			},
			{
				test: /\.s[ac]ss$/i,
				use: [
					'style-loader',
					'css-loader',
					'sass-loader',
				],
			},
		],
	},
	resolve: {
		extensions: ['.js', '.jsx', '.ts', '.tsx'],
	},
	plugins: [
		new HtmlWebpackPlugin({
			template: './public/index.html',
		}),
	],
	devServer: {
		static: {
			directory: path.join(__dirname, 'dist'),
		},
		compress: true,
		port: 3000,
	},
};
EOL

# Create the Babel configuration
cat >.babelrc <<EOL
{
	"presets": [
		"@babel/preset-env",
		"@babel/preset-react",
		"@babel/preset-typescript"
	]
}
EOL

# Create the HTML file
cat >public/index.html <<EOL
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		<title>$PROJECT_NAME</title>
	</head>
	<body>
		<div id="root"></div>
	</body>
</html>
EOL

# Create the React components and SASS file
cat >src/App.tsx <<EOL
import React from 'react';
import './App.scss';

const App: React.FC = () => {
	return (
		<div className="app">
			<h1>Hello, React with TypeScript and SASS!</h1>
		</div>
	);
};

export default App;
EOL

cat >src/App.scss <<EOL
.app {
	display: flex;
	justify-content: center;
	align-items: center;
	height: 100vh;

	h1 {
		color: blue;
	}
}
EOL

cat >src/index.tsx <<EOL
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

ReactDOM.render(
	<React.StrictMode>
		<App />
	</React.StrictMode>,
	document.getElementById('root')
);
EOL

# Update the scripts in package.json using Python
python -c "import json; \
	data = json.load(open('package.json')); \
	print('Loaded package.json:', data); \
	data.setdefault('scripts', {})['start'] = 'webpack serve --mode development --open'; \
	data['scripts']['build'] = 'webpack --mode production'; \
	json.dump(data, open('package.json', 'w'), indent=2); \
	print('Updated package.json:', data)"

end_time=$(date +%s)
time_elapsed=$((end_time - start_time))

echo -e "${YELLOW}✅ Project setup complete. Time elapsed: ${time_elapsed} seconds.${NC}"

# Print instructions for building and running the project
echo ""
echo "Instructions:"
echo "1. To build the project, run: '$PACKAGE_MANAGER run build'"
echo "2. To run the project in development mode, run: '$PACKAGE_MANAGER run start'"

# Prompt user if they want to run the project now
echo ""
echo "Do you want to run the project now? (yes/no)"
read -r run_project

if [ "$run_project" = "yes" ]; then
	$PACKAGE_MANAGER run start
else
	echo "You can run the project later with the command: '$PACKAGE_MANAGER run start'"
fi
