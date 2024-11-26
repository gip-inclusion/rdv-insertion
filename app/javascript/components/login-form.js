import Swal from "sweetalert2";

class LoginForm {
  constructor() {
    this.loginForm = document.getElementById("js-login-form");
    if (this.loginForm === null) return;

    this.attachSubmitListener();
    this.attachPasswordVisibilityListener();
  }

  attachSubmitListener() {
    this.loginForm.addEventListener("submit", (event) => {
      event.preventDefault();
      event.stopPropagation();
      this.signIn();
    });
  }

  attachPasswordVisibilityListener() {
    this.passwordInput = document.getElementById("password");
    this.passwordVisibilityIcon = document.querySelector(".input-group-text i");

    this.passwordVisibilityIcon.addEventListener("click", () => {
      this.togglePasswordVisibility();
    });
  }

  async signIn() {
    this.buttonForm = this.loginForm.querySelector("input[type=submit]");
    this.setButtonPending();
    this.email = this.loginForm.querySelector("input[type=email]").value;
    this.password = this.passwordInput.value;
    this.formAuthenticityToken = this.loginForm.querySelector(
      "input[name=authenticity_token]"
    ).value;
    this.headerAuthenticityToken = document.querySelector("meta[name=csrf-token]").content;

    if (this.email === "" || this.password === "") {
      Swal.fire("L'email et le mot de passe doivent être renseignés", "", "warning");
      this.resetButton();
      return;
    }

    const rdvSolidaritesResponse = await this.loginToRdvSolidarites();

    if (rdvSolidaritesResponse.body.success === false) {
      Swal.fire("Impossible de s'authentifier", `${rdvSolidaritesResponse.body.errors[0]}`, "warning");
      this.resetButton();
      return;
    }

    this.rdvSolidaritesCredentials = {
      accessToken: rdvSolidaritesResponse.headers.get("access-token"),
      uid: rdvSolidaritesResponse.headers.get("uid"),
      client: rdvSolidaritesResponse.headers.get("client"),
    };

    const signInResult = await this.createSession();

    if (signInResult.success === true) {
      window.location.href = signInResult.redirect_path;
    } else {
      Swal.fire(
        `Une erreur s'est produite: ${signInResult.errors[0]}`,
        "Veuillez contacter l'équipe par mail à rdv-insertion@beta.gouv.fr pour pouvoir vous connecter.",
        "warning"
      );
      this.resetButton();
    }
  }

  async createSession() {
    const response = await fetch("/sessions", {
      method: "POST",
      credentials: "same-origin",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.headerAuthenticityToken,
        uid: this.rdvSolidaritesCredentials.uid,
        access_token: this.rdvSolidaritesCredentials.accessToken,
        client: this.rdvSolidaritesCredentials.client,
      },
      body: JSON.stringify({
        authenticity_token: this.formAuthenticityToken,
      }),
    });
    return response.json();
  }

  setButtonPending() {
    this.buttonForm.value = "Connexion...";
  }

  resetButton() {
    this.buttonForm.value = "Se connecter";
  }

  async loginToRdvSolidarites() {
    const response = await fetch(`${process.env.RDV_SOLIDARITES_URL}/api/v1/auth/sign_in`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: this.email,
        password: this.password,
      }),
    });

    return {
      body: await response.json(),
      headers: response.headers,
    };
  }

  togglePasswordVisibility() {
      if (this.passwordInput.type === "password") {
        this.passwordInput.type = "text";
        this.passwordVisibilityIcon.classList.remove("ri-eye-fill");
        this.passwordVisibilityIcon.classList.add("ri-eye-off-fill");
      } else {
        this.passwordInput.type = "password";
        this.passwordVisibilityIcon.classList.remove("ri-eye-off-fill");
        this.passwordVisibilityIcon.classList.add("ri-eye-fill");
      }
  }
}

export default LoginForm;
