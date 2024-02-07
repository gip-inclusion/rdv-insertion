import React from "react";
import { observer } from "mobx-react-lite";

export default observer(({ users }) => {
  const toggle = () => {
    const dropdown = document.getElementById("batch-actions");
    dropdown.classList.toggle("show");
  };

  const deleteAll = () => {
    toggle();
    users.setUsers(users.list.filter((user) => !user.selected));
  };

  const inviteBy = async (format) => {
    toggle();
    // We need a synchronous loop with await here to avoid sending too many requests at the same time
    // eslint-disable-next-line no-restricted-syntax
    for (const user of users.selectedUsers) {
      // eslint-disable-next-line no-await-in-loop
      await user.inviteBy(format, { raiseError: false });
    }
  };

  const createAccounts = async () => {
    toggle();
    // We need a synchronous loop here to avoid sending too many requests at the same time
    // eslint-disable-next-line no-restricted-syntax
    for (const user of users.selectedUsers) {
      // eslint-disable-next-line no-await-in-loop
      await user.createAccount({ raiseError: false });
    }
  };

  const noUserSelected = !users.list.some((user) => user.selected);

  return (
    <div style={{ marginRight: 20, position: "relative" }}>
      <button
        type="button"
        className="btn btn-primary dropdown-toggle"
        onClick={toggle}
        disabled={noUserSelected}
      >
        Actions pour toute la sélection
      </button>
      <div className="dropdown-menu" id="batch-actions">
        {users.comesFromUploadFile && (
          <button
            type="button"
            className="dropdown-item d-flex justify-content-between align-items-center"
            onClick={createAccounts}
          >
            <span>Créer comptes</span>
            <i className="fas fa-user" />
          </button>
        )}
        {users.canBeInvitedBy("email") && (
          <button
            type="button"
            className="dropdown-item d-flex justify-content-between align-items-center"
            onClick={() => inviteBy("email")}
          >
            <span>Invitation par mail</span>
            <i className="fas fa-inbox" />
          </button>
        )}
        {users.canBeInvitedBy("sms") && (
          <button
            type="button"
            className="dropdown-item d-flex justify-content-between align-items-center"
            onClick={() => inviteBy("sms")}
          >
            <span>Invitation par sms</span>
            <i className="fas fa-comment" />
          </button>
        )}
        {users.canBeInvitedBy("postal") && (
          <button
            type="button"
            className="dropdown-item d-flex justify-content-between align-items-center"
            onClick={() => inviteBy("postal")}
          >
            <span>Invitation par courrier &nbsp;</span>
            <i className="fas fa-envelope" />
          </button>
        )}
        <button
          type="button"
          className="dropdown-item d-flex justify-content-between align-items-center"
          onClick={deleteAll}
        >
          <span>Cacher la sélection</span>
          <i className="fas fa-eye-slash" />
        </button>
      </div>
    </div>
  );
});
