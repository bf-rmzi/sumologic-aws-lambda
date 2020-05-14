#!/bin/sh

export AWS_REGION=$1
export AWS_PROFILE=$2
# App to test
export AppName=$3
export InstallType=$4

export uid=`cat /dev/random | LC_CTYPE=C tr -dc "[:lower:]" | head -c 6`

# Sumo Logic Access Configuration
export Section1aSumoDeployment=$5
export Section1bSumoAccessID=$6
export Section1cSumoAccessKey=$7
export Section1dSumoOrganizationId=$8
export Section1eRemoveSumoResourcesOnDeleteStack=true

export Section2bAccountAlias=${InstallType}
export Section2cFilterExpression=".*"
export Section4bCloudWatchMetricsSourceName="Source-metrics-${AppName}-${InstallType}"
export Section5dS3BucketPathExpression="ALB_LOGS"
export Section5fALBLogsSourceCategoryName="Labs/${AppName}/${InstallType}"
export Section5bS3LogsBucketName="${AppName}-${InstallType}-${uid}"

export Section2aTagExistingAWSResources="No"
export Section3aInstallApp="No"
export Section4aCreateCloudWatchMetricsSource="No"
export Section5aCreateS3Bucket="No"
export Section5cCreateALBLogSource="No"

if [[ "${InstallType}" == "all" ]]
then
    export Section3bCollectorName="Sourabh-Collector-${AppName}-${InstallType}"
    export Section5eALBLogsSourceName="Source-${AppName}-${InstallType}"
    export Section2aTagExistingAWSResources="Yes"
    export Section3aInstallApp="Yes"
    export Section4aCreateCloudWatchMetricsSource="Yes"
    export Section5aCreateS3Bucket="Yes"
    export Section5cCreateALBLogSource="Yes"
elif [[ "${InstallType}" == "onlyapp" ]]
then
    export Section3aInstallApp="Yes"
elif [[ "${InstallType}" == "onlytags" ]]
then
    export Section2aTagExistingAWSResources="Yes"
elif [[ "${InstallType}" == "onlycwsource" ]]
then
    export Section3bCollectorName="Sourabh-Collector-${AppName}-${InstallType}"
    export Section4aCreateCloudWatchMetricsSource="Yes"
elif [[ "${InstallType}" == "onlylogsourcewithbucket" ]]
then
    export Section3bCollectorName="Sourabh-Collector-${AppName}-${InstallType}"
    export Section5eALBLogsSourceName="Source-${AppName}-${InstallType}"
    export Section5aCreateS3Bucket="Yes"
    export Section5cCreateALBLogSource="Yes"
elif [[ "${InstallType}" == "onlylogsourcewithoutbucket" ]]
then
    export Section3bCollectorName="Sourabh-Collector-${AppName}-${InstallType}"
    export Section5eALBLogsSourceName="Source-${AppName}-${InstallType}"
    export Section5cCreateALBLogSource="Yes"
    export Section5bS3LogsBucketName="sumologiclambdahelper-${AWS_REGION}"
elif [[ "${InstallType}" == "updatesourceonly" ]]
then
    export Section3bCollectorName="Sourabh-Collector-alb-onlylogsourcewithoutbucket"
    export Section5eALBLogsSourceName="Source-alb-onlylogsourcewithoutbucket"
elif [[ "${InstallType}" == "nothing" ]]
then
    export Section3bCollectorName=""
    export Section5eALBLogsSourceName=""
else
    echo "No Valid Choice."
fi

# Stack Name
export stackName="${AppName}-${InstallType}"
pwd
aws cloudformation deploy --profile ${AWS_PROFILE} --template-file ./apps/${AppName}/alb_app.template.yaml --region ${AWS_REGION} \
--capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND --stack-name ${stackName} \
--parameter-overrides Section1aSumoDeployment="${Section1aSumoDeployment}" Section1bSumoAccessID="${Section1bSumoAccessID}" \
Section1cSumoAccessKey="${Section1cSumoAccessKey}" Section1dSumoOrganizationId="${Section1dSumoOrganizationId}" \
Section1eRemoveSumoResourcesOnDeleteStack="${Section1eRemoveSumoResourcesOnDeleteStack}" Section2bAccountAlias="${Section2bAccountAlias}" \
Section2cFilterExpression="${Section2cFilterExpression}" Section3bCollectorName="${Section3bCollectorName}" \
Section4bCloudWatchMetricsSourceName="${Section4bCloudWatchMetricsSourceName}" Section5dS3BucketPathExpression="${Section5dS3BucketPathExpression}" \
Section5eALBLogsSourceName="${Section5eALBLogsSourceName}" Section5fALBLogsSourceCategoryName="${Section5fALBLogsSourceCategoryName}" \
Section2aTagExistingAWSResources="${Section2aTagExistingAWSResources}" Section3aInstallApp="${Section3aInstallApp}" \
Section4aCreateCloudWatchMetricsSource="${Section4aCreateCloudWatchMetricsSource}" Section5aCreateS3Bucket="${Section5aCreateS3Bucket}" \
Section5cCreateALBLogSource="${Section5cCreateALBLogSource}" Section5bS3LogsBucketName="${Section5bS3LogsBucketName}"

