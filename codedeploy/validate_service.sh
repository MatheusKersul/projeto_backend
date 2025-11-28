#!/bin/bash
set -eux

# Executar healthcheck do diretório atual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== DIAGNÓSTICO PRÉ-VALIDAÇÃO ==="
# Mostra quem é o usuário rodando
whoami
# Mostra onde está rodando
pwd
# Mostra a lista REAL do PM2 antes de rodar o teste
pm2 list || echo "PM2 comando falhou"
# Mostra logs de erro se existirem
pm2 logs meu-backend --lines 20 --nostream || true
echo "================================"

bash "$SCRIPT_DIR/healthcheck.sh"
