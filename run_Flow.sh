#!/bin/bash
run_flow() {
  local flow="$1"
  echo "Running flow: $flow"
  if maestro test "$flow"; then
    echo "Flow $flow completed successfully."
  else
    echo "Flow $flow failed, but continuing with the next flow..." | tee -a Failed_tests_for_Task.log
  fi
}
flows=(
  "open_app.yaml"
  "Auth/Empty_Subdomain.yaml"
  "Auth/Invalid_Subdomain.yaml"
  "Auth/Empty_Login.yaml"
  "Auth/Invalid_Login.yaml"
  "Auth/Login.yaml"
  "In_Out/intime.yaml"
  "In_Out/outtime.yaml"
  "BreakTime/breaktime.yaml"
  "Task/new_task.yaml"
  "Task/status_change.yaml"
  "Task/view_task.yaml"
  "Task/update_task.yaml"
  "CheckInOut/checkin.yaml"
  "CheckInOut/checkout.yaml"
  "Claim/new_claim.yaml"
  "Claim/update_claim.yaml"
  "Claim/view_claim.yaml"
  "Claim/delete_claim.yaml"
  "Directory/directory.yaml"
  "Assets/assets.yaml"
  "Auth/Logout.yaml"
)


for flow in "${flows[@]}"; do
  run_flow "$flow"
done
echo "All flows executed."