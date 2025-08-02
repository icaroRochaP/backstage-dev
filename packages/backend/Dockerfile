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

# Copia arquivos essenciais para rodar o backend com Yarn PnP
COPY --from=build /app/.pnp.cjs ./
COPY --from=build /app/packages/backend/package.json ./packages/backend/package.json
COPY --from=build /app/packages/backend/dist ./packages/backend/dist
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/yarn.lock ./yarn.lock
COPY --from=build /app/.yarnrc.yml ./.yarnrc.yml
COPY --from=build /app/.yarn ./.yarn

# Instala apenas o backend em produção, sem devDependencies
RUN yarn workspaces focus backend --production

EXPOSE 7007

CMD ["node", "packages/backend/dist/index.cjs.js"]