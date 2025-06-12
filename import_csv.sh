#!/bin/bash

# === CONFIGURAÇÕES ===
TABLE_NAME="vendas"
FAMILY="info"
CSV_FILE="/data.csv"               # Caminho do CSV original
LINES_PER_BATCH=1000              # Tamanho do lote
TMP_DIR="/tmp/import_hbase_lotes"
mkdir -p "$TMP_DIR"

# Cria a tabela no HBase (ignora erro se já existir)
echo "create '$TABLE_NAME', '$FAMILY'" | hbase shell 2>/dev/null

# Remove cabeçalho e salva sem cabeçalho
CSV_NO_HEADER="$TMP_DIR/sem_cabecalho.csv"
tail -n +2 "$CSV_FILE" > "$CSV_NO_HEADER"

# Conta número total de linhas
TOTAL_LINES=$(wc -l < "$CSV_NO_HEADER")
TOTAL_BATCHES=$(( (TOTAL_LINES + LINES_PER_BATCH - 1) / LINES_PER_BATCH ))

echo "Importando $TOTAL_LINES linhas em $TOTAL_BATCHES lotes de $LINES_PER_BATCH linhas..."

# Processa lote a lote
for (( i=0; i<TOTAL_BATCHES; i++ ))
do
  START=$(( i * LINES_PER_BATCH + 1 ))
  END=$(( START + LINES_PER_BATCH - 1 ))
  BATCH_FILE="$TMP_DIR/lote_${i}.csv"
  HBASE_SCRIPT="$TMP_DIR/script_${i}.hbase"

  # Extrai o lote do CSV
  sed -n "${START},${END}p" "$CSV_NO_HEADER" > "$BATCH_FILE"
  
  # Gera o script do HBase
  > "$HBASE_SCRIPT"

  while IFS=',' read -r InvoiceNo StockCode Description Quantity InvoiceDate UnitPrice CustomerID Country
  do
    InvoiceNo=$(echo "$InvoiceNo" | tr -d '\r')
    [ -z "$InvoiceNo" ] && continue  # pula se chave for vazia

    # Limpa campos
    StockCode=$(echo "$StockCode" | tr -d '"' | sed "s/'//g")
    Description=$(echo "$Description" | tr -d '"' | sed "s/'//g")
    Quantity=$(echo "$Quantity" | tr -d '"' | sed "s/'//g")
    InvoiceDate=$(echo "$InvoiceDate" | tr -d '"' | sed "s/'//g")
    UnitPrice=$(echo "$UnitPrice" | tr -d '"' | sed "s/'//g")
    CustomerID=$(echo "$CustomerID" | tr -d '"' | sed "s/'//g")
    Country=$(echo "$Country" | tr -d '"' | sed "s/'//g")

    echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:StockCode', '$StockCode'" >> "$HBASE_SCRIPT"
    echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:Description', '$Description'" >> "$HBASE_SCRIPT"
    echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:Quantity', '$Quantity'" >> "$HBASE_SCRIPT"
    echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:InvoiceDate', '$InvoiceDate'" >> "$HBASE_SCRIPT"
    echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:UnitPrice', '$UnitPrice'" >> "$HBASE_SCRIPT"
    echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:CustomerID', '$CustomerID'" >> "$HBASE_SCRIPT"
    echo "put '$TABLE_NAME', '$InvoiceNo', '$FAMILY:Country', '$Country'" >> "$HBASE_SCRIPT"
  done < "$BATCH_FILE"

  echo "Executando lote $((i+1))/$TOTAL_BATCHES..."
  hbase shell "$HBASE_SCRIPT"

done

echo "✅ Importação concluída."

