import Swal from "sweetalert2";
import updateApplicant from "../react/actions/updateApplicant";

const archiveApplicant = async (archiveButton, archivingReason = null) => {
  const { applicantId, organisationId, departmentId, departmentLevel } = archiveButton.dataset;
  let attributes;
  const action = archiveButton.innerText;
  if (action === "Rouvrir le dossier") {
    attributes = { is_archived: "false" };
  } else {
    attributes = { is_archived: "true", archiving_reason: archivingReason };
  }
  console.log(attributes);
  const result = await updateApplicant(organisationId, applicantId, attributes);

  if (result.success) {
    if (departmentLevel === true) {
      window.location.replace(`/departments/${departmentId}/applicants/${applicantId}`);
    } else {
      window.location.replace(`/organisations/${organisationId}/applicants/${applicantId}`);
    }
  } else {
    Swal.fire("Impossible d'archiver le dossier", result.errors[0], "error");
  }
};

const displayArchiveModal = async (archiveButton) => {
  if (archiveButton.innerText === "Archiver le dossier") {
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
      archiveApplicant(archiveButton, archivingReason);
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
      archiveApplicant(archiveButton);
    }
  }
};

const archiveApplicantButton = () => {
  if (document.getElementById("archive-button")) {
    const archiveButton = document.getElementById("archive-button");
    archiveButton.addEventListener("click", () => {
      displayArchiveModal(archiveButton);
    });
  }
};

export default archiveApplicantButton;
