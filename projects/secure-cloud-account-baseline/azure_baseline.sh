#!/usr/bin/env bash
# Azure subscription baseline runbook.
# REVIEW BEFORE RUNNING. Replace every <PLACEHOLDER> first.
# These commands apply the controls in the baseline checklist for Azure.

set -euo pipefail

SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
RESOURCE_GROUP="<SECURITY_RG>"
LOCATION="eastus"
WORKSPACE="<LOG_ANALYTICS_WORKSPACE>"
STORAGE_ACCOUNT="<STORAGE_ACCOUNT>"

az account set --subscription "$SUBSCRIPTION_ID"

# 1. Owner accounts: MFA and Conditional Access are configured in
#    Microsoft Entra ID (portal), not by CLI. Enable MFA for all users,
#    block legacy authentication, and protect the two break-glass
#    accounts per the checklist before continuing.

# 2. Defender for Cloud plans on for the resource types that matter first.
az security pricing create --name VirtualMachines --tier Standard
az security pricing create --name SqlServers --tier Standard
az security pricing create --name StorageAccounts --tier Standard

# 3. Storage: no public blob access by default.
az storage account update \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2

# 4. Activity log: route it to the Log Analytics workspace with a
#    diagnostic setting at subscription scope (created in the portal or
#    with az monitor diagnostic-settings subscription create where
#    supported). Confirm logs are flowing before trusting any alert.

# 5. Cost alerts: set budget alerts in Cost Management at 50, 80, and
#    100 percent of the monthly budget for this subscription.

echo "Azure baseline commands complete. Verify each control in the portal and file the evidence."
