import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  duplicateWebhookEndpoint(event) {
    event.preventDefault();
    const targetId = prompt("Entrez l'id RDV-I de l'organisation pour laquelle vous souhaitez appliquer ce webhook");
    const form = event.target.closest("form");
    form.querySelector("input[name='webhook_endpoint[target_id]']").value = targetId;
    if (!targetId) {
      return;
    }
    form.submit();
  }
}