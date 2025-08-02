# --- Estágio 1: Base de Dependências ---
# Define a versão do Node.js consistente com o seu package.json (Node 20).
# Este estágio foca apenas em instalar as dependências para maximizar o cache.
FROM node:20-slim AS dependencies

# Define o diretório de trabalho.
WORKDIR /app

# Instala as ferramentas essenciais de build para compilar dependências nativas.
RUN apt-get update && apt-get install -y --no-install-recommends build-essential python3

# Habilita o Corepack para usar a versão correta do Yarn.
RUN corepack enable

# Copia apenas os arquivos necessários para a instalação de dependências.
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages packages

# Instala todas as dependências (dev e prod) de forma imutável.
RUN yarn install --immutable


# --- Estágio 2: Build ---
# Este estágio usa as dependências do estágio anterior e compila a aplicação.
FROM node:20-slim AS build

WORKDIR /app

# Copia as dependências e o código-fonte já instalados do estágio anterior.
COPY --from=dependencies /app .

# Executa o build do backend.
RUN yarn build:backend


# --- Estágio 3: Final ---
# Este é o estágio final, que resulta na imagem de produção.
FROM node:20-slim

WORKDIR /app

# Define o fuso horário para logs consistentes.
ENV TZ=America/Sao_Paulo

# Copia o pacote do backend (bundle) do estágio de build.
COPY --from=build /app/packages/backend/dist/bundle.tar.gz ./

# Copia o arquivo de configuração diretamente do contexto local.
COPY app-config.yaml ./

# Descompacta o pacote do backend.
RUN tar -xzf bundle.tar.gz && rm bundle.tar.gz

# Expõe a porta que o backend do Backstage usará.
EXPOSE 7007

# Inicia o backend.
CMD ["node", "packages/backend"]