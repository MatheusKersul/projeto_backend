#!/bin/bash
set -e

# Configurações
APP_PORT=${PORT:-3001}
APP_NAME="meu-backend"
MAX_RETRIES=30
RETRY_DELAY=2

echo "===== Iniciando validação robusta (JSON) ====="

check_http_health() {
  curl -f -s -o /dev/null http://localhost:$APP_PORT/ || return 1
  return 0
}

check_pm2_health() {
  # 1. Verifica se PM2 existe
  if ! command -v pm2 >/dev/null 2>&1; then
    echo "✗ PM2 não encontrado no PATH"
    return 1
  fi

  # 2. Pega o status real usando JSON (muito mais seguro que grep na tabela)
  # Isso extrai apenas o status do processo com o nome exato
  PM2_STATUS=$(pm2 jlist | grep -o "\"name\":\"$APP_NAME\".*\"status\":\"[^\"]*\"" | grep -o "\"status\":\"[^\"]*\"" | cut -d'"' -f4)

  if [ -z "$PM2_STATUS" ]; then
    echo "✗ Processo $APP_NAME não encontrado na lista do PM2"
    # Debug: mostrar o que tem lá
    pm2 jlist | grep "name"
    return 1
  fi

  echo "ℹ️  Status atual do PM2: [$PM2_STATUS]"

  if [ "$PM2_STATUS" == "online" ]; then
    return 0
  else
    echo "✗ Esperado 'online', mas encontrei '$PM2_STATUS'"
    # Se estiver com erro, mostra o log do erro imediatamente
    if [ "$PM2_STATUS" == "errored" ]; then
        echo "=== LOGS DE ERRO DO PM2 ==="
        pm2 logs $APP_NAME --lines 15 --nostream --err
        echo "==========================="
    fi
    return 1
  fi
}

# Loop de Tentativas
for i in $(seq 1 $MAX_RETRIES); do
  echo "--- Tentativa $i de $MAX_RETRIES ---"

  if check_pm2_health; then
    echo "✓ PM2: Processo online!"
    
    if check_http_health; then
      echo "✓ HTTP: Respondendo na porta $APP_PORT"
      echo "=== ✓ SUCESSO TOTAL ==="
      exit 0
    else
      echo "⚠️  HTTP: Porta $APP_PORT ainda não responde..."
    fi
  else
    echo "⚠️  PM2 ainda não está pronto..."
  fi

  if [ $i -lt $MAX_RETRIES ]; then
    sleep $RETRY_DELAY
  fi
done

echo "=== ✗ Falha: Timeout após $MAX_RETRIES tentativas ==="
exit 1
