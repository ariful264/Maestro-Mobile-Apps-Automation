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


for flow in "${flows[@]}"; do
  run_flow "$flow"
done
echo "All flows executed."