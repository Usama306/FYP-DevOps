# Environment-Specific Landing Pages

A Node.js application that demonstrates different landing pages for development, test, and production environments using Docker containers.

## Features

- Different themed pages for each environment (Development, Test, Production)
- Docker containerization with environment isolation
- Particle.js background effects
- Tailwind CSS for styling
- Environment-specific configurations

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/Usama306/FYP-DevOps.git
cd FYP-DevOps
```

2. Start the environments:

Development:
```bash
docker compose up dev
```

Test:
```bash
docker compose up test
```

Production:
```bash
docker compose up prod
```

Or start all environments:
```bash
docker compose up
```

3. Access the environments:
- Development: http://localhost:3001
- Test: http://localhost:3002
- Production: http://localhost:3003

## Environment Details

### Development (Blue Theme)
- PORT: 3001
- Features development-specific UI
- Hot-reloading enabled

### Test (Yellow Theme)
- PORT: 3002
- Testing environment configuration
- Isolated test setup

### Production (Green Theme)
- PORT: 3003
- Production-ready configuration
- Optimized for deployment

## Project Structure

```
.
├── app/
│   ├── public/
│   ├── src/
│   │   └── styles/
│   ├── views/
│   ├── server.js
│   ├── package.json
│   ├── tailwind.config.js
│   └── postcss.config.js
├── docker-compose.yml
└── Dockerfile
```

## Technologies Used

- Node.js
- Express.js
- EJS Templates
- Tailwind CSS
- Docker
- Particles.js

## License

MIT 