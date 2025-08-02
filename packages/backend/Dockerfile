# --- Etapa 2: Runner (para a imagem de produção final) ---
# Usa uma imagem base mais leve para a imagem de produção
FROM node:20-bookworm-slim

# Instala as dependências de sistema para o ambiente de produção
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-dev python3 python3-pip python3-venv

# Configura o ambiente Python para o TechDocs
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip3 install mkdocs-techdocs-core==1.1.7

# Usa o usuário `node` para segurança
WORKDIR /app
# AQUI ESTÁ A CORREÇÃO: Mova o chown para antes do COPY
# Isso garante que o diretório /app seja de propriedade do usuário `node`
RUN chown -R node:node /app
USER node

# Copia os artefatos compilados da etapa anterior (`builder`)
COPY --from=builder --chown=node:node /app/package.json ./
COPY --from=builder --chown=node:node /app/yarn.lock ./
COPY --from=builder --chown=node:node /app/.yarn ./.yarn
COPY --from=builder --chown=node:node /app/.yarnrc.yml ./
COPY --from=builder --chown=node:node /app/packages/backend/dist/skeleton.tar.gz ./
COPY --from=builder --chown=node:node /app/packages/backend/dist/bundle.tar.gz ./

# Descompacta e instala as dependências de produção
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz
RUN yarn workspaces focus --all --production
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# Copia os arquivos de configuração da aplicação
COPY --from=builder --chown=node:node /app/app-config*.yaml ./

# Define o comando de inicialização da aplicação
CMD ["node", "packages/backend", "--config", "app-config.yaml"]