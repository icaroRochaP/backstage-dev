# Use uma imagem base com Node.js e Yarn
FROM node:18-alpine

# Defina o diretório de trabalho
WORKDIR /app

# Copie o package.json e instale as dependências
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copie o restante do código
COPY . .

# Construa a aplicação
RUN yarn build

# Exponha a porta que o Backstage usa
EXPOSE 7007

# Defina o comando para rodar a aplicação
CMD ["yarn", "start"]