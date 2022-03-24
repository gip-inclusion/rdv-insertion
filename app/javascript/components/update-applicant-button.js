import Swal from "sweetalert2";
import updateApplicant from "../react/actions/updateApplicant";

const updateApplicantStatus = async (updateButton, archivingReason = null) => {
  const { organisationId, applicantId } = updateButton.dataset;
  const action = updateButton.innerText;

  const status = action === "Rouvrir le dossier" ? "invitation_pending" : "archived";
  const attributes = { status, archiving_reason: archivingReason };
  const result = await updateApplicant(organisationId, applicantId, attributes);

  if (result.success) {
    window.location.replace(`/organisations/${organisationId}/applicants/${applicantId}`);
  } else {
    Swal.fire("Impossible d'archiver le dossier", result.errors[0], "error");
  }
};

const displayUpdateStatusModal = async (updateButton) => {
  if (updateButton.innerText === "Archiver le dossier") {
    const { value: archivingReason, isConfirmed } = await Swal.fire({
      icon: "warning",
      title: "Le dossier sera archivé",
      input: "text",
      inputLabel: "Motif d'archivage",
      showCancelButton: true,
      confirmButtonText: "Oui",
      cancelButtonText: "Annuler",
      confirmButtonColor: "#EC4C4C",
      cancelButtonColor: "#083b66",
    });

    if (isConfirmed) {
      updateApplicantStatus(updateButton, archivingReason);
    }
  } else {
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
      updateApplicantStatus(updateButton);
    }
  }
};

const updateApplicantButton = () => {
  if (document.getElementById("update-status-button")) {
    const updateButton = document.getElementById("update-status-button");
    updateButton.addEventListener("click", () => {
      displayUpdateStatusModal(updateButton);
    });
  }
};

export default updateApplicantButton;
