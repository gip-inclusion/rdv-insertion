import Swal from 'sweetalert2'

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
    this.formAuthenticityToken = this.loginForm.querySelector("input[name=authenticity_token]").value;
    this.headerAuthenticityToken = document.querySelector("meta[name=csrf-token]").content;

    if (this.email === '' || this.password === '') {
      alert("L\'email et le mot de passe doivent être renseignés");
      this.resetButton();
      return;
    }

    let loginRdvResult = await this.loginToRdv()

    if (loginRdvResult.body.success === false) {
      Swal.fire("Impossible de s'authentifier" , `${loginRdvResult.body.errors[0]}`, "warning")
      this.resetButton();
      return;
    }

    let rdvSolidaritesSession = {
      accessToken:  loginRdvResult.headers.get("access-token"),
      uid: loginRdvResult.headers.get("uid"),
      client: loginRdvResult.headers.get("client")
    }

    let organisationsResult = await this.retrieveOrganisations(rdvSolidaritesSession)
    console.log("organisationsResult", organisationsResult)

    let organisationIds = organisationsResult.organisations.map(o => o.id)

    let signInResult = await this.createSession(
      rdvSolidaritesSession, organisationIds
    );

    if (signInResult.success === true) {
      window.location.href = signInResult.redirect_path;
    } else {
      Swal.fire(
        "Une erreur s'est produite: " + signInResult.errors[0],
        "Veuillez contacter l'équipe par mail à data.insertion@beta.gouv.fr pour pouvoir vous connecter.",
        "warning"
      )
      this.resetButton();
    }
  }

  async createSession(rdvSolidaritesSession, organisationIds) {
    let response = await fetch('/sessions', {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.headerAuthenticityToken
      },
      body: JSON.stringify({
          access_token: rdvSolidaritesSession.accessToken,
          uid: rdvSolidaritesSession.uid,
          client: rdvSolidaritesSession.client,
          organisation_ids: organisationIds,
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

  async retrieveOrganisations(rdvSolidaritesSession) {
    let response = await fetch(
      `${process.env.RDV_SOLIDARITES_URL}/api/v1/organisations`,
      {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "access-token": rdvSolidaritesSession.accessToken,
          "uid": rdvSolidaritesSession.uid,
          "client": rdvSolidaritesSession.client
        },
      }
    )

    return await response.json()
  }

  async loginToRdv() {
    let response = await fetch(
      `${process.env.RDV_SOLIDARITES_URL}/api/v1/auth/sign_in`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: this.email,
          password: this.password
        })
      }
    );

    return {
      body: await response.json(),
      headers: response.headers
    }
  }
}

export { LoginForm }
