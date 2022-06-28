import { Controller } from "@hotwired/stimulus";
import { navigator } from "@hotwired/turbo"

export default class extends Controller {
  submit() {
    console.log("my lord")
    navigator.submitForm(this.element.closest("form"))
  }

  submitEnd(e) {
    console.log("detail", e.detail.formSubmission)
    console.log("detail",e.detail.formSubmissionResult)

  }
}
