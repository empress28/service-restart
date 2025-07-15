FROM node:18-alpine

WORKDIR /app

# Copy everything
COPY . .

# Make script executable
RUN chmod +x service_restart.sh

# Install dependencies
RUN npm install

# Expose port
EXPOSE 3000

# Start the service
CMD ["npm", "start"]
