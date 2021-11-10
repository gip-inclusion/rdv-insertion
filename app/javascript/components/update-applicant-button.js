import Swal from "sweetalert2";
import updateApplicant from "../react/actions/updateApplicant";

const updateApplicantStatus = async (updateButton) => {
  const { organisationId } = updateButton.dataset;
  const { applicantId } = updateButton.dataset;
  const action = updateButton.innerText;

  const attributes = (action === "Rouvrir le dossier") ? { status: "invitation_pending" } : { status: "resolved" };
  const result = await updateApplicant(organisationId, applicantId, attributes);

  if (result.success) {
    window.location.replace(`/organisations/${organisationId}/applicants/${applicantId}`);
  } else {
    Swal.fire("Impossible de clôturer le dossier", result.errors[0], "error");
  };
}

const resolveWarningModal = () => Swal.fire({
  title: "Le dossier sera définitivement clôturé",
  text: "Vous ne pourrez plus inviter ou relancer l'allocataire. Êtes-vous sûr(e) ?",
  icon: "warning",
  showCancelButton: true,
  confirmButtonText: "Oui",
  cancelButtonText: "Annuler",
  confirmButtonColor: "#EC4C4C",
  cancelButtonColor: "#083b66"
});

const displayResolveWarning = async (updateButton) => {
  const confirmation = await resolveWarningModal();

  if (confirmation.isConfirmed) {
    updateApplicantStatus(updateButton);
  };
};

const updateApplicantButton = () => {
  if (document.getElementById("update-status-button")) {
    const updateButton = document.getElementById("update-status-button");
    updateButton.addEventListener("click", () => { displayResolveWarning(updateButton) });
  }
};

export default updateApplicantButton;
