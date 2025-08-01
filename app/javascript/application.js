// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
// Vanilla components
import "bootstrap";
import "./stylesheets/application.scss";
import "@hotwired/turbo-rails";
import { Application } from "@hotwired/stimulus";
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers";
import "chartkick/chart.js";

import DepartmentSelector from "./components/department-selector";
import OrganisationSelector from "./components/organisation-selector";

require("@rails/ujs").start();
require("@rails/activestorage").start();

const componentRequireContext = require.context("./react/", true);
const ReactRailsUJS = require("react_ujs");

ReactRailsUJS.useContext(componentRequireContext);

window.Stimulus = Application.start();
const context = require.context("./controllers/", true, /\.js$/);
Stimulus.load(definitionsFromContext(context));

// https://github.com/reactjs/react-rails/issues/1103
ReactRailsUJS.handleEvent("turbo:load", ReactRailsUJS.handleMount);
ReactRailsUJS.handleEvent("turbo:before-render", ReactRailsUJS.handleUnmount);

// https://github.com/reactjs/react-rails/issues/1103#issuecomment-1212205462
ReactRailsUJS.handleEvent("turbo:frame-load", ReactRailsUJS.handleMount);
ReactRailsUJS.handleEvent("turbo:frame-render", ReactRailsUJS.handleUnmount);

Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target);
}

document.addEventListener("turbo:load", () => {
  new DepartmentSelector();
  new OrganisationSelector();
});
