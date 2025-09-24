param(
  [string]$Location = "eastus",
  [ValidateSet("dev","uat","prod")][string]$Env = "dev"
)
$rg = "alz-$Env-rg"
az group create -n $rg -l $Location --tags env=$Env owner=platform | Out-Null
az deployment group what-if -g $rg -f ./bicep/main.bicep -p @("./params/$Env.parameters.json")
