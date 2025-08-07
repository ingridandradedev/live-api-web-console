#!/bin/bash

# Script para fazer deploy no Google Cloud Run
# Certifique-se de ter o Google Cloud CLI instalado e autenticado

# Definir variáveis
PROJECT_ID="seu-project-id"  # Substitua pelo seu Project ID
SERVICE_NAME="maria-streaming-console"
REGION="us-central1"  # Altere se necessário
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo "🚀 Iniciando deploy no Google Cloud Run..."

# Verificar se está logado no Google Cloud
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 > /dev/null; then
    echo "❌ Erro: Você não está autenticado no Google Cloud"
    echo "Execute: gcloud auth login"
    exit 1
fi

# Definir o projeto
echo "📋 Definindo projeto: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Habilitar APIs necessárias
echo "🔧 Habilitando APIs necessárias..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com

# Build da imagem usando Cloud Build
echo "🏗️  Fazendo build da imagem..."
gcloud builds submit --tag $IMAGE_NAME

# Deploy no Cloud Run
echo "🚀 Fazendo deploy no Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_NAME \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10 \
    --set-env-vars "NODE_ENV=production"

echo "✅ Deploy concluído!"
echo "🌐 Sua aplicação estará disponível em:"
gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)"
