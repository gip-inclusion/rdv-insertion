import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    displayCrisp: Boolean,
    userEmail: String,
    userNickname: String,
    userCrispToken: String,
  };

  connect() {
    if (!this.displayCrispValue) {
      // If the crisp chat is disabled and the user is still logged in, we logout the user
      if (window.$crisp) { this.logout(); };
      return;
    }

    if (window.CRISP_TOKEN_ID === this.userCrispTokenValue) {
      // If the user is already logged in, we don't need to do anything
      return;
    }

    const user = {
      email: this.userEmailValue,
      nickname: this.userNicknameValue,
      crispToken: this.userCrispTokenValue,
    };

    this.initCrisp(user);
  }

  initCrisp(user) {
    window.$crisp = [];
    window.CRISP_WEBSITE_ID = process.env.CRISP_WEBSITE_ID;

    if (user) {
      window.CRISP_TOKEN_ID = user.crispToken;
      window.$crisp.push(["set", "user:email", [user.email]]);
      window.$crisp.push(["set", "user:nickname", [user.nickname]]);
    }

    if (!document.querySelector("script[src='https://client.crisp.chat/l.js']")) {
      const crispScriptTag = document.createElement("script");
      crispScriptTag.async = true;
      crispScriptTag.src = "https://client.crisp.chat/l.js";

      const firstScriptTag = document.getElementsByTagName("head")[0];
      firstScriptTag.appendChild(crispScriptTag);
    }
  }

  logout() {
    if (window.$crisp) {
      window.CRISP_TOKEN_ID = null;
      window.$crisp.push(["do", "session:reset"]);
      window.$crisp.push(["do", "session:destroy"]);
      window.$crisp.push(["do", "chat:hide"]);
    }
  }
}
