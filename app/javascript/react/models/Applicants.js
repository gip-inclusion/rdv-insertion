import { makeAutoObservable } from "mobx"

class Applicants {
  constructor() {
    this.list = []
    makeAutoObservable(this)
  }
  
  addApplicant(applicant) {
    this.list.push(applicant)
  }

  setApplicants(applicants) {
    this.list = applicants
  }

  get selectedApplicants() {
    return this.list.filter((applicant) => applicant.selected)
  }

  get invalidFirsts() {
    return this.list.slice().sort((a, b) => {
      if (a.isValid !== b.isValid) {
        return a.isValid ? 1 : -1;
      }
      return null
    })
  }
}

export default new Applicants()