//TODO step-by-step algoritm 

# Docker для Express App
## Выбираем образ Node.js

Создаем ```Dockerfile``` в директории проекта.

Любой Dockerfile должен начинаться с инструкции ```FROM```.

Найти подходящий образ, к примеру под Node.js, можно тут  https://hub.docker.com/_/node/

```dockerfile
./Dockerfile

FROM node: 21-alpine3.18
```

Создадим папки для модулей npm (node_modules) и самого приложения. Так как в дальнейшем могут быть проблемы с правами доступа на эти папки. 

Это одна из лучших практик. Еще больше полезностей по лучшим практикам тут - https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md

```dockerfile
./Dockerfile

FROM node: 21-alpine3.18
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
```

Укажем рабочую директорию в контейнере  ```/home/node/app``` (там будет лежать код проекта):

```dockerfile
./Dockerfile

FROM node: 21-alpine3.18
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
```

Если рабочая область не будет указана вручную, то будет создана авотматически, но это довольно неудобно =)

Далее копируем package.json and package-lock.json файлы командой ```COPY package*.json ./```:

```dockerfile
./Dockerfile

FROM node: 21-alpine3.18
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY package*.json ./
```

Ставим зависимости в контейнере командой  ```RUN npm install```

```js
./Dockerfile

FROM node:21-alpine
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY package*.json ./
RUN npm install

```

Чтобы гарантировать, что все файлы приложения принадлежат пользователю без root, включая содержимое каталога node_modules, переключите пользователя ```USER node```  перед запуском установки npm:

```dockerfile
./Dockerfile

FROM node: 21-alpine3.18
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY package*.json ./
USER node

```

И осталось скопировать код проекта в контейнер командой ```COPY --chown=node:node . .```

```dockerfile
./Dockerfile

FROM node:21-alpine
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY package*.json ./
RUN npm install
USER node
COPY --chown=node:node . .

```

Документация по команде здесь - https://docs.docker.com/engine/reference/builder/#copy

Полное описание команды

```dockerfile
COPY [--chown=<user>:<group>] [--chmod=<perms>] <src>... <dest>
COPY [--chown=<user>:<group>] [--chmod=<perms>] ["<src>",... "<dest>"]
```

COPY копирует новые файлы или каталоги из <src> и добавляет их в файловую систему контейнера по пути <dest>.

Команда COPY --chown=node:node . . работает следующем образом:
1. от пользователя node
2. копирует все файлы текущей директории . (первая точка)
3. в файловую систему контейнера . (вторая точка) по пути WORKDIR

Осталось открыть порты командой ```EXPOSE 3000```

```dockerfile
./Dockerfile

FROM node:21-alpine
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY package*.json ./
RUN npm install
USER node
COPY --chown=node:node . .
EXPOSE 3000
```

И запустить приложение

```dockerfile
./Dockerfile

FROM node:21-alpine
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY package*.json ./
RUN npm install
USER node
COPY --chown=node:node . .
EXPOSE 3000
CMD [ "node", "app.js" ]
```

Прежде чем создавать образ приложения, добавьте файл ```.dockerignore```. Работая аналогично файлу ```.gitignore```, ```.dockerignore``` указывает, какие файлы и каталоги в каталоге вашего проекта не следует копировать в ваш контейнер.

Добавим туда node модули, логи и файлы docker

```dockerignore
./dockerignore

node_modules
npm-debug.log
Dockerfile
.dockerignore
```

Звпускаем из директории проекта в командной строке команду создания образа. 

```zsh
$ docker build -t getting-started .
```

Смотрим его наличие в списке образов:

```zsh
$ docker images
```

```zsh
demo-docker             latest    0 f316d56e267   20 seconds ago   146MB
```

Заупскаем на порте 3000.

```zsh
$ docker run -p 3000:3000 demo-docker 
```

Как обновить файлы в контейнере, описано тут https://docs.docker.com/get-started/03_updating_app/.