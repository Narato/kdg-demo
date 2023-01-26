#!/bin/bash

az_sub="Narato - Playground"
az_rg="rg-kdg-demo-01"
tag=$(git rev-parse HEAD)

az login
az account set --subscription "$az_sub"

az acr login --name "kdgdemo01"
az aks get-credentials --resource-group "$az_rg" --name "aks-kdg-demo-01" --admin --overwrite-existing

docker buildx build "src/frontend" --platform linux/amd64 -f "src/frontend/Containerfile" -t "kdgdemo01.azurecr.io/kdg-demo-frontend:$tag"
docker buildx build "src/session-scaler" --platform linux/amd64 -f "src/session-scaler/Containerfile" -t "kdgdemo01.azurecr.io/kdg-demo-scaler:$tag"
docker push "kdgdemo01.azurecr.io/kdg-demo-frontend:$tag"
docker push "kdgdemo01.azurecr.io/kdg-demo-scaler:$tag"

output=$(az deployment group create --template-file "infrastructure/bicep/app/main.bicep" --resource-group "$az_rg" --parameters tag="$tag")
helm upgrade --install "kdg-demo" infrastructure/helm --namespace "kdg-demo" --create-namespace --set scaler.tag="$tag" --set scaler.endpoint=$(echo "$output" | jq -r '.properties.outputs.frontendFqdn.value')