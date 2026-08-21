FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY tsconfig.json vite.config.ts index.html ./
COPY src ./src

# Browser-side URL. The compose file passes this as a build argument.
ARG VITE_ORCHESTRATOR_URL=http://localhost:4005
ENV VITE_ORCHESTRATOR_URL=$VITE_ORCHESTRATOR_URL

RUN npm run build

FROM nginx:1.29-alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY docker/rlt-web/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
