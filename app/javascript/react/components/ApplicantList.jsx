import React from "react";
import Applicant from "./Applicant";

export default function ApplicantList({ applicants, dispatchApplicants, contactsData, isDepartmentLevel }) {

  return applicants.map(({ applicant }) => (
    <Applicant
      applicant={applicant}
      dispatchApplicants={dispatchApplicants}
      contactsData={contactsData}
      isDepartmentLevel={isDepartmentLevel}
    />
  ));
}
