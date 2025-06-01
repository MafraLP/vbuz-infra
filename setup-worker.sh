#!/bin/bash

# setup-worker.sh - Comandos para configurar o worker

echo "🔧 Configurando Queue Worker para VBUZ..."

# 1. Criar o Dockerfile.worker no diretório correto
echo "📁 Criando Dockerfile.worker..."
if [ ! -f "../vbuz-webserver/Dockerfile.worker" ]; then
    echo "❌ Primeiro crie o arquivo ../vbuz-webserver/Dockerfile.worker com o conteúdo fornecido"
    exit 1
fi

# 2. Parar containers atuais
echo "⏹️  Parando containers..."
docker-compose down

# 3. Buildar o worker
echo "🏗️  Buildando worker container..."
docker-compose build queue-worker

if [ $? -ne 0 ]; then
    echo "❌ Erro ao buildar o worker. Verifique o Dockerfile.worker"
    exit 1
fi

# 4. Subir todos os containers
echo "🚀 Subindo containers..."
docker-compose up -d

# 5. Aguardar containers iniciarem
echo "⏳ Aguardando containers iniciarem..."
sleep 10

# 6. Verificar status
echo "📊 Verificando status dos containers..."
docker-compose ps

# 7. Verificar logs do worker
echo "📝 Logs iniciais do worker:"
docker-compose logs queue-worker

# 8. Testar conexão com banco
echo "🔍 Testando conexão com banco..."
docker exec vbuz-app php artisan migrate:status

# 9. Verificar se worker está processando
echo "👷 Verificando se worker está ativo..."
docker exec vbuz-queue-worker supervisorctl status

echo ""
echo "✅ Setup concluído!"
echo ""
echo "🎯 Próximos passos:"
echo "1. Execute: ./queue-monitor.sh para monitorar"
echo "2. Teste criando uma rota com vários pontos"
echo "3. Acompanhe os logs: docker-compose logs -f queue-worker"
echo ""
echo "🆘 Se algo der errado:"
echo "   - Verifique os logs: docker-compose logs queue-worker"
echo "   - Reinicie o worker: docker-compose restart queue-worker"
echo "   - Entre no container: docker exec -it vbuz-queue-worker bash"