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

## Modificações realizadas para funcionamento distribuído do HBase

### O que foi modificado

- **Separação dos serviços:**  
  O serviço único do HBase foi dividido em três serviços distintos no `docker-compose.yml`:
  - `zookeeper`: Responsável pela coordenação do cluster.
  - `hbase-master`: Responsável pelo gerenciamento do cluster HBase.
  - `hbase-regionserver`: Responsável pelo armazenamento e processamento dos dados.

- **Variáveis de ambiente:**  
  Foram adicionadas as variáveis `HBASE_MANAGES_ZK` e `HBASE_ROLE` para definir o papel de cada container (master ou regionserver).

- **Volumes separados:**  
  Cada serviço HBase (`hbase-master` e `hbase-regionserver`) utiliza volumes distintos para persistência dos dados.

- **Importação automática:**  
  O arquivo `data.csv` é montado apenas no container do master, permitindo a importação automática dos dados ao iniciar o ambiente.

- **Exposição de portas:**  
  As portas de administração e comunicação de cada serviço foram explicitamente expostas para facilitar o acesso e monitoramento.

---

### Objetivo das modificações

- **Simular um ambiente distribuído:**  
  Permitir que o HBase rode de forma semelhante a um cluster real, com múltiplos papéis (master e regionserver) e coordenação via ZooKeeper.

- **Escalabilidade:**  
  Possibilitar a adição de múltiplos regionservers facilmente, simulando o aumento de nós no cluster para suportar maior volume de dados e consultas distribuídas.

- **Persistência e isolamento:**  
  Garantir que cada serviço tenha seu próprio volume de dados, simulando discos separados como em um ambiente real.

- **Facilidade de demonstração:**  
  Permitir que o ambiente seja facilmente iniciado, testado e monitorado em laboratório ou em sala de aula, demonstrando os conceitos de banco de dados distribuído.

---

## Como testar o acesso simultâneo por duas pessoas na mesma rede

Se duas pessoas estiverem na mesma rede (por exemplo, no laboratório ou conectadas à mesma VPN), ambas podem acessar o mesmo banco de dados HBase. Veja como simular isso:

### 1. Descubra o IP da máquina que está rodando o Docker Compose

No terminal da máquina host, execute:
```sh
hostname -I
```
Anote o IP retornado (exemplo: 192.168.0.10).

2. Garanta que as portas necessárias estão expostas
No seu docker-compose.yml, as portas 16010 (web UI), 2181 (ZooKeeper) e, se necessário, 9090 (Thrift) devem estar expostas.

3. Acesse o HBase a partir de outra máquina na mesma rede
Na segunda máquina (usuário 2), execute:

```sh
docker exec -it hbase-master bash
```
No shell do container ou cliente HBase, execute:

```sh
hbase shell
scan 'vendas', {LIMIT => 5}
```

4. Simule dois acessos simultâneos
Pessoa 1:
No terminal 1, acesse o shell do HBase e faça uma consulta:

```sh
docker exec -it hbase-master bash
hbase shell
scan 'vendas', {LIMIT => 5}
```

Pessoa 2:
No terminal 2 (ou em outro computador na mesma rede), repita o processo acima.

Ambos verão os mesmos dados, pois estão acessando o mesmo cluster HBase.
