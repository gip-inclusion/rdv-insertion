import React from "react";
import Tippy from "@tippyjs/react";
import { observer } from "mobx-react-lite";

import UserBatchActions from "./UserBatchActions";
import UserRow from "./User";

export default observer(({users}) => (
  <>
    <div className="container mt-5 mb-5">
      <div className="row my-1" style={{ height: 50 }}>
        <div className="d-flex justify-content-end align-items-center">
          <UserBatchActions users={users} />
          <i className="fas fa-user" />
          {users.showReferentColumn ? (
            <Tippy content="Cacher colonne référent">
              <button
                type="button"
                onClick={() => {
                  users.showReferentColumn = false;
                }}
              >
                <i className="fas fa-minus" />
              </button>
            </Tippy>
          ) : (
            <Tippy content="Montrer colonne référent">
              <button
                type="button"
                onClick={() => {
                  users.showReferentColumn = true;
                }}
              >
                <i className="fas fa-plus" />
              </button>
            </Tippy>
          )}
        </div>
      </div>
    </div>
    <div className="my-5 px-4" style={{ overflow: "scroll" }}>
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
            <UserRow user={user} key={user.uniqueKey} />
          ))}
        </tbody>
      </table>
    </div>
  </>
));
