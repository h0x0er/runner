#!/usr/bin/env bash
set -u

source logger.sh

function step-log(){
    log.debug "[StepSecurity] $1"
}

step-log "executing custom hook"

step-log "workflow_repository: ${GITHUB_REPOSITORY:-}"
step-log "workflow_repository_owner: ${GITHUB_REPOSITORY_OWNER:-}"
step-log "workflow_name: ${GITHUB_WORKFLOW:-}"
step-log "workflow_run_id: ${GITHUB_RUN_ID:-}"
step-log "workflow_run_number: ${GITHUB_RUN_NUMBER:-}"
step-log "workflow_job: ${GITHUB_JOB:-}"
step-log "workflow_action: ${GITHUB_ACTION:-}"

step-log "done"

