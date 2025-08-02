# Use uma imagem base com Node.js e Yarn
FROM node:18-slim

# Defina o diretório de trabalho
WORKDIR /app

# Habilite o Corepack
RUN corepack enable

# Copie apenas os arquivos de configuração de dependências
COPY package.json yarn.lock ./

# Instale as dependências
RUN yarn install

# Copie o restante do código
COPY . .

# Construa a aplicação
RUN yarn build

# Exponha a porta que o Backstage usa
EXPOSE 7007

# Defina o comando para rodar a aplicação
CMD ["yarn", "start"]