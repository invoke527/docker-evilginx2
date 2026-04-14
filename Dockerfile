FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git make build-base
WORKDIR /app
RUN git clone https://github.com/kgretzky/evilginx2.git .
RUN make

FROM alpine:latest
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /app/bin/evilginx .

# Copia os arquivos que você criou no Kali para dentro do servidor
RUN mkdir -p /app/phishlets
COPY ./phishlets/demobank.yaml /app/phishlets/demobank.yaml
COPY ./config.yaml /app/config.yaml

EXPOSE 80 443 53/udp

# Inicia o Evilginx apontando para a pasta correta
ENTRYPOINT ["./evilginx", "-p", "/app/phishlets", "-c", "/app/data"]
