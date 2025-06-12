# Tutorial Passo a Passo: Comandos Básicos do Apache HBase Shell em Ambiente Docker

## Pré-requisitos

Antes de começar, certifique-se de ter o Docker e o Docker Compose instalados em sua máquina. Além disso, você deve ter o projeto Docker do HBase configurado e em execução. Se ainda não o fez, siga os passos abaixo para iniciar o ambiente:

1.  **Navegue até o diretório do projeto:**
    ```bash
    cd /caminho/para/seu/projeto/Bancos-NoSQL-BDII
    ```

2.  **Construa e inicie os containers:**
    ```bash
    docker-compose up --build -d
    ```
    Este comando irá baixar as dependências, construir a imagem do HBase e iniciar os serviços (Zookeeper, HBase Master e RegionServers). O `-d` no final executa os containers em segundo plano.

3.  **Verifique o status dos containers (opcional):**
    ```bash
    docker-compose ps
    ```
    Certifique-se de que todos os serviços estão `Up`.

## 1. Conectando ao HBase Shell

Para acessar o shell do HBase, você precisa primeiro entrar no container `hbase-master`. Abra um novo terminal e execute:

```bash
docker exec -it hbase-master bash
```

Uma vez dentro do container, você pode iniciar o shell do HBase:

```bash
hbase shell
```

Você verá um prompt `hbase(main):001:0>`. Agora você está conectado ao shell e pronto para executar comandos.

## 2. Comandos Gerais

*   **`help`**: Exibe informações de ajuda sobre os comandos do shell.

    ```hbase-shell
    help
    ```

*   **`version`**: Mostra a versão do HBase.

    ```hbase-shell
    version
    ```

*   **`status`**: Exibe o status do cluster HBase (número de servidores, etc.).

    ```hbase-shell
    status
    ```

## 3. Gerenciamento de Tabelas

No seu ambiente Docker, a tabela `vendas` com a família de colunas `info` é criada automaticamente e populada com dados do `data.csv` quando o ambiente é iniciado via `docker-compose up --build`. Portanto, você não precisará criá-la manualmente para este tutorial.

### 3.1. Listando Tabelas

Para ver as tabelas existentes no HBase (você deverá ver a tabela `vendas`):

```hbase-shell
list
```

### 3.2. Descrevendo uma Tabela

Para ver a descrição da tabela `vendas`, incluindo suas famílias de colunas:

```hbase-shell
describe 'vendas'
```

### 3.3. Desabilitando uma Tabela

Se você precisar modificar a estrutura da tabela `vendas` ou removê-la, primeiro ela precisa ser desabilitada:

```hbase-shell
disable 'vendas'
```

### 3.4. Habilitando uma Tabela

Para tornar a tabela `vendas` novamente ativa após desabilitá-la:

```hbase-shell
enable 'vendas'
```

### 3.5. Removendo (Dropando) uma Tabela

Para remover a tabela `vendas`, ela deve estar desabilitada primeiro:

```hbase-shell
drop 'vendas'
```




## 4. Manipulação de Dados na Tabela `vendas`

No seu ambiente Docker, a tabela `vendas` já é populada automaticamente com dados do `data.csv` ao iniciar o ambiente. Abaixo, você encontrará comandos para interagir com esses dados.

### 4.1. Inserindo Dados (put)

Embora a tabela `vendas` já esteja populada, você pode inserir novos dados ou atualizar os existentes usando o comando `put`. Lembre-se que o HBase sobrescreve o valor de uma célula se você usar a mesma `row key`, família de coluna e qualificador de coluna.

```hbase-shell
put 'vendas', 'nova_invoice_no', 'info:InvoiceNo', 'nova_invoice_no_valor'
put 'vendas', 'nova_invoice_no', 'info:StockCode', 'novo_stock_code_valor'
put 'vendas', 'nova_invoice_no', 'info:Description', 'nova_descricao'
put 'vendas', 'nova_invoice_no', 'info:Quantity', '10'
put 'vendas', 'nova_invoice_no', 'info:InvoiceDate', '01/01/2025'
put 'vendas', 'nova_invoice_no', 'info:UnitPrice', '9.99'
put 'vendas', 'nova_invoice_no', 'info:CustomerID', '99999'
put 'vendas', 'nova_invoice_no', 'info:Country', 'Brazil'
```

Exemplo de inserção de um novo registro:

```hbase-shell
put 'vendas', '536366', 'info:InvoiceNo', '536366'
put 'vendas', '536366', 'info:StockCode', '22629'
put 'vendas', '536366', 'info:Description', 'DOLLY GIRL BEAKER'
put 'vendas', '536366', 'info:Quantity', '6'
put 'vendas', '536366', 'info:InvoiceDate', '01/12/2010 08:26'
put 'vendas', '536366', 'info:UnitPrice', '3.25'
put 'vendas', '536366', 'info:CustomerID', '17850'
put 'vendas', '536366', 'info:Country', 'United Kingdom'
```

### 4.2. Consultando Dados (get)

Para obter uma linha específica da tabela `vendas` usando sua `row key` (que é o `InvoiceNo`):

```hbase-shell
get 'vendas', '536365'
```

Você também pode especificar uma família de colunas ou uma coluna específica:

```hbase-shell
get 'vendas', '536365', {COLUMN => 'info:Description'}
```

### 4.3. Varrendo Dados (scan)

Para varrer (scan) todas as linhas da tabela `vendas` ou um intervalo de linhas. O `README.md` do seu projeto já sugere um `scan` com `LIMIT` para verificar a importação:

```hbase-shell
scan 'vendas', {LIMIT => 5}
```

Para varrer um intervalo de `row keys` (InvoiceNo):

```hbase-shell
scan 'vendas', {STARTROW => '536365', ENDROW => '536367'}
```

Você pode adicionar filtros para refinar a varredura, por exemplo, para ver apenas algumas colunas:

```hbase-shell
scan 'vendas', {COLUMNS => ['info:InvoiceNo', 'info:Description', 'info:Quantity'], LIMIT => 10}
```

### 4.4. Deletando Dados (delete/deleteall)

Para deletar uma célula específica na tabela `vendas`:

```hbase-shell
delete 'vendas', '536365', 'info:Country'
```

Para deletar todos os dados de uma linha específica na tabela `vendas`:

```hbase-shell
deleteall 'vendas', '536365'
```

## 5. Sair do Shell HBase

Para sair do shell HBase, digite `exit`:

```hbase-shell
exit
```

## 6. Parando e Removendo o Ambiente Docker

Quando terminar de usar o ambiente HBase, você pode pará-lo e remover os containers e volumes associados. Certifique-se de sair do shell do HBase e do container `hbase-master` antes de executar este comando no seu terminal local (fora do container):

```bash
docker-compose down
```

Este comando irá parar e remover os containers, redes e volumes criados pelo `docker-compose up`. Se você quiser remover também as imagens Docker baixadas, pode usar `docker-compose down --rmi all`.

Este tutorial cobriu os comandos essenciais para interagir com o Apache HBase Shell dentro do seu ambiente Docker. Para funcionalidades mais avançadas, consulte a documentação oficial do Apache HBase.

