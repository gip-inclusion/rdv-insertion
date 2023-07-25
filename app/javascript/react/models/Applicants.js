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
}

export default new Applicants()