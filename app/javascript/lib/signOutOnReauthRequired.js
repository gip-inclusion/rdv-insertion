function signOut() {
  const form = document.createElement("form")
  form.method = "post"
  form.action = "/sign_out"

  const methodField = document.createElement("input")
  methodField.type = "hidden"
  methodField.name = "_method"
  methodField.value = "delete"
  form.appendChild(methodField)

  const csrfField = document.createElement("input")
  csrfField.type = "hidden"
  csrfField.name = "authenticity_token"
  csrfField.value = document.querySelector("meta[name='csrf-token']")?.content
  form.appendChild(csrfField)

  document.body.appendChild(form)
  form.submit()
}

const signOutOnReauthRequired = (event) => {
  if (event.detail.fetchResponse.response.headers.get("X-Reauth-Required") !== "1") return
  document.removeEventListener("turbo:before-fetch-response", signOutOnReauthRequired)
  signOut()
}

export default signOutOnReauthRequired
