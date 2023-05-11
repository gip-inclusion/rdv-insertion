import Swal from "sweetalert2";
import deleteArchiving from "../actions/deleteArchiving";

const handleArchivingDelete = async (applicant) => {
  const archivingToDelete = applicant.currentArchiving();
  const result = await deleteArchiving(archivingToDelete.id);
  if (result.success) {
    applicant.archivings = applicant.archivings.filter(
      (archiving) => archiving.id !== archivingToDelete.id
    );
    Swal.fire("Dossier de l'allocataire rouvert avec succès", "", "info");
  } else {
    Swal.fire("Impossible de rouvrir le dossier du bénéficiaire'", result.errors[0], "error");
  }
  return result;
};

export default handleArchivingDelete;
