import React from "react";
import Tippy from "@tippyjs/react";
import { observer } from "mobx-react-lite";

export default observer(({ users }) => (
  <Tippy content={users.showReferentColumn ? "Cacher colonne référent" : "Montrer colonne référent"}>
    <button
      type="button"
      className={users.showReferentColumn ? "btn btn-blue show-referent-button" : "btn btn-blue-out"}
      style={{ cursor: "pointer" }}
      onClick={() => { users.showReferentColumn = !users.showReferentColumn } }
    >
      <i className="ri-user-line" />
      <i className={users.showReferentColumn ? "ri-subtract-line" : "ri-add-line"} />
    </button>
  </Tippy>
));
