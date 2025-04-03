import safeSwal from "../../lib/safeSwal";
import deleteArchive from "../actions/deleteArchive";

const handleArchiveDelete = async (user, options = { raiseError: true }) => {
  const archiveToDelete = user.archiveInCurrentOrganisation();
  const result = await deleteArchive(archiveToDelete.id, archiveToDelete.organisation_id);
  if (result.success) {
    user.archives = user.archives.filter((archive) => archive.id !== archiveToDelete.id);
    if (options.raiseError) {
      safeSwal({
        title: "Dossier de l'usager rouvert avec succès",
        icon: "info",
      });
    }
  } else if (!result.success && options.raiseError) {
    safeSwal({
      title: "Impossible de rouvrir le dossier du bénéficiaire",
      text: result.errors[0],
      icon: "error",
    });
  }
  return result;
};

export default handleArchiveDelete;
