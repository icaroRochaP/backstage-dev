# --- Etapa 1: Builder (para compilar a aplicação) ---
# Usa a imagem base do Node.js para o ambiente de build
FROM node:20-bookworm-slim AS builder

# Instala dependências de sistema (sqlite3, python, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-dev python3 python3-pip python3-venv build-essential && \
    yarn config set python /usr/bin/python3

# Configura o ambiente
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip3 install mkdocs-techdocs-core==1.1.7

WORKDIR /app
# Copia arquivos importantes para o gerenciamento de pacotes
COPY .yarn ./.yarn
COPY .yarnrc.yml ./
COPY package.json yarn.lock ./
COPY packages/backend/package.json packages/backend/

# Instala as dependências, incluindo as de desenvolvimento
RUN yarn install --immutable

# Copia todo o código-fonte
COPY . ./

# Executa o build da aplicação Backstage
RUN yarn tsc
RUN yarn build:backend

# --- Etapa 2: Runner (para a imagem de produção) ---
# Usa uma imagem base mais leve para a imagem final de produção
FROM node:20-bookworm-slim

# Instala as dependências de sistema para o ambiente de produção
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-dev python3 python3-pip python3-venv

# Configura o ambiente Python para o TechDocs
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip3 install mkdocs-techdocs-core==1.1.7

# Usa o usuário `node`
WORKDIR /app
USER node

# Copia os artefatos compilados da etapa anterior
COPY --from=builder /app/package.json ./
COPY --from=builder /app/yarn.lock ./
COPY --from=builder /app/.yarn ./.yarn
COPY --from=builder /app/.yarnrc.yml ./
COPY --from=builder /app/packages/backend/dist/skeleton.tar.gz ./
COPY --from=builder /app/packages/backend/dist/bundle.tar.gz ./

# Instala as dependências de produção
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz
RUN yarn workspaces focus --all --production
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# Copia os arquivos de configuração
COPY --from=builder /app/app-config*.yaml ./

# Define o comando de inicialização
CMD ["node", "packages/backend", "--config", "app-config.yaml"]