#!/bin/bash

ROOT_FOLDER=$(pwd)

OPTIND=1
NO_FORMAT="\033[0m"
F_BOLD="\033[1m"
C_LIME="\033[38;5;10m"
C_RED="\033[38;5;9m"

NAMESPACE="default"
PREFIX=""
LICENSE_KEY=${NEW_RELIC_LICENSE_KEY}
CLUSTER_NAME=""
INSTALL_INFRA_AGENT=false
CHARTS_FOLDER="${ROOT_FOLDER}/charts"
APP_LIST="catalogue-db orders-db user-db rabbitmq carts catalogue orders payment queue-master shipping user front-end"

PROGRAM_NAME=$(basename $0)

function usage() {
  cat <<HEREDOC

   Usage: $PROGRAM_NAME [--help NUM] [--namespace STR] [--namespace STR] [--license-key STR] [--install-newrelic-infra BOOL] [--cluster-name STR]

   optional arguments:
     -h, --help                             Print a summary help and exit.
     -a, --apps                 string      Application list to deploy, single string space separated.
     -c, --cluster-name         string      The cluster name for the Kubernetes cluster if you install the New Relic Infrastructure bundle.
     -l, --license-key          string      The license key for your New Relic Account. This will be the preferred configuration option if you're license-key and the NEW_RELIC_LICENSE_KEY environment variable.
     -n, --namespace            string      Namespace scope for this request
     -p, --prefix               string      Resources prefix
     --install-newrelic-infra   boolean     Install New Relic Kubernetes integration bundle
HEREDOC
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
  -h | --help)
    usage
    exit
    ;;
  -a | --apps)
    APP_LIST="$2"
    shift
    ;;
  -c | --cluster-name)
    CLUSTER_NAME="$2"
    shift
    ;;
  -l | --license-key)
    LICENSE_KEY="$2"
    shift
    ;;
  -n | --namespace)
    NAMESPACE="$2"
    shift
    ;;
  -p | --prefix)
    PREFIX="$2"
    shift
    ;;

  --install-newrelic-infra)
    INSTALL_INFRA_AGENT=$2
    shift
    ;;
  *)
    echo "${F_BOLD}${C_RED}Unknown parameter passed: $1${NO_FORMAT}"
    exit 1
    ;;
  esac
  shift
done

if [ "$INSTALL_INFRA_AGENT" != true ] && [ "$INSTALL_INFRA_AGENT" != false ]; then
  echo "${F_BOLD}${C_RED}ERR: --install-newrelic-infra must be boolean${NO_FORMAT}"
  exit
fi

if [ -z "${LICENSE_KEY}" ]; then
  echo "${F_BOLD}${C_RED}ERR: New Relic License Key is missing${NO_FORMAT}"
  exit
fi

if [ "$INSTALL_INFRA_AGENT" = true ]; then
  if [ -z "${CLUSTER_NAME}" ]; then
    echo "${F_BOLD}${C_RED}ERR: Cluster name is missing${NO_FORMAT}"
    exit
  fi

  echo "${F_BOLD}${C_LIME}Deploying New Relic ${NO_FORMAT}\n"

  helm install newrelic-bundle newrelic/nri-bundle \
    --values "${ROOT_FOLDER}/on-host-integration.yaml" \
    --set global.licenseKey=${LICENSE_KEY} \
    --set global.cluster=${CLUSTER_NAME} \
    --set kubeEvents.enabled=true \
    --set webhook.enabled=true \
    --set prometheus.enabled=true \
    --set logging.enabled=true \
    --set ksm.enabled=true
fi

CHART_NAME_PREFIX=""
if [ -n "${PREFIX}" ]; then
  CHART_NAME_PREFIX=${PREFIX}"-"
fi

echo "${F_BOLD}Namespace:${NO_FORMAT} ${NAMESPACE}\n"
for APP in ${APP_LIST}; do
  PREFIX_FLAG=""
  if [ -n "${PREFIX}" ]; then
    PREFIX_FLAG=" --set prefix="${CHART_NAME_PREFIX}${APP}
  fi
  echo "${F_BOLD}${C_LIME}Installing:${NO_FORMAT} ${APP}"
  cd "${CHARTS_FOLDER}/${APP}" || return
  helm install ${APP} . --namespace=${NAMESPACE} --set newRelic.licenseKey=${LICENSE_KEY} --set mysql.password=fake_password --set namespace=${NAMESPACE} ${PREFIX_FLAG}
  cd "${CHARTS_FOLDER}" || return
  echo "\n"
done

cd "${CHARTS_FOLDER}/rabbitmq" || return
echo "${F_BOLD}${C_LIME}Installing:${NO_FORMAT} Rabbitmq"
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbitmq bitnami/rabbitmq --values=./values.yaml --set auth.username=admin,auth.password=verySECRETpassword -n ${NAMESPACE}
cd "${CHARTS_FOLDER}" || return
echo "\n"

cd "${CHARTS_FOLDER}/load-testing" || return
echo "${F_BOLD}${C_LIME}Installing:${NO_FORMAT} Load Testing"
helm install load-testing . -n ${NAMESPACE}
cd "${CHARTS_FOLDER}" || return
echo "\n"
