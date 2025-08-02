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

# Copia o pacote do backend (gerado no estágio anterior)
COPY --from=build /app/packages/backend/dist/bundle.tar.gz ./

# Copia arquivos essenciais para instalar dependências no container final
COPY ./packages/backend/package.json ./package.json
COPY ./packages/backend/yarn.lock ./yarn.lock
COPY ./app-config.yaml ./app-config.yaml

# Descompacta o bundle
RUN tar -xzf bundle.tar.gz && rm bundle.tar.gz

# Instala somente as dependências de produção
RUN corepack enable && yarn install --production --frozen-lockfile

EXPOSE 7007

CMD ["node", "packages/backend"]