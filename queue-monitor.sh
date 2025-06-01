#!/bin/bash

# queue-monitor.sh - Monitoramento para sua estrutura

echo "=== 🚀 MONITORAMENTO DA QUEUE VBUZ ==="

# Verificar status dos containers
echo "📦 Status dos Containers:"
docker-compose ps

echo ""
echo "👥 Processos do Worker:"
docker exec vbuz-queue-worker supervisorctl status 2>/dev/null || echo "Worker não está rodando ou não responde"

echo ""
echo "📊 Jobs na Fila:"
docker exec vbuz-app php artisan queue:monitor 2>/dev/null || echo "Erro ao acessar fila"

echo ""
echo "❌ Jobs Falhados:"
docker exec vbuz-app php artisan queue:failed 2>/dev/null || echo "Erro ao acessar jobs falhados"

echo ""
echo "📈 Estatísticas do Banco:"
docker exec vbuz-app php artisan tinker --execute="
try {
    echo 'Jobs pendentes: ' . DB::table('jobs')->count() . PHP_EOL;
    echo 'Jobs falhados: ' . DB::table('failed_jobs')->count() . PHP_EOL;
    echo 'Últimos 5 jobs:' . PHP_EOL;
    DB::table('jobs')->latest('created_at')->take(5)->get(['id', 'queue', 'created_at'])->each(function(\$job) {
        echo '  - Job #' . \$job->id . ' na fila: ' . \$job->queue . ' criado em: ' . \$job->created_at . PHP_EOL;
    });
} catch (Exception \$e) {
    echo 'Erro ao acessar banco: ' . \$e->getMessage() . PHP_EOL;
}
" 2>/dev/null || echo "Erro ao executar consultas no banco"

echo ""
echo "📝 Últimas linhas do log do worker:"
docker exec vbuz-queue-worker tail -n 20 /var/www/storage/logs/worker.log 2>/dev/null || echo "Log do worker não encontrado"

echo ""
echo "📝 Últimas linhas do log Laravel:"
docker exec vbuz-app tail -n 10 /var/www/storage/logs/laravel.log 2>/dev/null || echo "Log Laravel não encontrado"

echo ""
echo "=== 🔧 COMANDOS ÚTEIS ==="
echo "Reiniciar worker:      docker-compose restart queue-worker"
echo "Ver logs worker:       docker-compose logs -f queue-worker"
echo "Ver logs app:          docker-compose logs -f app"
echo "Limpar queue:          docker exec vbuz-app php artisan queue:clear"
echo "Processar 1 job:       docker exec vbuz-app php artisan queue:work --once"
echo "Entrar no worker:      docker exec -it vbuz-queue-worker bash"
echo "Entrar no app:         docker exec -it vbuz-app bash"
echo "Status supervisor:     docker exec vbuz-queue-worker supervisorctl status"
echo "Reiniciar supervisor:  docker exec vbuz-queue-worker supervisorctl restart all"