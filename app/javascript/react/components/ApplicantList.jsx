import React from "react";
import Applicant from "./Applicant";

export default function ApplicantList({
  applicants,
  isDepartmentLevel,
  downloadInProgress,
  setDownloadInProgress,
  showReferentColumn,
}) {
  return applicants.map(({ applicant }) => (
    <Applicant
      applicant={applicant}
      isDepartmentLevel={isDepartmentLevel}
      downloadInProgress={downloadInProgress}
      setDownloadInProgress={setDownloadInProgress}
      key={applicant.affiliationNumber + applicant.role}
      showReferentColumn={showReferentColumn}
    />
  ));
}
