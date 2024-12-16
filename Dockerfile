FROM node:18

WORKDIR /usr/src/app

# Install global packages
RUN npm install -g tailwindcss postcss autoprefixer nodemon

# Create necessary directories with correct permissions
RUN mkdir -p public src/styles && \
    chown -R node:node /usr/src/app

# Copy package files first
COPY --chown=node:node app/package*.json ./

# Install dependencies
RUN npm install

# Copy app directory contents (excluding node_modules)
COPY --chown=node:node app/ .

# Build CSS
RUN npm run build:css

# Switch to node user
USER node

# Expose port
EXPOSE 3000

# Start command will be provided by docker-compose