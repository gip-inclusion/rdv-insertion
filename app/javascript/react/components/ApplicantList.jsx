import React from "react";
import Applicant from "./Applicant";

export default function ApplicantList({ applicants, dispatchApplicants, department }) {
  return applicants.map(({ applicant }) => (
    <Applicant
      applicant={applicant}
      dispatchApplicants={dispatchApplicants}
      department={department}
    />
  ));
}
