import React from "react";
import Applicant from "./Applicant";

export default function ApplicantList({ applicants, dispatchApplicants, organisation }) {
  return applicants.map(({ applicant }) => (
    <Applicant
      applicant={applicant}
      dispatchApplicants={dispatchApplicants}
      organisation={organisation}
    />
  ));
}
