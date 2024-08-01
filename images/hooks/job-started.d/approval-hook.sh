#!/usr/bin/env bash
set -u
source logger.sh

step-log-debug () { log.debug "[StepSecurity] $1"; }
step-log-error () { log.error "[StepSecurity] $1"; }
step-log-success  () { log.success "[StepSecurity] $1"; }
step-log-warning  () { log.warning "[StepSecurity] $1"; }
step-log-notice  () { log.notice "[StepSecurity] $1"; }



GITHUB_REPOSITORY=${GITHUB_REPOSITORY:-}
GITHUB_RUN_ID=${GITHUB_RUN_ID:-}
GITHUB_SHA=${GITHUB_SHA:-}

ERROR_COUNT=0
ERROR_RESP=""


api_base="https://int.api.stepsecurity.io/v1"
should_ci_run="$api_base/github/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID/should-ci-run"


function handleResponse(){
    local resp=${1}
    local lastStatus=${2}

    local err
    echo "$resp" | grep -q "error"  > /dev/null
    err=$?
    if [[ $err -eq 0 ]] || [[ $lastStatus -ne 0 ]]; then
        # step-log-error "error response received: $resp"
        ERROR_COUNT=$((ERROR_COUNT += 1))
        ERROR_RESP="$resp"
    fi
    
    if [[ $ERROR_COUNT -eq 4 ]]; then
        step-log-error "error occured: $ERROR_RESP"
        exit 1
    fi


    local isApproved
    echo "$resp" | grep -q "approved_by" > /dev/null
    isApproved=$?
    if [[ $isApproved -eq 0 ]]; then

        approver=$(echo "$resp" | jq '.approved_by')
        step-log-success "approved by: $approver"
        step-log-notice "continuing job"
        exit 0

    fi

}

function printApprovalInfo(){

    step-log-notice "approval_url: https://int1.stepsecurity.io/github/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/approve-ci-run"

    step-log-debug "$should_ci_run"
    step-log-notice "waiting to be approved.."

}


function main(){

    local resp
    local counter
    local maxWait

    counter=0
    maxWait=60 # wait for 5 minutes
    
    printApprovalInfo

    while [[ $counter -ne $maxWait ]]; do
        # step-log-debug "[$counter] waiting.."

        resp=$(curl -XGET -s "${should_ci_run}")
        handleResponse "${resp}" $?

        counter=$((counter += 1))
        sleep 5

    done

    step-log-warning "no-one approved run, waited for maximum time"
    step-log-warning "failing job"

    exit 1

}


main









