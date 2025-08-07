@echo off
REM Script para fazer deploy no Google Cloud Run (Windows)
REM Certifique-se de ter o Google Cloud CLI instalado e autenticado

REM Definir variáveis
set PROJECT_ID=seu-project-id
set SERVICE_NAME=maria-streaming-console
set REGION=us-central1
set IMAGE_NAME=gcr.io/%PROJECT_ID%/%SERVICE_NAME%

echo 🚀 Iniciando deploy no Google Cloud Run...

REM Verificar se está logado no Google Cloud
gcloud auth list --filter=status:ACTIVE --format="value(account)" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Erro: Você não está autenticado no Google Cloud
    echo Execute: gcloud auth login
    exit /b 1
)

REM Definir o projeto
echo 📋 Definindo projeto: %PROJECT_ID%
gcloud config set project %PROJECT_ID%

REM Habilitar APIs necessárias
echo 🔧 Habilitando APIs necessárias...
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com

REM Build da imagem usando Cloud Build
echo 🏗️  Fazendo build da imagem...
gcloud builds submit --tag %IMAGE_NAME%

REM Deploy no Cloud Run
echo 🚀 Fazendo deploy no Cloud Run...
gcloud run deploy %SERVICE_NAME% ^
    --image %IMAGE_NAME% ^
    --platform managed ^
    --region %REGION% ^
    --allow-unauthenticated ^
    --port 8080 ^
    --memory 512Mi ^
    --cpu 1 ^
    --max-instances 10 ^
    --set-env-vars "NODE_ENV=production"

echo ✅ Deploy concluído!
echo 🌐 Sua aplicação estará disponível em:
gcloud run services describe %SERVICE_NAME% --region=%REGION% --format="value(status.url)"

pause
