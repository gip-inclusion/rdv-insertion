// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
// Vanilla components
import LoginForm from "components/login-form";
import StatusSelector from "components/status-selector"
import ActionRequiredCheckbox from "components/action-required-checkbox"

import "bootstrap";
import "stylesheets/application";
import * as Sentry from "@sentry/react";
import { Integrations } from "@sentry/tracing";

require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();

// this is necessary so images are compiled by webpack
require.context("../images", true);

if (process.env.NODE_ENV === 'production') {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.SENTRY_ENVIRONMENT,
    integrations: [new Integrations.BrowserTracing()],

    // We recommend adjusting this value in production, or using tracesSampler
    // for finer control
    tracesSampleRate: 0.5,
  });
};

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
// Support component names relative to this directory:
const componentRequireContext = require.context("react", true);
const ReactRailsUJS = require("react_ujs");

ReactRailsUJS.useContext(componentRequireContext);

document.addEventListener("turbolinks:load", () => {
  new LoginForm();
  new StatusSelector();
  new ActionRequiredCheckbox()
});
