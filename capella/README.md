# Capella Server

Este repositório contém comandos úteis para gerenciamento do servidor capella.

## Criar rede externa no Docker

```sh
docker network create proxy
```

Use este comando para criar a rede `proxy` no Docker. A rede `proxy` é necessaria para rodar todos os docker composes na mesma rede do traefik que é o nosso proxy.
