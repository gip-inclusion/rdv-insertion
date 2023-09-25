import React from "react";
import { observer } from "mobx-react-lite";
import User from "./User";

export default observer(
  ({
    users,
    isDepartmentLevel,
    downloadInProgress,
    setDownloadInProgress,
    showReferentColumn,
    showCarnetColumn,
  }) =>
    users.invalidFirsts.map((user) => (
      <User
        user={user}
        isDepartmentLevel={isDepartmentLevel}
        downloadInProgress={downloadInProgress}
        setDownloadInProgress={setDownloadInProgress}
        key={user.uniqueKey}
        showReferentColumn={showReferentColumn}
        showCarnetColumn={showCarnetColumn}
      />
    ))
);
