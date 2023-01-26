#!/bin/bash

az_sub="Narato - Playground"
az_rg="rg-kdg-demo-01"

az login
az account set --subscription "$az_sub"

az deployment group create --template-file "infrastructure/bicep/infra/main.bicep" --resource-group "$az_rg" --parameters aksSshPublicKey="$(cat infrastructure/bicep/infra/keys/id_rsa.pub)"

az aks get-credentials --resource-group "$az_rg" --name "aks-kdg-demo-01" --admin
az aks update --resource-group "$az_rg" -n "aks-kdg-demo-01" --attach-acr "kdgdemo01" --only-show-errors -o none
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm upgrade --install keda kedacore/keda --namespace keda --create-namespace