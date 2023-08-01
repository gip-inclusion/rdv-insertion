import React from "react";
import { observer } from "mobx-react-lite";
import Applicant from "./Applicant";

export default observer(({
  applicants,
  isDepartmentLevel,
  downloadInProgress,
  setDownloadInProgress,
  showReferentColumn,
  showCarnetColumn,
}) => applicants.invalidFirsts.map((applicant) => (
  <Applicant
      applicant={applicant}
      isDepartmentLevel={isDepartmentLevel}
      downloadInProgress={downloadInProgress}
      setDownloadInProgress={setDownloadInProgress}
      key={applicant.uniqueKey}
      showReferentColumn={showReferentColumn}
      showCarnetColumn={showCarnetColumn}
    />
)));