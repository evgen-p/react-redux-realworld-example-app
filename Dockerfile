FROM alpine:latest AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN apk add nodejs npm && npm install
COPY . .
RUN npm run build

FROM alpine:latest
RUN apk add thttpd
RUN adduser -D static
USER static
WORKDIR /home/static

COPY --from=builder /usr/src/app/build/ .

# CMD ["thttpd", "-D", "-h", "0.0.0.0", "-p", "3000", "-d", "/home/static", "-u", "static", "-l", "-", "-M", "60"]
