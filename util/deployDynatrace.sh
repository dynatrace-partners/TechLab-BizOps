#!/bin/bash


export API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
export PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')
export TENANTID=$(cat creds.json | jq -r '.dynatraceTenantID')
export ENVIRONMENTID=$(cat creds.json | jq -r '.dynatraceEnvironmentID')

echo "Deploying Dynatrace Oneagent using the following credentials: "
echo "API_TOKEN = $API_TOKEN"
echo "PAAS_TOKEN = $PAAS_TOKEN"
echo "TENANTID = $TENANTID"
echo "ENVIRONMENTID (Dynatrace Managed) = $ENVIRONMENTID"

echo ""
read -p "Is this all correct? (y/n) : " -n 1 -r
echo ""



deployOneAgent()
{

	case $ENVIRONMENTID in
			'')
			echo "SaaS Deplyoment.."
			#sed -i 's/apiUrl: https:\/\/ENVIRONMENTID.live.dynatrace.com\/api/apiUrl: https:\/\/'$TENANTID'.live.dynatrace.com\/api/' cr.yaml
			wget  -O Dynatrace-OneAgent-Linux.sh --header="Authorization: Api-Token "$PAAS_TOKEN "https://"$TENANTID".live.dynatrace.com/api/v1/deployment/installer/agent/unix/default/latest?arch=x86&flavor=default"
			;;
			*)
			echo "Managed Deployment.."
			#sed -i 's/apiUrl: https:\/\/ENVIRONMENTID.live.dynatrace.com\/api/apiUrl: https:\/\/'$TENANTID'.dynatrace-managed.com\/e\/'$ENVIRONMENTID'\/api/' cr.yaml
			wget  -O Dynatrace-OneAgent-Linux.sh --header="Authorization: Api-Token "$PAAS_TOKEN "https://"$TENANTID".live.dynatrace.com/e/"$ENVIRONMENTID"/api/v1/deployment/installer/agent/unix/default/latest?arch=x86&flavor=default"
			;;
	esac
	
	echo "Installing Dynatrace OneAgent.."
	sudo /bin/sh Dynatrace-OneAgent-Linux.sh APP_LOG_CONTENT_ACCESS=1 INFRA_ONLY=0
	echo "Restarting easyTravel..."
	cd ~
	./restart_easyTravel.sh
	cd Workshop-BizOps/util
	
}

deployApplicationConfig()
{
	## Create Application

}

if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Download Dynatrace OneAgent from Cluster..."
	deployOneAgent
	deployApplicationConfig
else
    exit 1
fi
