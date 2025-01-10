import { Controller } from "@hotwired/stimulus"
import CrispScript from "../components/crisp-script"

export default class extends Controller {
  static values = {
    userEmail: String,
    userNickname: String,
    userCrispToken: String
  }

  connect() {
    const user = {
      email: this.userEmailValue,
      nickname: this.userNicknameValue,
      crispToken: this.userCrispTokenValue
    }
    this.crispInstance = new CrispScript(user);
  }
}
