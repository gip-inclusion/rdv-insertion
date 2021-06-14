class LoginForm {
  constructor() {
    this.loginForm = document.getElementById('js-login-form');
    if (this.loginForm === null) return;

    this.attachListeners()
  }


  attachListeners() {
    this.loginForm.addEventListener("submit", (event) => {
      event.preventDefault()
      event.stopPropagation()
      this.signIn()
    })
  }

  async signIn() {
    this.buttonForm = this.loginForm.querySelector("input[type=submit]");
    this.setButtonPending();
    this.email = this.loginForm.querySelector("input[type=email]").value;
    this.password = this.loginForm.querySelector("input[type=password]").value;
    this.departmentId = this.loginForm.querySelector("input[name=department_id]").value;
    this.formAuthenticityToken = this.loginForm.querySelector("input[name=authenticity_token]").value;
    this.headerAuthenticityToken = document.querySelector("meta[name=csrf-token]").content;

    if (this.email === '' || this.password === '') {
      alert("L\'email et le mot de passe doivent être renseignés");
      this.resetButton();
      return;
    }

    let result = await this.loginToRdv()

    if (result.body.success === false) {
      alert(`Impossible de s'authentifier: ${result.body.errors[0]}`)
      this.resetButton();
      return;
    }
    console.log("result.body", result.body)
    let signInResult = await this.createSession(
      result.headers.get("access-token"),
      result.headers.get("uid"),
      result.headers.get("client")
    );
    if (signInResult.success === true) {
      window.location.href = signInResult.redirect_path;
    } else {
      alert("Quelque chose d'inhabituel s'est produit, veuillez contacter l'équipe par mail"
        + " à data.insertion@beta.gouv.fr pour pouvoir vous connecter")
      this.resetButton();
    }
  }

  async createSession(accessToken, uid, client) {
    let response = await fetch('/sessions', {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.headerAuthenticityToken
      },
      body: JSON.stringify({
        access_token: accessToken,
        uid: uid,
        client: client,
        department_id: this.departmentId,
        authenticity_token: this.formAuthenticityToken,
      })
    })
    return await response.json()
  }

  setButtonPending() {
    this.buttonForm.value = 'Connexion...'
  }

  resetButton() {
    this.buttonForm.value = 'Se connecter'
  }

  async loginToRdv() {
    let rdvSolidaritesUrl = process.env.RDV_SOLIDARITES_URL

    let response = await fetch(`${rdvSolidaritesUrl}/api/v1/auth/sign_in`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: this.email,
        password: this.password
      })
    });

    return {
      body: await response.json(),
      headers: response.headers
    }
  }
}

export { LoginForm }
