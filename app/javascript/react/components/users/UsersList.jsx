import React from "react";
import { observer } from "mobx-react-lite";

import UserTableRow from "../user/TableRow";

export default observer(({ users }) => (
  <div className="mt-3 mb-5 px-4" style={{ overflow: "scroll" }}>
    <table className="table table-hover text-center align-middle table-striped table-bordered">
      <thead className="align-middle dark-blue">
        <tr>
          {users.columns.map((column) => {
            if (!column.visible) return null;

            return (
              <th {...column.attributes} key={column.name}>
                {column.header({ column, users })}
              </th>
            );
          })}
        </tr>
      </thead>
      <tbody>
        {users.sorted.map((user) => (
          <UserTableRow user={user} key={user.uniqueKey} />
        ))}
      </tbody>
    </table>
  </div>
));
