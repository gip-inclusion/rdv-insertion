import Swal from "sweetalert2";
import inviteApplicant from "./inviteApplicant";

const getInvitationLetter = async (
  applicantId,
  departmentId,
  organisation,
  isDepartmentLevel,
  invitationFormat
) => {
  const result = await inviteApplicant(
    applicantId,
    departmentId,
    organisation.id,
    isDepartmentLevel,
    invitationFormat,
    organisation.phone_number,
    "application/json, application/pdf"
  );
  if (result.success === false) {
    Swal.fire({
      title: "Impossible d'inviter l'utilisateur",
      html: result.errors[0],
      icon: "error",
    });
    return result;
  }
  const blob = await result.blob();
  if (blob) {
    const headerParts = result?.headers.get("Content-Disposition").split(";");
    const filename = headerParts[1].split("=")[1];
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

export default getInvitationLetter;
