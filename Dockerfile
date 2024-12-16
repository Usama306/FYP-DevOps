FROM node:18

WORKDIR /usr/src/app

# Install global packages
RUN npm install -g tailwindcss postcss autoprefixer nodemon

# Create necessary directories
RUN mkdir -p public src/styles

# Copy package files first
COPY app/package*.json ./

# Install dependencies
RUN npm install

# Copy app directory contents (excluding node_modules)
COPY app/ .

# Build CSS
RUN npm run build:css && \
    chown -R node:node /usr/src/app

# Switch to node user
USER node

# Expose port
EXPOSE 3000

# Start command will be provided by docker-compose