# Deploy no Google Cloud Run

Este guia explica como fazer o deploy da aplicação Maria Streaming Live no Google Cloud Run usando Docker.

## Pré-requisitos

1. **Google Cloud CLI instalado**
   ```bash
   # Instalar Google Cloud CLI
   # Windows: https://cloud.google.com/sdk/docs/install
   # Linux/macOS: curl https://sdk.cloud.google.com | bash
   ```

2. **Autenticação no Google Cloud**
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

3. **Projeto Google Cloud configurado**
   ```bash
   gcloud config set project SEU-PROJECT-ID
   ```

## Arquivos de Deploy Criados

- `Dockerfile` - Configuração Docker multi-stage para produção
- `nginx.conf` - Configuração do Nginx para servir a aplicação
- `.dockerignore` - Arquivos a serem ignorados no build Docker
- `deploy.sh` - Script de deploy para Linux/macOS
- `deploy.bat` - Script de deploy para Windows
- `cloud-run.yaml` - Configuração declarativa do Cloud Run
- `cloudbuild.yaml` - Configuração do Cloud Build para CI/CD

## Como fazer o Deploy

### Opção 1: Script Automático (Recomendado)

1. **Edite o script de deploy:**
   ```bash
   # No arquivo deploy.sh (Linux/macOS) ou deploy.bat (Windows)
   # Altere PROJECT_ID para o seu Project ID do Google Cloud
   PROJECT_ID="seu-project-id-aqui"
   ```

2. **Execute o script:**
   ```bash
   # Linux/macOS
   chmod +x deploy.sh
   ./deploy.sh
   
   # Windows
   deploy.bat
   ```

### Opção 2: Comandos Manuais

1. **Habilitar APIs necessárias:**
   ```bash
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable run.googleapis.com
   ```

2. **Build da imagem:**
   ```bash
   gcloud builds submit --tag gcr.io/SEU-PROJECT-ID/maria-streaming-console
   ```

3. **Deploy no Cloud Run:**
   ```bash
   gcloud run deploy maria-streaming-console \
     --image gcr.io/SEU-PROJECT-ID/maria-streaming-console \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated \
     --port 8080 \
     --memory 512Mi \
     --cpu 1 \
     --max-instances 10
   ```

### Opção 3: Deploy via Console (UI)

1. Acesse o [Google Cloud Console](https://console.cloud.google.com/)
2. Navegue para Cloud Run
3. Clique em "Create Service"
4. Selecione "Deploy one revision from an existing container image"
5. Use a imagem: `gcr.io/SEU-PROJECT-ID/maria-streaming-console`
6. Configure:
   - Port: 8080
   - Memory: 512 MiB
   - CPU: 1
   - Max instances: 10

## Configurações Importantes

### Variáveis de Ambiente
A aplicação usa as seguintes variáveis de ambiente:
- `NODE_ENV=production` (automaticamente configurada)
- `REACT_APP_GEMINI_API_KEY` (configure via Cloud Run console se necessário)

### Recursos
- **CPU**: 1 vCPU
- **Memória**: 512 MiB
- **Port**: 8080 (obrigatório para Cloud Run)
- **Max Instances**: 10 (para controlar custos)

### Health Check
A aplicação inclui um endpoint de health check em `/health` para monitoramento do Cloud Run.

## Monitoramento e Logs

1. **Ver logs:**
   ```bash
   gcloud logs read --service-name=maria-streaming-console
   ```

2. **Monitorar serviço:**
   ```bash
   gcloud run services describe maria-streaming-console --region=us-central1
   ```

## Custos Estimados

O Cloud Run cobra por uso, com as seguintes métricas:
- vCPU: ~$0.024/h por vCPU
- Memória: ~$0.0025/h por GiB
- Requests: ~$0.40 por 1M requests

Com 512 MiB de RAM e 1 vCPU, o custo será mínimo para aplicações com baixo tráfego devido ao modelo pay-per-use.

## Troubleshooting

### Erro de Build
```bash
# Verificar logs do build
gcloud builds log [BUILD_ID]
```

### Erro de Deploy
```bash
# Verificar status do serviço
gcloud run services describe maria-streaming-console --region=us-central1
```

### Aplicação não responde
1. Verifique se a porta 8080 está configurada
2. Verifique os logs da aplicação
3. Teste o health check endpoint

## CI/CD Automático

Para configurar deploy automático via GitHub/GitLab:

1. Configure o Cloud Build trigger
2. Use o arquivo `cloudbuild.yaml` incluído
3. Configure as variáveis de ambiente no Cloud Build

## Segurança

- A aplicação roda como usuário não-root
- Headers de segurança configurados no Nginx
- HTTPS automático via Cloud Run
- Autenticação pode ser habilitada conforme necessário
