#!/bin/bash

# Cria a tabela se não existir
echo "create 'vendas', 'info'" | hbase shell 2>/dev/null

# Importa os dados do CSV
tail -n +2 /data.csv | while IFS=, read -r InvoiceNo StockCode Description Quantity InvoiceDate UnitPrice CustomerID Country
do
  echo "put 'vendas', '$InvoiceNo', 'info:StockCode', '$StockCode'" | hbase shell -n
  echo "put 'vendas', '$InvoiceNo', 'info:Description', '$Description'" | hbase shell -n
  echo "put 'vendas', '$InvoiceNo', 'info:Quantity', '$Quantity'" | hbase shell -n
  echo "put 'vendas', '$InvoiceNo', 'info:InvoiceDate', '$InvoiceDate'" | hbase shell -n
  echo "put 'vendas', '$InvoiceNo', 'info:UnitPrice', '$UnitPrice'" | hbase shell -n
  echo "put 'vendas', '$InvoiceNo', 'info:CustomerID', '$CustomerID'" | hbase shell -n
  echo "put 'vendas', '$InvoiceNo', 'info:Country', '$Country'" | hbase shell -n
done