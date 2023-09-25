import { makeAutoObservable } from "mobx";

class Users {
  constructor() {
    this.list = [];
    this.loading = false;
    makeAutoObservable(this);
  }

  addUser(user) {
    this.list.push(user);
  }

  setUsers(users) {
    this.list = users;
  }

  setLoading(loading) {
    this.loading = loading;
  }

  get selectedUsers() {
    return this.list.filter((user) => user.selected);
  }

  get invalidFirsts() {
    return this.list.slice().sort((a, b) => {
      if (a.isValid !== b.isValid) {
        return a.isValid ? 1 : -1;
      }
      return null;
    });
  }
}

export default new Users();
