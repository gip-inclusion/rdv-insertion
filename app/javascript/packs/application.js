// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
// Vanilla components
import LoginForm from "components/login-form";
import StatusSelector from "components/status-selector"
import DepartmentSelector from "components/department-selector"
import ActionRequiredCheckbox from "components/action-required-checkbox"
import initTooltip from "components/tooltip"
import archiveApplicantButton from "components/archive-applicant-button"

import "bootstrap";
import "stylesheets/application";
import "@hotwired/turbo-rails"
import * as Sentry from "@sentry/react";
import { Integrations } from "@sentry/tracing";
import { cable } from "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

require("@rails/ujs").start();
require("@rails/activestorage").start();

const componentRequireContext = require.context("react", true);
const ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);

import "@hotwired/turbo-rails";

window.Stimulus = Application.start()
const context = require.context("../controllers", true, /\.js$/)
Stimulus.load(definitionsFromContext(context))

// https://github.com/reactjs/react-rails/issues/1103
ReactRailsUJS.handleEvent('turbo:load', ReactRailsUJS.handleMount);
ReactRailsUJS.handleEvent('turbo:before-render', ReactRailsUJS.handleUnmount);

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

document.addEventListener("turbo:load", () => {
  new LoginForm();
  new StatusSelector();
  new DepartmentSelector();
  new ActionRequiredCheckbox();
  initTooltip();
  archiveApplicantButton();
});
