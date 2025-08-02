# Use uma imagem base com Node.js e Yarn
FROM node:18-alpine

# Defina o diretório de trabalho
WORKDIR /app

# Habilite o Corepack para usar a versão correta do Yarn
RUN corepack enable

# Copie o package.json e instale as dependências
COPY package.json yarn.lock ./
# Remova as flags de imutabilidade para permitir a instalação
RUN yarn install

# Copie o restante do código
COPY . .

# Construa a aplicação
RUN yarn build

# Exponha a porta que o Backstage usa
EXPOSE 7007

# Defina o comando para rodar a aplicação
CMD ["yarn", "start"]