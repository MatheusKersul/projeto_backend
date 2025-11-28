module.exports = {
  apps: [{
    name: 'meu-backend',
    cwd: '/opt/apps/backend/current', // <--- ADICIONE ISSO AQUI (Mude se seu caminho for outro)
    script: './src/index.js',         // Agora o ponto (.) vai funcionar
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'aws',
      PORT: 3001,
      SECRET_NAME: 'money2-backend-dev-secret-rds',
      AWS_REGION: 'us-east-1',
      JWT_SECRET: process.env.JWT_SECRET || ''
    },
    // DICA: Use caminhos absolutos para logs também, para não perder eles
    error_file: '/opt/apps/backend/current/logs/pm2-error.log',
    out_file: '/opt/apps/backend/current/logs/pm2-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    time: true
  }]
};
