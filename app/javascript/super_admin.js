import "chartkick/chart.js";
import "./stylesheets/super_admin.scss";
import "@hotwired/turbo-rails";
import { Application } from "@hotwired/stimulus";
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers";

window.Stimulus = Application.start();
const context = require.context("./controllers/", true, /\.js$/);
window.Stimulus.load(definitionsFromContext(context));

document.addEventListener("turbo:before-fetch-response", (event) => {
  if (event.detail.fetchResponse.response.status === 401) {
    window.location.href = "/sign_out"
  }
})
