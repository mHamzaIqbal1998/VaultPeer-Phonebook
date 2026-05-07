# Use a lightweight Node.js 20 image
FROM node:20-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package.json files
# This allows Docker to cache the npm install step if dependencies haven't changed
COPY package*.json ./

# Install dependencies (use --omit=dev for production)
RUN npm install --omit=dev

# Bundle app source
COPY . .

# Expose the default port
EXPOSE 8080

# Start the application
CMD ["node", "server.js"]
