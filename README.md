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

## Importação automática do CSV

Ao iniciar o ambiente com `docker-compose up --build`, os dados do arquivo `data.csv` serão automaticamente importados para a tabela `vendas` no HBase.

## Como funciona a importação automática do CSV

Ao iniciar o ambiente com `docker-compose up --build`, o script `import_csv.sh` é executado automaticamente dentro do container. Esse script realiza os seguintes passos:

1. **Criação da tabela:**  
   O script cria a tabela `vendas` com a coluna família `info` no HBase, caso ela ainda não exista.

2. **Leitura do arquivo CSV:**  
   O arquivo `data.csv` é lido linha a linha (ignorando o cabeçalho).

3. **Inserção dos dados:**  
   Para cada linha do CSV, o script insere os valores das colunas (`InvoiceNo`, `StockCode`, `Description`, `Quantity`, `InvoiceDate`, `UnitPrice`, `CustomerID`, `Country`) como colunas da tabela `vendas` no HBase, usando o valor de `InvoiceNo` como chave primária (rowkey).

O processo é totalmente automatizado: basta garantir que o arquivo `data.csv` esteja no diretório do projeto antes de subir o ambiente.  
Após a inicialização, os dados já estarão disponíveis na tabela `vendas` do HBase.

## Como verificar se a importação ocorreu

Após subir o ambiente, siga os passos abaixo para conferir se os dados do `data.csv` foram importados corretamente para o HBase:

1. **Acesse o terminal do container:**
   ```sh
   docker exec -it hbase_custom bash
   ```

2. No terminal do container, execute:
   ```sh
   hbase shell
   ```

3. Execute um scan na tabela vendas:
   ```sh
   scan 'vendas', {LIMIT => 5}
   ```