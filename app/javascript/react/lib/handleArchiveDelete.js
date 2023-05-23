import Swal from "sweetalert2";
import deleteArchive from "../actions/deleteArchive";

const handleArchiveDelete = async (applicant) => {
  const archiveToDelete = applicant.archiveInCurrentDepartment();
  const result = await deleteArchive(archiveToDelete.id);
  if (result.success) {
    applicant.archives = applicant.archives.filter((archive) => archive.id !== archiveToDelete.id);
    Swal.fire("Dossier de l'allocataire rouvert avec succès", "", "info");
  } else {
    Swal.fire("Impossible de rouvrir le dossier du bénéficiaire'", result.errors[0], "error");
  }
  return result;
};

export default handleArchiveDelete;
