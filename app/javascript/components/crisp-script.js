class CrispScriptTag {
  constructor(user = null) {
    this.initCrisp();
    this.setUserData(user);
    this.loadScript();
  }

  initCrisp() {
    window.$crisp = [];
    window.CRISP_WEBSITE_ID = process.env.CRISP_WEBSITE_ID;
  }

  setUserData(user) {
    if (user) {
      window.CRISP_TOKEN_ID = user.crispToken
      window.$crisp.push(["set", "user:email", [user.email]]);
      window.$crisp.push(["set", "user:nickname", [user.nickname]]);
    }
  }

  loadScript() {
    if (!document.querySelector("script[src=\"https://client.crisp.chat/l.js\"]")) {
      const crispScriptTag = document.createElement("script");
      crispScriptTag.async = true;
      crispScriptTag.src = "https://client.crisp.chat/l.js";

      const firstScriptTag = document.getElementsByTagName("head")[0];
      firstScriptTag.appendChild(crispScriptTag);
    }
  }
}

export default CrispScriptTag;
