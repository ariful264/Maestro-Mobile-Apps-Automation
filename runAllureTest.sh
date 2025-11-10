#!/bin/bash

# Allure-enabled test runner for piHR App
# Runs Maestro tests, parses JUnit XML for failures, and generates Allure reports

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ALLURE_RESULTS_DIR="allure-results"
REPORTS_DIR="reports"
FAILED_LOG="failed_results.log"

# Create necessary directories
mkdir -p "$ALLURE_RESULTS_DIR"
mkdir -p "$REPORTS_DIR"

# Clean previous results
echo -e "${BLUE}🧹 Cleaning previous test results...${NC}"
rm -rf "$ALLURE_RESULTS_DIR"/*
rm -f "$FAILED_LOG"
rm -f "$REPORTS_DIR"/*.xml

# Function to run individual test flow
run_flow() {
    local flow="$1"
    local test_name=$(basename "$flow" .yaml)
    local suite_name=$(dirname "$flow" | sed 's/\/Test$//' | sed 's/.*\///')

    echo -e "${YELLOW}🧪 Running: $flow${NC}"

    # Create unique JUnit output file
    local output_file="$REPORTS_DIR/${suite_name}_${test_name}_output.xml"

    # Run Maestro test (always exit 0 even on failure, so we must parse)
    maestro test "$flow" --format junit --output "$output_file" > "$REPORTS_DIR/tmp.log" 2>&1

    # Parse JUnit XML for failures
    if grep -q "<failure" "$output_file"; then
        echo -e "${RED}❌ Flow $flow failed${NC}"
        echo "Flow $flow failed" >> "$FAILED_LOG"
        create_allure_result "$flow" "failed" "Assertion failure in Maestro test"
        return 1
    else
        echo -e "${GREEN}✅ Flow $flow completed successfully${NC}"
        create_allure_result "$flow" "passed" ""
        return 0
    fi
}

# Function to create Allure result file
create_allure_result() {
    local test_path="$1"
    local status="$2"
    local error_message="$3"

    local test_name=$(basename "$test_path" .yaml)
    local suite_name=$(dirname "$test_path" | sed 's/\/Test$//' | sed 's/.*\///')
    local uuid=$(uuidgen 2>/dev/null || echo "$(date +%s)-$(basename "$test_path")")
    local timestamp=$(date +%s%3N)
    local start_time=$((timestamp - 5000)) # Assume ~5s test duration

    cat > "$ALLURE_RESULTS_DIR/${uuid}-result.json" << EOF
{
  "uuid": "$uuid",
  "historyId": "$(echo -n "${suite_name}.${test_name}" | base64)",
  "fullName": "${suite_name}.${test_name}",
  "name": "$test_name",
  "status": "$status",
  "statusDetails": {
    "message": "$error_message",
    "trace": "$error_message"
  },
  "stage": "finished",
  "start": $start_time,
  "stop": $timestamp,
  "labels": [
    { "name": "suite", "value": "$suite_name" },
    { "name": "framework", "value": "Maestro" },
    { "name": "language", "value": "YAML" },
    { "name": "feature", "value": "$suite_name" }
  ],
  "links": []
}
EOF
}

# Test flows to execute
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
  "CheckInOut/supervision_Check.yaml"

  "Claim/new_claim.yaml"
  "Claim/update_claim.yaml"
  "Claim/view_claim.yaml"
  "Claim/delete_claim.yaml"

  "Directory/directory.yaml"

  "Notice/create_new_notice.yaml"
  "Notice/view_notice.yaml"

  "Assets/assets.yaml"
  "Assets/useradmin_assets_distribution_create.yaml"
  "Assets/useradmin_assets_distribution_update.yaml"
  "Assets/useradmin_assets_distribution_complete.yaml"
  "Assets/useradmin_assets_distribution_delete.yaml"

  "MyProfile/check_myprofile.yaml"
  "Myprofile/profile_pic_upload_byfiles.yaml"
  "Myprofile/profile_pic_upload_bycamera.yaml"

  "ChangePassword/create_new_password.yaml"

  "Attendance/attendance_view.yaml"
  "Attendance/recon_application_view.yaml"
  "Attendance/subordinate_view.yaml"
  "Attendance/recon_approval.yaml"
  "Attendance/face_registration.yaml"
  "Attendance/giveintime_face_att.yaml"
  "Attendance/giveouttime_face_att.yaml"
  "Attendance/employee_monitoring.yaml"

  "AttendanceRemainder/attendace_remainder_create.yaml"

  "Leave/halfday_leave-apply.yaml"
  "Leave/leave_continuous_sacntion.yaml"
  "Leave/attchment_require-leave.yaml"
  "Leave/pendingone_reapply_leave.yaml"
  "Leave/allow_check_reliever_leave.yaml"
  "Leave/approved_leave_application.yaml"
  "Leave/rejected_leave_application.yaml"
  "Leave/approved_visit_application.yaml"
  "Leave/rejected_visit_application.yaml"

  "Payroll/salary_Check.yaml"
  "Payroll/advance_salary_bycash.yaml"
  "Payroll/advance_salary_update.yaml"
  "Payroll/advance_salary_delete.yaml"

  "P.Fund/view_pf.yaml"
  
  "Auth/Logout.yaml"
)


echo -e "${BLUE}🚀 Starting piHR App Test Suite with Allure Reporting${NC}"
echo -e "${BLUE}📱 App: com.vivacomsolutions.pihr.client${NC}"
echo -e "${BLUE}🕐 Started at: $(date)${NC}"
echo ""

# Execute all test flows
total_tests=${#flows[@]}
passed_tests=0
failed_tests=0

for flow in "${flows[@]}"; do
    if [[ -f "$flow" ]]; then
        run_flow "$flow"
        if [[ $? -eq 0 ]]; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
    else
        echo -e "${RED}⚠️  Test file not found: $flow${NC}"
        echo "Flow $flow missing" >> "$FAILED_LOG"
        create_allure_result "$flow" "broken" "Test file not found"
        ((failed_tests++))
    fi
done

# Generate environment info for Allure
cat > "$ALLURE_RESULTS_DIR/environment.properties" << EOF
Framework=Maestro
App=piHR (com.vivacomsolutions.pihr.client)
Platform=Mobile
Test.Environment=${TEST_ENV:-Development}
OS=$(uname -s)
Execution.Date=$(date)
Total.Tests=$total_tests
Passed.Tests=$passed_tests
Failed.Tests=$failed_tests
EOF

# Generate categories for better reporting
cat > "$ALLURE_RESULTS_DIR/categories.json" << 'EOF'
[
  {
    "name": "Authentication Failures",
    "matchedStatuses": ["failed"],
    "messageRegex": ".*login.*|.*auth.*|.*credential.*"
  },
  {
    "name": "UI Element Not Found",
    "matchedStatuses": ["failed"],
    "messageRegex": ".*not found.*|.*element.*|.*visible.*"
  },
  {
    "name": "Timeout Issues",
    "matchedStatuses": ["failed"],
    "messageRegex": ".*timeout.*|.*wait.*"
  },
  {
    "name": "App Launch Issues",
    "matchedStatuses": ["broken"],
    "messageRegex": ".*launch.*|.*start.*|.*app.*"
  }
]
EOF

# Test execution summary
echo -e "${BLUE}📊 Test Execution Summary${NC}"
echo -e "${BLUE}=========================${NC}"
echo -e "Total Tests: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $failed_tests${NC}"
echo -e "Success Rate: $(( passed_tests * 100 / total_tests ))%"
echo -e "Failed Rate: $(( failed_tests * 100 / total_tests ))%"
echo ""

# Generate and display Allure report instructions
echo -e "${BLUE}📈 Allure Report Generation${NC}"
echo -e "${BLUE}===========================${NC}"
echo -e "Results saved to: ${ALLURE_RESULTS_DIR}/"
echo ""
echo -e "${YELLOW}To generate and view the Allure report:${NC}"
echo -e "  ${GREEN}npm run allure:generate${NC}  # Generate HTML report"
echo -e "  ${GREEN}npm run allure:open${NC}     # Open report in browser"
echo -e "  ${GREEN}npm run allure:serve${NC}    # Generate and serve report"
echo ""

if [[ $failed_tests -gt 0 ]]; then
    echo -e "${RED}⚠️  Some tests failed. Check failed_results.log for details.${NC}"
    exit 1
else
    echo -e "${GREEN}🎉 All tests passed successfully!${NC}"
    exit 0
fi