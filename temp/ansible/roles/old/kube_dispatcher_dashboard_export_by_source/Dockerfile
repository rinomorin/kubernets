# Base image for Node + Python + Jinja2
FROM node:20-bullseye

WORKDIR /app

# Install dependencies
COPY react-dashboard/ ./react-dashboard/
COPY jinja2-dashboard/ ./jinja2-dashboard/
COPY mock-server/ ./mock-server/
COPY Makefile ./

RUN make deploy

# Expose static dashboard + mock API
CMD ["node", "mock-server/server.js"]
