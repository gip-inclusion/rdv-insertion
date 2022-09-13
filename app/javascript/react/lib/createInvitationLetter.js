import Swal from "sweetalert2";
import inviteApplicant from "../actions/inviteApplicant";

const createInvitationLetter = async (
  applicantId,
  departmentId,
  organisationId,
  isDepartmentLevel,
  motifCategory,
  helpPhoneNumber
) => {
  const response = await inviteApplicant(
    applicantId,
    departmentId,
    organisationId,
    isDepartmentLevel,
    "postal",
    helpPhoneNumber,
    motifCategory,
    "application/pdf"
  );

  if (!response.ok) {
    // we respond with json when request is unsuccessfull
    const result = await response.json();
    if (result.errors[0] === "Le format de l'adresse est invalide") {
      Swal.fire({
        title: "Impossible d'inviter l'utilisateur",
        html: `L'adresse n'est pas complète ou elle n'est pas enregistrée correctement.
        <br/><br/>
        Format attendu&nbsp;:<br/>10 rue de l'envoi 12345 - La Ville`,
        icon: "error",
      });
    } else {
      Swal.fire("Impossible d'inviter l'utilisateur", result.errors[0], "error");
    }
    return result;
  }
  const blob = await response.blob();
  if (blob) {
    const headerParts = response.headers.get("Content-Disposition").split(";");
    const filename = headerParts[1].split("=")[1].replace(/^"|"$/g, "");
    const filePath = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = filePath;
    a.download = filename;
    a.click();
    return { success: true };
  }
  Swal.fire(
    "Une erreur a eu lieu pendant le téléchargement",
    "Essayez de vous rendre sur la page du bénéficiaire et de recréer le document",
    "error"
  );
  return { success: false };
};

export default createInvitationLetter;
