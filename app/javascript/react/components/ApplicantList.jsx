import React from "react";
import Applicant from "./Applicant";

export default function ApplicantList({ applicants, dispatchApplicants }) {
  return applicants.map(({ applicant }) => (
    <Applicant applicant={applicant} dispatchApplicants={dispatchApplicants} />
  ));
}
