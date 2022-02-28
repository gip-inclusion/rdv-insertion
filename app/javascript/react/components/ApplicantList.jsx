import React from "react";
import Applicant from "./Applicant";

export default function ApplicantList({
  applicants,
  dispatchApplicants,
  isDepartmentLevel,
  downloadInProgress,
  setDownloadInProgress,
}) {
  return applicants.map(({ applicant }) => (
    <Applicant
      applicant={applicant}
      dispatchApplicants={dispatchApplicants}
      isDepartmentLevel={isDepartmentLevel}
      downloadInProgress={downloadInProgress}
      setDownloadInProgress={setDownloadInProgress}
    />
  ));
}
