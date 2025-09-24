# Azure Landing Zone Mini (Bicep + Policy)

Minimal, reproducible Azure landing zone showcasing platform engineering fundamentals: hub/spoke networking, diagnostics, and secure defaults via Policy. One-liner deploys with environment parameters.

[![CI – WhatIf](https://img.shields.io/github/actions/workflow/status/OWNER/REPO/whatif.yml?branch=main)](https://github.com/OWNER/REPO/actions/workflows/whatif.yml)
![Bicep](https://img.shields.io/badge/Bicep-%F0%9F%92%AA-0a84ff)
![Azure](https://img.shields.io/badge/Azure-Ready-0072C6)
![License: MIT](https://img.shields.io/badge/License-MIT-green)

> Replace `OWNER/REPO` with your GitHub org/user and repository name. The CI badge is optional (sample workflow shown below).

---

## What this delivers

- **Hub & Spoke VNets** with peering
- **Central Log Analytics** workspace
- **Policy assignments** (built‑in Allowed Locations + Custom “Require Tags”)
- **Diagnostics wiring stub** (extend per resource)
- **Parametrized environments** (`dev/uat/prod`) + **one‑liner** deploy scripts

---

## Repo layout

```text
azure-landing-zone-mini-bicep/
├─ bicep/
│  ├─ main.bicep
│  └─ modules/
│     ├─ hub.bicep
│     ├─ spoke.bicep
│     ├─ peering.bicep
│     ├─ log-analytics.bicep
│     ├─ diag-settings.bicep
│     └─ policy-assignments.bicep
├─ params/
│  ├─ dev.parameters.json
│  ├─ uat.parameters.json
│  └─ prod.parameters.json
├─ scripts/
│  ├─ deploy.ps1
│  └─ whatif.ps1
└─ docs/
   └─ architecture.md
```

---

## Quick start

> Prereqs: Azure CLI logged in (`az login`), Resource Group contributor rights.

```powershell
# Select your subscription
az account set --subscription "<SUB-ID>"

# Dry run (WhatIf)
pwsh ./scripts/whatif.ps1 -Location eastus -Env dev

# Deploy
pwsh ./scripts/deploy.ps1 -Location eastus -Env dev
```

Outputs: hub/spoke VNets (peered), Log Analytics workspace, policy assignments applied at RG scope.

---

## Parameters (examples)

`params/dev.parameters.json`
```json
{
  "env":   { "value": "dev" },
  "tags":  { "value": { "env": "dev", "owner": "platform" } },
  "hubCidr":   { "value": "10.100.0.0/24" },
  "spokeCidr": { "value": "10.101.0.0/24" }
}
```

`bicep/main.bicep` (key params)
```bicep
param env string = 'dev'
param location string = resourceGroup().location
param tags object = { env: env, owner: 'platform' }
param hubCidr string = '10.100.0.0/24'
param spokeCidr string = '10.101.0.0/24'
```

---

## Modules overview

- **hub.bicep / spoke.bicep** – create VNets + subnets
- **peering.bicep** – bidirectional peering
- **log-analytics.bicep** – central LA workspace
- **diag-settings.bicep** – placeholder to standardize diagnostics
- **policy-assignments.bicep** – built‑in *Allowed Locations* + custom *Require Tags*

`policy-assignments.bicep` highlights:
```bicep
resource builtinAllowed 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'e56962a6-4747-49cd-b67b-bf8b01975c4c' // Allowed locations
}

resource requireTags 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-tags'
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Require specific tags'
    // modify effect adds missing tags at RG creation
  }
}
```

---

## Deploy scripts

`scripts/whatif.ps1`
```powershell
param([string]$Location="eastus",[ValidateSet("dev","uat","prod")][string]$Env="dev")
$rg="alz-$Env-rg"
az group create -n $rg -l $Location --tags env=$Env owner=platform | Out-Null
az deployment group what-if -g $rg -f ./bicep/main.bicep -p @("./params/$Env.parameters.json")
```

`scripts/deploy.ps1`
```powershell
param([string]$Location="eastus",[ValidateSet("dev","uat","prod")][string]$Env="dev")
$rg="alz-$Env-rg"
az group create -n $rg -l $Location --tags env=$Env owner=platform | Out-Null
az deployment group create -g $rg -f ./bicep/main.bicep -p @("./params/$Env.parameters.json")
```

---

## (Optional) CI: What‑If on PRs

Place at `.github/workflows/whatif.yml` and update `OWNER/REPO` in the badge.

```yaml
name: whatif
on:
  pull_request:
    paths: ["bicep/**", "params/**", "scripts/**", ".github/workflows/whatif.yml"]
jobs:
  whatif:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - name: WhatIf (dev)
        run: |
          pwsh ./scripts/whatif.ps1 -Location eastus -Env dev
```

Set `AZURE_CREDENTIALS` as a GitHub secret (JSON for a federated or service principal auth).

---

## Troubleshooting

- **Policy assignment errors** – ensure your account has `Resource Policy Contributor` at RG/sub scope.  
- **Address space overlap** – adjust `hubCidr` / `spokeCidr`.  
- **Missing diagnostics** – extend `diag-settings.bicep` per resource type.  
- **Different region** – pass `-Location` to scripts and update `allowedLocations` in policy if needed.

---

## Security notes

- Enforce required tags (`env`, `owner`) via custom policy.  
- Limit creation to specific regions with *Allowed Locations*.  
- Keep LA retention/cost in check; adjust SKU and `retentionInDays`.  
- Use branch protection + PR reviews for infra changes.

---

## Roadmap

- Private DNS + Private Endpoints for common PaaS services  
- Budget + alerting policies  
- Optional hub firewall & UDR  
- Workbook dashboards for platform observability

---

## License & Author

MIT — feel free to copy and adapt.

**Ulysses Grant, IV**  
[LinkedIn](https://www.linkedin.com/in/usgrant4/) 
[GitHub](https://github.com/usgrant4)

---
