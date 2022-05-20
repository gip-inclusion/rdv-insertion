import React from "react";
import Applicant from "./Applicant";

export default function ApplicantList({
  applicants,
  isDepartmentLevel,
  downloadInProgress,
  setDownloadInProgress,
}) {
  return applicants.map(({ applicant }, i) => (
    <Applicant
      applicant={applicant}
      isDepartmentLevel={isDepartmentLevel}
      downloadInProgress={downloadInProgress}
      setDownloadInProgress={setDownloadInProgress}
      key={`${applicant.uid}${i}`} // eslint-disable-line react/no-array-index-key
    />
  ));
}
