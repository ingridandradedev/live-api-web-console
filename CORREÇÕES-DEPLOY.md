# Correções Aplicadas para o Deploy no Cloud Run

## Problemas Identificados e Soluções

### 1. **Erro Principal**: Dependências de Teste Ausentes
**Problema**: O Dockerfile estava instalando apenas dependências de produção (`--only=production`), mas o build precisa das dependências de desenvolvimento.

**Solução**: Mudei para `npm ci` (sem flags) para instalar todas as dependências.

### 2. **Babel Plugin Missing**
**Problema**: Faltava o plugin `@babel/plugin-proposal-private-property-in-object`.

**Solução**: Adicionei ao `devDependencies` no `package.json`.

### 3. **Arquivos de Teste Causando Conflitos**
**Problema**: Arquivos `.test.tsx` podem causar problemas no build de produção.

**Solução**: 
- Remoção automática de arquivos de teste durante o build Docker
- Criação de script `build:docker` otimizado
- Atualização do `.dockerignore`

### 4. **Configuração de Ambiente**
**Problema**: Variáveis de ambiente não configuradas adequadamente.

**Solução**: 
- Criado `.env.production` com configurações otimizadas
- Configurado flags para build otimizado (sem sourcemaps)

## Arquivos Modificados

### `Dockerfile`
- ✅ Mudança de `npm ci --only=production` para `npm ci`
- ✅ Remoção de arquivos de teste antes do build
- ✅ Uso do script `build:docker` otimizado

### `package.json`
- ✅ Adicionado `@babel/plugin-proposal-private-property-in-object`
- ✅ Criado script `build:docker` com flags CI=true
- ✅ Criado script `build:prod` otimizado

### `.dockerignore`
- ✅ Exclusão de arquivos de teste
- ✅ Permitir `.env.production` 
- ✅ Otimizado para builds Docker

### `.env.production`
- ✅ Configurações de produção
- ✅ Flags para build otimizado
- ✅ Chave API incluída (arquivo deve ficar no .gitignore)

### `.gitignore`
- ✅ Adicionado `.env.production` para segurança

## Como Fazer o Deploy Agora

### Opção 1: Via Cloud Build (Recomendado)
```bash
# No diretório do projeto
gcloud builds submit --tag gcr.io/SEU-PROJECT-ID/maria-streaming-console
```

### Opção 2: Via Script
```bash
# Edite deploy.bat ou deploy.sh com seu PROJECT_ID
# Windows:
deploy.bat

# Linux/macOS:
./deploy.sh
```

### Opção 3: Build Local e Push
```bash
# Build local
docker build -t maria-streaming-console .

# Tag para GCR
docker tag maria-streaming-console gcr.io/SEU-PROJECT-ID/maria-streaming-console

# Push
docker push gcr.io/SEU-PROJECT-ID/maria-streaming-console

# Deploy
gcloud run deploy maria-streaming-console \
  --image gcr.io/SEU-PROJECT-ID/maria-streaming-console \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated
```

## Verificar se Funcionou

1. **Build local**: `npm run build:docker`
2. **Docker build local**: `docker build -t test .`
3. **Executar local**: `docker run -p 8080:8080 test`

## Notas Importantes

- ⚠️ O arquivo `.env.production` contém sua chave API - mantenha-o no `.gitignore`
- ✅ A região foi mantida como `europe-west1` conforme seu deploy anterior
- ✅ Todas as otimizações de produção foram aplicadas
- ✅ Health check endpoint configurado em `/health`

## Próximos Passos

1. Commit as alterações (exceto `.env.production`)
2. Execute o deploy usando uma das opções acima
3. Verifique os logs no Cloud Build/Cloud Run
4. Teste a aplicação no URL fornecido pelo Cloud Run
