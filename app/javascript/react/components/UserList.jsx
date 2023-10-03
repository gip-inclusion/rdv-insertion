import React from "react";
import { observer } from "mobx-react-lite";
import User from "./User";

export default observer(
  ({ users }) =>
    users.invalidFirsts.map((user) => (
      <User user={user} key={user.uniqueKey} />
    ))
);
