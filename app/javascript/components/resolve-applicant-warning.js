import Swal from "sweetalert2";
import updateApplicant from "../react/actions/updateApplicant";

const resolveWarningModal = () => Swal.fire({
  title: "Le dossier sera définitivement clôturé",
  text: "Vous ne pourrez plus inviter ou relancer l'allocataire. Êtes-vous sûr(e) ?",
  icon: "warning",
  showCancelButton: true,
  confirmButtonColor: "#083b66",
  cancelButtonColor: "#EC4C4C"
});

const displayResolveWarning = async (resolveButton) => {
  const { organisationId } = resolveButton.dataset;
  const { applicantId } = resolveButton.dataset;
  const confirmation = await resolveWarningModal();

  if (confirmation.isConfirmed) {
    const attributes = { status: "resolved" }
    const result = await updateApplicant(organisationId, applicantId, attributes);

    if (result.success) {
      window.location.replace(`/organisations/${organisationId}/applicants/${applicantId}`);
    } else {
      Swal.fire("Impossible de clôturer le dossier", result.errors[0], "error");
    };
  };
};

const resolveApplicantWarning = () => {
  if (document.getElementById("resolve-button")) {
    const resolveButton = document.getElementById("resolve-button");
    resolveButton.addEventListener("click", () => { displayResolveWarning(resolveButton) });
  }
};

export default resolveApplicantWarning;
