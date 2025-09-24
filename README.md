# Azure Landing Zone Mini (Bicep + Policy)

Minimal hub/spoke landing zone with diagnostics and secure defaults.

## Quick start
```powershell
az login
az account set --subscription "<SUB-ID>"
pwsh ./scripts/whatif.ps1 -Location eastus -Env dev
pwsh ./scripts/deploy.ps1 -Location eastus -Env dev
```
