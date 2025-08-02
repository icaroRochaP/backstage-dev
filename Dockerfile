# Use uma imagem base com Node.js e Yarn
FROM node:18-alpine

# Defina o diretório de trabalho
WORKDIR /app

# Habilite o Corepack para usar a versão correta do Yarn
RUN corepack enable

# Copie o package.json e instale as dependências
COPY package.json yarn.lock ./
# Use o comando de instalação mais moderno
RUN yarn install --immutable --immutable-cache

# Copie o restante do código
COPY . .

# Construa a aplicação
RUN yarn build

# Exponha a porta que o Backstage usa
EXPOSE 7007

# Defina o comando para rodar a aplicação
CMD ["yarn", "start"]