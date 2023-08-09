import { makeAutoObservable } from "mobx"

class OrganisationTags {
  constructor() {
    this.list = []
    makeAutoObservable(this)
  }

  setTags(tags) {
    this.list = tags
  }
}

export default new OrganisationTags()