import Swal from "sweetalert2";
import archiveApplicant from "../react/actions/archiveApplicant";
import unarchiveApplicant from "../react/actions/unarchiveApplicant";

const toggleApplicantArchiving = async (toggleArchivingButton, archivingReason = null) => {
  const { applicantId, organisationId, departmentId, departmentLevel } =
    toggleArchivingButton.dataset;
  const action = toggleArchivingButton.innerText;
  const isArchiving = action.toLowerCase().includes("archiver");
  const attributes = { archiving_reason: archivingReason };

  const result = isArchiving
    ? await archiveApplicant(applicantId, attributes)
    : await unarchiveApplicant(applicantId);

  if (result.success) {
    if (departmentLevel === "true") {
      window.location.replace(`/departments/${departmentId}/applicants/${applicantId}`);
    } else {
      window.location.replace(`/organisations/${organisationId}/applicants/${applicantId}`);
    }
  } else {
    Swal.fire("Impossible d'archiver le dossier", result.errors[0], "error");
  }
};

const displayToggleArchivingModal = async (archiveButton) => {
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
      toggleApplicantArchiving(archiveButton, archivingReason);
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
      toggleApplicantArchiving(archiveButton);
    }
  }
};

const toggleApplicantArchivingButton = () => {
  if (document.getElementById("archive-button")) {
    const archiveButton = document.getElementById("archive-button");
    archiveButton.addEventListener("click", () => {
      displayToggleArchivingModal(archiveButton);
    });
  }
};

export default toggleApplicantArchivingButton;
