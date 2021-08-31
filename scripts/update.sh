#!/bin/bash

env=$1

if [ $CI_ENVIRONMENT_SLUG == "prod" ]; then
  sed -i "s/tag/$CI_ENVIRONMENT_SLUG/g" deployment/manifests/base/emp/emp-deployment.yaml
  sed -i "s/tag/$CI_ENVIRONMENT_SLUG/g" deployment/manifests/base/version/version-deployment.yaml
else
  sed -i "s/tag/$CI_COMMIT_BRANCH/g" deployment/manifests/base/emp/emp-deployment.yaml
  sed -i "s/tag/$CI_COMMIT_BRANCH/g" deployment/manifests/base/version/version-deployment.yaml
  ENDPOINT=`aws rds describe-db-instances --db-instance-identifier $(echo $CI_ENVIRONMENT_NAME |tr "_" "-") --query "DBInstances[*].[Endpoint.Address]" --output text`
  echo "Endpoint: $ENDPOINT"
fi

if [ $CI_ENVIRONMENT_SLUG == "prod" ] || [ $CI_COMMIT_BRANCH == "dev" ]; then
  DEPLOYMENT_FILES=$CI_ENVIRONMENT_SLUG
else
  DEPLOYMENT_FILES="branches"
fi

echo -e "Environment: $env \nCI_COMMIT_REF_NAME: $CI_COMMIT_REF_NAME \nCI_ENVIRONMENT_SLUG: $CI_ENVIRONMENT_SLUG \nCI_ENVIRONMENT_NAME: $CI_ENVIRONMENT_NAME \nCI_COMMIT_BRANCH: $CI_COMMIT_BRANCH \nDEPLOYMENT_FILES: $DEPLOYMENT_FILES"
GIT=`which git`
KUSTOMIZE=`which kustomize`
${GIT} clone https://root:$GIT_PASSWORD@gitlab.moaaznoaman.com/root/argocd.git
echo "cloning successfully..."
cd argocd/
[ ! -d "core/" ] && mkdir core/
[ -d "core/employees-$CI_ENVIRONMENT_SLUG/" ] && rm -rf core/employees-$CI_ENVIRONMENT_SLUG/
mkdir core/employees-$CI_ENVIRONMENT_SLUG/
echo "creating employees-$CI_ENVIRONMENT_SLUG.yaml ..."
sed -e "s/\$CI_ENVIRONMENT_SLUG/$CI_ENVIRONMENT_SLUG/" ../deployment/employees-app.yaml > core/employees-$CI_ENVIRONMENT_SLUG.yaml
echo "Building manifest.yaml file for $CI_ENVIRONMENT_SLUG"
${KUSTOMIZE} build ../deployment/manifests/$DEPLOYMENT_FILES > core/employees-$CI_ENVIRONMENT_SLUG/manifest.yaml
#find core/employees-$CI_ENVIRONMENT_SLUG/ -type f -name "*.yaml" -print0 | xargs -0 sed -i '' -e "s/\$CI_ENVIRONMENT_SLUG/$CI_ENVIRONMENT_SLUG/g"
#find core/employees-$CI_ENVIRONMENT_SLUG/ -type f -exec sed -i "s/\$CI_ENVIRONMENT_SLUG/$CI_ENVIRONMENT_SLUG/g" {} +
echo "replacing core/employees-$CI_ENVIRONMENT_SLUG/manifest.yaml"
sed -i "s/\$CI_ENVIRONMENT_SLUG/$CI_ENVIRONMENT_SLUG/g" core/employees-$CI_ENVIRONMENT_SLUG/manifest.yaml
sed -i "s/BRANCH_RDS_ENDPOINT/$ENDPOINT/g" core/employees-$CI_ENVIRONMENT_SLUG/manifest.yaml
echo "setting image tag to $CI_ENVIRONMENT_SLUG"
git config --global user.email "admin@gitlab.moaaznoaman.com"
git config --global user.name "Administrator"
${GIT} add --all .
${GIT} commit -m "auto-commit from $GITLAB_USER_NAME@$(hostname -s) on $(date)"
gitPush=$(${GIT} push -vvv https://root:$GIT_PASSWORD@gitlab.moaaznoaman.com/root/argocd.git master 2>&1)
echo "$gitPush"
