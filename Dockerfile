# --- Etapa 1: Builder (para compilar a aplicação) ---
FROM node:20-bookworm-slim AS builder

# Instala dependências de sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-dev python3 python3-pip python3-venv build-essential && \
    yarn config set python /usr/bin/python3

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip3 install mkdocs-techdocs-core==1.1.7

WORKDIR /app

# Copia da raiz do contexto para o contêiner
COPY ./wait-for-db.sh ./
COPY ./.yarn ./.yarn
COPY ./package.json ./yarn.lock ./
COPY ./.yarnrc.yml ./
COPY ./packages ./packages

RUN yarn install --immutable

# Copia o restante do código-fonte
COPY . ./

# Executa o build da aplicação Backstage
RUN yarn tsc
RUN yarn build:backend


# --- Etapa 2: Runner (para a imagem de produção final) ---
FROM node:20-bookworm-slim

# Instala dependências de sistema para o ambiente de produção
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-dev python3 python3-pip python3-venv postgresql-client

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip3 install mkdocs-techdocs-core==1.1.7

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
COPY --from=builder --chown=node:node /app/wait-for-db.sh ./
RUN chmod +x ./wait-for-db.sh

RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz
RUN yarn workspaces focus --all --production
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# COPIA OS ARQUIVOS DE CONFIGURAÇÃO DA RAIZ DO CONTEXTO PARA O CONTAINER
COPY ./app-config*.yaml ./
COPY ./catalog-info.yaml ./

CMD ["./wait-for-db.sh", "postgres", "node", "packages/backend", "--config", "app-config.yaml"]