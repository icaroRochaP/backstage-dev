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
# Isso melhora o cache, pois o 'yarn install' só será executado novamente
# se um desses arquivos mudar.
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages packages

# Instala todas as dependências (dev e prod) de forma imutável.
# As dependências de desenvolvimento são necessárias para o estágio de build.
RUN yarn install --immutable


# --- Estágio 2: Build ---
# Este estágio usa as dependências do estágio anterior e compila a aplicação.
FROM node:20-slim AS build

WORKDIR /app

# Copia as dependências e o código-fonte já instalados do estágio anterior.
# Esta é a única fonte de verdade para o código, evitando problemas com .dockerignore.
COPY --from=dependencies /app .

# --- DEPURAÇÃO ---
# Lista o conteúdo em cada nível do caminho para encontrar o ponto de falha.
RUN echo "--- Listing /app ---" && ls -lA /app
RUN echo "--- Listing /app/packages ---" && ls -lA /app/packages
RUN echo "--- Listing /app/packages/backend ---" && ls -lA /app/packages/backend
RUN echo "--- Listing /app/packages/backend/src ---" && ls -lA /app/packages/backend/src


# Executa o build do backend. Este comando gera um pacote otimizado
# para produção em 'packages/backend/dist'.
RUN yarn build:backend


# --- Estágio 3: Final ---
# Este é o estágio final, que resulta na imagem de produção.
# É uma imagem leve, contendo apenas o necessário para rodar o backend.
FROM node:20-slim

WORKDIR /app

# Define o fuso horário (opcional, mas recomendado para logs consistentes).
ENV TZ=America/Sao_Paulo

# Copia o pacote do backend (bundle) e o arquivo de configuração do estágio de build.
COPY --from=build /app/packages/backend/dist/bundle.tar.gz /app/app-config.yaml ./

# Descompacta o pacote do backend.
RUN tar -xzf bundle.tar.gz && rm bundle.tar.gz

# Expõe a porta que o backend do Backstage usará.
EXPOSE 7007

# Define o comando para iniciar o servidor.
# Ele executa o backend a partir do pacote descompactado.
CMD ["node", "packages/backend"]
