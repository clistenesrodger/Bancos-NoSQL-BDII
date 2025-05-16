# HBase com Docker Compose

Este projeto configura um ambiente HBase usando Docker Compose para facilitar testes e estudos.

## Como executar o ambiente

1. **Clone o repositório (se necessário):**
   ```sh
   git clone <url-do-repositorio>
   cd Bancos-NoSQL-BDII
   ```

2. Construa e inicie o container:
   ```sh
   docker-compose up --build
   ```
   Isso irá baixar as dependências, construir a imagem e iniciar o serviço do HBase.

3. Acesse a interface web do HBase:

   Abra o navegador e acesse: http://localhost:16010

## Como acessar o shell do HBase

1. Abra um terminal no container:
   ```sh
   docker exec -it hbase_custom bash
   ```

2. No terminal do container, execute:
   ```sh
   hbase shell
   ```

## Para parar e remover os containers

Execute:
   ```sh
   docker-compose down
   ```