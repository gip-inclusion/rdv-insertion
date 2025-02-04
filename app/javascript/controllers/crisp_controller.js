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
      // If the user is logged out (displayCrispValue is false) but crisp is still loaded, we logout the user from crisp
      if (window.$crisp) {
        this.logout();
      }
      return;
    }

    // safe mode is enabled to avoid console warnings related to MutationObserver modifications
    window.$crisp = window.$crisp || [];
    window.$crisp.push(["safe", true]);
    this.#setupMutationObserverOverride();

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
    this.handleFirstVisit();
  }

  initCrisp(user) {
    window.$crisp = [];
    window.CRISP_WEBSITE_ID = process.env.CRISP_WEBSITE_ID;

    // Ajout du safe mode pour supprimer l'avertissement dans la console lié aux modifs du MutationObserver
    window.$crisp.push(["safe", true]);

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

  handleFirstVisit() {
    const firstVisit = localStorage.getItem("crispFirstVisit");
    if (!firstVisit) {
      window.$crisp.push(["on", "session:loaded", () => {
        window.$crisp.push(["do", "chat:open"]);
        localStorage.setItem("crispFirstVisit", "true");
      }]);
    }
  }

  logout() {
    if (window.$crisp) {
      window.CRISP_WEBSITE_ID = undefined;
      window.CRISP_TOKEN_ID = undefined;
      window.$crisp.push(["do", "session:reset"]);
      window.$crisp.push(["do", "session:destroy"]);
      window.$crisp.push(["do", "chat:hide"]);
    }
  }

  #setupMutationObserverOverride() {
    // Fix for solving Crisp/Turbo incompatibility : https://github.com/crisp-im/crisp-sdk-web/issues/39
    if (!window.originalMutationObserver) {
      window.originalMutationObserver = window.MutationObserver
      window.listOfObservers = [];

      window.MutationObserver = function(aFunction) {
        /* eslint new-cap: ["error", { "newIsCap": false }] */

        const observer = new window.originalMutationObserver(aFunction);
        const { stack } = new Error();

        if (stack?.includes("crisp")) {
          window.listOfObservers.push(observer);
        }

        return observer;
      };

      window.CRISP_READY_TRIGGER = () => this.#onCrispReady();
    }
  }

  #disconnectAllObservers() {
    window.listOfObservers?.forEach((observer) => {
      observer.disconnect();
    });
  }

  #reconnectAllObservers() {
    window.listOfObservers?.forEach((observer) => {
      observer.reconnect();
    });
  }

  #moveCrispToPermanentContainer() {
    const crispWidget = document.querySelector(".crisp-client");
    const crispWrapper = document.getElementById("crisp-wrapper");

    if (crispWidget && crispWrapper && !crispWrapper.contains(crispWidget)) {
      this.#disconnectAllObservers();
      crispWrapper.appendChild(crispWidget);
      this.#reconnectAllObservers();
    }
  }

  #onCrispReady() {
    this.#moveCrispToPermanentContainer();
  }
}
