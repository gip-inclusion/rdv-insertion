require "rails_helper"

# Simple feature test that verifies our CSP test page is working properly
RSpec.describe "CSP form-action protection", :js, type: :feature do
  it "blocks form submissions to external domains" do
    # Visit the test page
    visit "/csp-test"

    # Attempt to submit a form to an external domain
    # This should be blocked by CSP
    click_button "Submit to external domain"

    result = find("[data-csp-test-target='result']", visible: :all, wait: 3)

    # The CSP violation should be detected and displayed
    # If this fails, it means either:
    # 1. The CSP isn't properly configured
    # 2. The test environment doesn't properly enforce CSP
    # 3. There's an issue with the detection in our JavaScript
    expect(result.text).to eq("CSP Violation Detected")
  end

  it "blocks form submissions to external domains via JavaScript" do
    visit "/csp-test"

    # Attempt to submit a form to an external domain via JavaScript
    # This should be blocked by CSP
    click_button "Create and submit form to external domain via JavaScript"

    # Get the result element using the data-target attribute
    result = find("[data-csp-test-target='result']", visible: :all, wait: 3)

    # The CSP violation should be detected and displayed
    # If this fails, it means either:
    # 1. The CSP isn't properly configured
    # 2. The test environment doesn't properly enforce CSP
    # 3. There's an issue with the detection in our JavaScript
    expect(result.text).to eq("CSP Violation Detected")
  end

  it "blocks loading scripts from external domains" do
    visit "/csp-test"

    # Attempt to load a script from an external domain
    # This should be blocked by CSP
    click_button "Load script from external domain"

    # Get the result element using the data-target attribute
    result = find("[data-csp-test-target='result']", visible: :all, wait: 3)

    # The CSP violation should be detected and displayed
    # If this fails, it means either:
    # 1. The CSP isn't properly configured
    # 2. The test environment doesn't properly enforce CSP
    # 3. There's an issue with the detection in our JavaScript
    expect(result.text).to eq("CSP Violation Detected")
  end

  it "allows same-origin form submissions" do
    visit "/csp-test"

    # Submit the same-origin form (the Stimulus controller will intercept it)
    find("form[action='/csp-test-endpoint']").find("button").click

    # Verify the submission was allowed (not blocked by CSP)
    # The Stimulus controller will set the text when the event is intercepted
    result = find("[data-csp-test-target='result']", visible: :all, wait: 3)
    expect(result.text).to eq("Same-origin submission successful")
  end
end
