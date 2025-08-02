# --- Estágio 1: Dependências ---
FROM node:20-slim AS dependencies

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends build-essential python3

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages ./packages

RUN yarn install --immutable


# --- Estágio 2: Build completo (app + backend) ---
FROM node:20-slim AS build

WORKDIR /app

COPY --from=dependencies /app .

# Build completo do Backstage (gera dist/backend/index.js)
RUN yarn build


# --- Estágio 3: Produção ---
FROM node:20-slim AS production

WORKDIR /app

ENV NODE_ENV=production
ENV TZ=America/Sao_Paulo

RUN corepack enable

# Copia apenas os arquivos necessários para rodar o backend
COPY --from=build /app/dist ./dist
COPY --from=build /app/yarn.lock /app/package.json /app/.yarnrc.yml ./
COPY --from=build /app/.yarn ./.yarn

# Instala só deps de produção
RUN yarn install --production --immutable

EXPOSE 7007

CMD ["node", "dist/backend"]