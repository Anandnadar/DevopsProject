FROM node:alpine
WORKDIR /src
COPY package.json ./
RUN npm install
COPY . . /src/

# Expose Vite default port
EXPOSE 5173

# Start Vite dev server
CMD ["npm", "run", "dev", "--", "--host"]