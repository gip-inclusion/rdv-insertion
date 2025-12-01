import safeSwal from "./safeSwal";
import inviteUser from "../actions/inviteUser";

const createInvitationLetter = async (
  userId,
  departmentId,
  organisationId,
  isDepartmentLevel,
  motifCategoryId
) => {
  const response = await inviteUser(
    userId,
    departmentId,
    organisationId,
    isDepartmentLevel,
    "postal",
    motifCategoryId,
    "application/pdf"
  );

  if (!response.ok) {
    // we respond with json when request is unsuccessfull
    const result = await response.json();
    if (result.errors[0] === "Le format de l'adresse est invalide") {
      safeSwal({
        title: "Impossible d'inviter l'usager",
        html: "L'adresse n'est pas complète ou elle n'est pas enregistrée correctement",
        icon: "error",
      });
    } else if (result.errors[0] === "Une erreur est survenue lors de la génération du PDF. L'équipe a été notifiée de l'erreur et tente de la résoudre.") {
      safeSwal({
        title: "Erreur de génération du PDF",
        text: result.errors[0],
        icon: "error",
      });
    } else {
      safeSwal({
        title: "Impossible d'inviter l'usager",
        text: result.errors[0],
        icon: "error",
      });
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
  safeSwal({
    title: "Une erreur a eu lieu pendant le téléchargement",
    text: "Essayez de vous rendre sur la page du bénéficiaire et de recréer le document",
    icon: "error",
  });
  return { success: false };
};

export default createInvitationLetter;
