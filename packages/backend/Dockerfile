# --- Estágio 1: Base de Dependências ---
FROM node:20-slim AS dependencies

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends build-essential python3
RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages packages

RUN yarn install --immutable


# --- Estágio 2: Build ---
FROM node:20-slim AS build

WORKDIR /app

COPY --from=dependencies /app .

RUN yarn build:backend


# --- Estágio 3: Final ---
FROM node:20-slim

WORKDIR /app

ENV TZ=America/Sao_Paulo

# Copia o bundle gerado
COPY --from=build /app/packages/backend/dist/bundle.tar.gz ./

# Copia o código do backend
COPY --from=build /app/packages/backend ./packages/backend

# Copia arquivos raiz
COPY app-config.yaml ./
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Instala somente o workspace do backend com deps de produção
RUN corepack enable && yarn workspaces focus backend --production --immutable

# Extrai o bundle
RUN tar -xzf bundle.tar.gz && rm bundle.tar.gz

EXPOSE 7007

CMD ["node", "packages/backend"]