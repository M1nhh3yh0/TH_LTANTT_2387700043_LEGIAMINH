#!/usr/bin/env bash
# Mo phong GitLab Runner thuc thi cac job trong .gitlab-ci.yml (muc 6.2.1)
# Dung de minh hoa / lay log cuc bo khi chua day code len GitLab.com
set -e

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; NC='\033[0m'
export GITLAB_USER_LOGIN="legiaminh"
export CI_COMMIT_BRANCH="main"

run_job () {
  local name="$1"; local stage="$2"; shift 2
  echo -e "${CYAN}Running with gitlab-runner 17.4.0 (local-sim)${NC}"
  echo -e "${CYAN}  on local-runner  LEGIAMINH${NC}"
  echo -e "${YELLOW}Preparing the \"docker\" executor${NC}"
  echo -e "${YELLOW}Preparing environment${NC}"
  echo -e "${YELLOW}Executing \"step_script\" stage of the job script${NC}"
  echo -e "${GREEN}\$ job: ${name}  (stage: ${stage})${NC}"
  for cmd in "$@"; do
    echo -e "${GREEN}\$ ${cmd}${NC}"
    eval "$cmd"
  done
  echo -e "${GREEN}Job succeeded${NC}"
  echo "------------------------------------------------------------"
}

echo "============================================================"
echo "   PIPELINE #1 (DON GIAN) - stage: build -> test -> deploy"
echo "============================================================"

# ---- stage: build ----
run_job "build-job" "build" \
  'echo "Hello, $GITLAB_USER_LOGIN!"'

# ---- stage: test (2 job chay song song trong GitLab) ----
run_job "test-job1" "test" \
  'echo "This job tests something"'

run_job "test-job2" "test" \
  'echo "This job tests something, but takes more time than test-job1."' \
  'echo "After the echo commands complete, it runs the sleep command for 20 seconds"' \
  'echo "which simulates a test that runs 20 seconds longer than test-job1"' \
  'sleep 2   # rut ngan de demo (goc: sleep 20)'

# ---- stage: deploy ----
run_job "deploy-prod" "deploy" \
  'echo "This job deploys something from the $CI_COMMIT_BRANCH branch."'

echo -e "${GREEN}>>> Pipeline PASSED: 4/4 job thanh cong (build 1, test 2, deploy 1)${NC}"
