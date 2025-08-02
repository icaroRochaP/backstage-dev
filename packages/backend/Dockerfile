# --- Estágio 1: Instala dependências de todos os workspaces ---
FROM node:20-slim AS dependencies

WORKDIR /app

# Instala build deps básicas
RUN apt-get update && apt-get install -y --no-install-recommends build-essential python3

# Ativa Corepack e garante Yarn 4.4.1 (ou o que estiver no .yarnrc.yml)
RUN corepack enable

# Copia config de Yarn
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Copia os workspaces
COPY packages ./packages

# Instala TODAS as dependências (desenvolvimento incluso)
RUN yarn install --immutable


# --- Estágio 2: Build do backend ---
FROM node:20-slim AS build

WORKDIR /app

# Copia tudo do estágio anterior (com node_modules/linkers se for o caso)
COPY --from=dependencies /app .

# Roda o build do backend
RUN yarn workspace backend build


# --- Estágio 3: Imagem final de produção ---
FROM node:20-slim AS production

WORKDIR /app

ENV TZ=America/Sao_Paulo

# Ativa corepack e garante Yarn na versão do projeto
RUN corepack enable

# Copia apenas os arquivos essenciais do backend
COPY --from=build /app/packages/backend ./packages/backend
COPY --from=build /app/package.json /app/yarn.lock /app/.yarnrc.yml ./
COPY --from=build /app/.yarn ./.yarn

# Instala apenas dependências de produção do backend
RUN yarn workspaces focus --production --all

# Expõe porta padrão do backend do Backstage
EXPOSE 7007

# Comando de inicialização
CMD ["node", "packages/backend"]