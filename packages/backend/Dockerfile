# --- Estágio 1: Dependências ---
FROM node:20-slim AS dependencies

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends build-essential python3

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages ./packages

RUN yarn install --immutable


# --- Estágio 2: Build do backend ---
FROM node:20-slim AS build

WORKDIR /app

COPY --from=dependencies /app .

RUN yarn workspace backend build


# --- Estágio 3: Produção ---
FROM node:20-slim AS production

WORKDIR /app

ENV NODE_ENV=production
ENV TZ=America/Sao_Paulo

RUN corepack enable

# Copia dist e package.json do backend
COPY --from=build /app/packages/backend/dist ./dist
COPY --from=build /app/packages/backend/package.json ./package.json

# Copia arquivos de config e .yarn
COPY --from=build /app/yarn.lock ./
COPY --from=build /app/.yarn ./.yarn
COPY --from=build /app/.yarnrc.yml ./

RUN yarn install --production

EXPOSE 7007

CMD ["node", "dist/index.cjs.js"]