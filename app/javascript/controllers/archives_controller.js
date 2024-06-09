import { Controller } from "@hotwired/stimulus";
import Swal from "sweetalert2";
import deleteArchive from "../react/actions/deleteArchive";

export default class extends Controller {
  connect() {
    this.userId = this.element.dataset.userId;
    this.departmentId = this.element.dataset.departmentId;
    this.archiveId = this.element.dataset.archiveId;
  }

  async destroy() {
    const { isConfirmed } = await Swal.fire({
      title: "Le dossier sera rouvert",
      text: "Le dossier retrouvera le statut précédant l'archivage",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Oui",
      cancelButtonText: "Annuler",
      confirmButtonColor: "#EC4C4C",
      cancelButtonColor: "#083b66",
    });

    if (isConfirmed) {
      const result = await deleteArchive(this.archiveId);
      this.handleResult(result);
    }
  }

  handleResult(result) {
    if (result.success) {
      window.location.replace(result.redirect_path);
    } else {
      Swal.fire("Impossible d'archiver le dossier", result.errors[0], "error");
    }
  }
}
