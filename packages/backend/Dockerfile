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

COPY --from=build /app/packages/backend ./packages/backend
COPY --from=build /app/package.json /app/yarn.lock /app/.yarnrc.yml ./
COPY --from=build /app/.yarn ./.yarn

RUN yarn workspaces focus --production --all

EXPOSE 7007

# ✅ Arquivo correto do backend
CMD ["node", "packages/backend/dist/index.cjs.js"]