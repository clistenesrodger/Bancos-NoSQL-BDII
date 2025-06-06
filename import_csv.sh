#!/bin/bash

TABLE_NAME="vendas"
FAMILY="info"
CSV_FILE="/data.csv"
HBASE_SCRIPT="/tmp/hbase_bulk_put.txt"

# Cria a tabela se não existir
echo "create '$TABLE_NAME', '$FAMILY'" | hbase shell 2>/dev/null

# Prepara o script HBase
echo -n "" > $HBASE_SCRIPT

# Lê o CSV (ignorando o cabeçalho)
tail -n +2 "$CSV_FILE" | while IFS=, read -r InvoiceNo StockCode Description Quantity InvoiceDate UnitPrice CustomerID Country
do
  # Remove espaços extras e possíveis quebras de linha
  InvoiceNo=$(echo "$InvoiceNo" | tr -d '\r')
  echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:StockCode', '$StockCode'" >> $HBASE_SCRIPT
  echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:Description', '$Description'" >> $HBASE_SCRIPT
  echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:Quantity', '$Quantity'" >> $HBASE_SCRIPT
  echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:InvoiceDate', '$InvoiceDate'" >> $HBASE_SCRIPT
  echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:UnitPrice', '$UnitPrice'" >> $HBASE_SCRIPT
  echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:CustomerID', '$CustomerID'" >> $HBASE_SCRIPT
  echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:Country', '$Country'" >> $HBASE_SCRIPT
done

# Executa tudo de uma vez só no HBase shell
hbase shell $HBASE_SCRIPT
