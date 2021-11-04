import Swal from "sweetalert2";
import confirmationModal from "../../lib/confirmationModal";
import createApplicant from "./createApplicant";

const displayDuplicationWarning = async (applicant, department) => {
  let warningMessage = "";

  if (!applicant.affiliationNumber) {
    warningMessage =
      "Le numéro d'allocataire n'est pas spécifié (si c'est un NIR il a été filtré).";
  } else if (!applicant.role) {
    warningMessage = "Le rôle de l'allocataire n'est pas spécifié.";
  }

  const searchApplicantLink = new URL(
    `${window.location.origin}/departments/${department.id}/applicants`
  );
  searchApplicantLink.searchParams.set("search_query", applicant.lastName);

  return confirmationModal(
    `${warningMessage}\nVérifiez <a class="light-blue" href="${searchApplicantLink.href}" target="_blank">ici</a>` +
      " que l'allocataire n'a pas déjà été créé avant de continuer.",
    {
      confirmButtonText: "Créer",
      cancelButtonText: "Annuler",
    }
  );
};

const handleApplicantCreation = async (applicant, department) => {
  if (!applicant.affiliationNumber || !applicant.role) {
    const confirmation = await displayDuplicationWarning(applicant, department);
    if (!confirmation.isConfirmed) return;
  }
  const result = await createApplicant(applicant, department.id);
  if (result.success) {
    applicant.updateWith(result.applicant);
  } else {
    Swal.fire("Impossible de créer l'utilisateur", result.errors[0], "error");
  }
};

export default handleApplicantCreation;
