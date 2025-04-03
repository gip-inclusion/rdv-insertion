import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["result"]

  connect() {
    // Set up CSP violation listener for all tests
    document.addEventListener("securitypolicyviolation", (e) => {
      console.log("CSP violation detected", e)
      this.displayResult("CSP Violation Detected", "danger")
    })
  }

  sameOriginSubmit(event) {
    event.preventDefault()
    this.displayResult("Same-origin submission successful", "success")
  }

  submitExternalForm() {
    try {
      // Create a form pointing to external domain
      const form = document.createElement("form");
      form.method = "POST";
      form.action = "https://example.com/some-endpoint";

      // Add some data
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = "test_data";
      input.value = "This is sensitive data";
      form.appendChild(input);

      // Display a message to show we're testing
      this.displayResult("Testing external form submission...", "info");

      // Submit the form - this should be blocked by CSP
      document.body.appendChild(form);
      form.submit();
      document.body.removeChild(form);
    } catch (error) {
      this.displayResult(`Error: ${error.message}`, "danger");
    }
  }

  loadExternalScript() {
    console.log("Attempting to load external script")

    try {
      // Display a message to show we're testing
      this.displayResult("Testing external script loading...", "info");

      // Create a script element pointing to an external domain
      const script = document.createElement("script");
      script.src = "https://example.com/potentially-malicious-script.js";

      // Define a callback to detect if the script loads
      // This shouldn't execute if CSP is working correctly
      script.onload = () => {
        console.error("WARNING: External script was loaded - CSP is not blocking script-src correctly!")
        this.displayResult(
          "Security Issue: External script was loaded! CSP is not blocking script-src correctly",
          "danger"
        );
      };

      // Define an error callback - this might execute if the script fails to load
      script.onerror = () => {
        if (this.resultTarget.textContent === "Testing external script loading...") {
          this.displayResult("Script blocked (but no CSP violation detected)", "warning");
        }
      };

      // Attempt to load the script - should be blocked by CSP
      document.body.appendChild(script)
    } catch (error) {
      this.displayResult(`Error: ${error.message}`, "danger");
    }
  }

  displayResult(message, type) {
    this.resultTarget.textContent = message

    // Remove any existing alert classes
    this.resultTarget.classList.remove("alert-info", "alert-success", "alert-warning", "alert-danger");

    // Add the appropriate alert class
    this.resultTarget.classList.add(`alert-${type}`)

    // Make sure the result is visible
    this.resultTarget.classList.remove("hidden");
  }
}
