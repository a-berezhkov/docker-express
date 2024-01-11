FROM node:21-alpine
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY package*.json ./
RUN npm install
USER node
COPY --chown=node:node . .
EXPOSE 3000
EXPOSE 5000
EXPOSE 8080
CMD [ "node", "app.js" ]