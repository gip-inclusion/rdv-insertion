import React from "react";
import Applicant from "./Applicant";

export default function ApplicantList({ applicants, dispatchApplicants, isDepartmentLevel }) {
  return applicants.map(({ applicant }) => (
    <Applicant
      applicant={applicant}
      dispatchApplicants={dispatchApplicants}
      isDepartmentLevel={isDepartmentLevel}
    />
  ));
}
