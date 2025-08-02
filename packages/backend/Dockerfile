# --- Etapa 1: Builder (para compilar a aplicação) ---
FROM node:20-bookworm-slim AS builder

# Instala dependências de sistema para o sqlite3, techdocs e outras ferramentas
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-dev python3 python3-pip python3-venv build-essential && \
    yarn config set python /usr/bin/python3

# Configura o ambiente Python para o TechDocs
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip3 install mkdocs-techdocs-core==1.1.7

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copia o script de espera do banco de dados para a imagem
COPY wait-for-db.sh ./

# Copia os arquivos de configuração do Yarn e do projeto
COPY .yarn ./.yarn
COPY .yarnrc.yml ./
COPY package.json yarn.lock ./

# Copia o esqueleto do projeto (apenas os arquivos package.json de cada pacote)
COPY packages/ packages/

# Instala as dependências do projeto (incluindo as de desenvolvimento)
RUN yarn install --immutable

# Copia todo o código-fonte restante
COPY . ./

# Executa o build da aplicação Backstage
RUN yarn tsc
RUN yarn build:backend


# --- Etapa 2: Runner (para a imagem de produção final) ---
FROM node:20-bookworm-slim

# Instala as dependências de sistema para o ambiente de produção
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-dev python3 python3-pip python3-venv

# Instala o cliente do PostgreSQL para o script de espera
RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client

# Configura o ambiente Python para o TechDocs
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip3 install mkdocs-techdocs-core==1.1.7

# Usa o usuário `node` para segurança
WORKDIR /app
RUN chown -R node:node /app
USER node

# Copia os artefatos compilados da etapa anterior (`builder`)
COPY --from=builder --chown=node:node /app/package.json ./
COPY --from=builder --chown=node:node /app/yarn.lock ./
COPY --from=builder --chown=node:node /app/.yarn ./.yarn
COPY --from=builder --chown=node:node /app/.yarnrc.yml ./
COPY --from=builder --chown=node:node /app/packages/backend/dist/skeleton.tar.gz ./
COPY --from=builder --chown=node:node /app/packages/backend/dist/bundle.tar.gz ./
# Copia o script de espera da etapa 'builder' para a etapa 'runner'
COPY --from=builder --chown=node:node /app/wait-for-db.sh ./
RUN chmod +x ./wait-for-db.sh

# Descompacta e instala as dependências de produção
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz
RUN yarn workspaces focus --all --production
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# Copia os arquivos de configuração da aplicação e o catalog-info.yaml
COPY --from=builder --chown=node:node /app/app-config*.yaml ./
# ADICIONADO: Copia o arquivo de catálogo local para a imagem final
COPY --from=builder --chown=node:node /app/catalog-info.yaml ./

# Define o comando de inicialização da aplicação, usando o script de espera
CMD ["./wait-for-db.sh", "postgres", "node", "packages/backend", "--config", "app-config.yaml"]