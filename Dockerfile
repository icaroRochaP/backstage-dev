# --- Stage 1: Build ---
# Usa a imagem do Node para construir o projeto.
FROM node:18-slim as build

# Define o diretório de trabalho.
WORKDIR /app

# Habilita o Corepack para garantir que a versão correta do Yarn seja usada.
RUN corepack enable

# Copia os arquivos de configuração de dependências.
COPY package.json yarn.lock ./

# Instala as dependências. Adicionamos um comentário para forçar a rebuild.
RUN yarn install --immutable --immutable-cache # rebuild-fix-v1

# Copia o restante do código da aplicação.
COPY . .

# Faz a build das aplicações do Backstage.
RUN yarn tsc
RUN yarn build:api
RUN yarn build

# --- Stage 2: Final ---
# Usa uma imagem mais leve para o contêiner final em produção.
FROM node:18-slim

# Define o diretório de trabalho.
WORKDIR /app

# Copia a aplicação construída do estágio anterior (build).
COPY --from=build /app/packages/backend/dist ./packages/backend/dist
COPY --from=build /app/packages/backend/dist-types ./packages/backend/dist-types
COPY --from=build /app/packages/app/dist ./packages/app/dist

# Copia arquivos de configuração e outros recursos necessários.
COPY --from=build /app/app-config.yaml ./
COPY --from=build /app/package.json ./
COPY --from=build /app/yarn.lock ./
COPY --from=build /app/.yarn ./.yarn
COPY --from=build /app/.pnp.* ./
COPY --from=build /app/backstage.json ./

# Expõe a porta e define o comando de execução para o backend do Backstage.
EXPOSE 7007
CMD ["yarn", "start-backend"]