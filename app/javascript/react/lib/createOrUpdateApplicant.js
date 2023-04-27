import Swal from "sweetalert2";
import handleApplicantCreation from "./handleApplicantCreation";

const FRENCH_DULPLICATE_ATTRIBUTES = {
  email: "email",
  phone_number: "numéro de téléphone",
};

const createOrUpdateApplicant = async (
  newApplicant,
  contactDuplicate,
  duplicateAttribute,
  encryptedId,
  organisationId
) => {
  const humanDuplicateAttribute = FRENCH_DULPLICATE_ATTRIBUTES[duplicateAttribute];
  const text =
    `La personne ci-dessous est enregistrée avec le même ${humanDuplicateAttribute} mais avec un prénom différent:<br/><br/>` +
    `<div><strong>${
      contactDuplicate.title.charAt(0).toUpperCase() + contactDuplicate.title.slice(1)
    } ${contactDuplicate.first_name} ${contactDuplicate.last_name}</strong></div>` +
    "<br/><br/>S'agit-il de la même personne ou d'une autre personne?<br/>" +
    `S'il s'agit d'une personne différente, on l'enregistrera sans ${humanDuplicateAttribute}.`;
  const result = await Swal.fire({
    title: `Une personne avec le même ${humanDuplicateAttribute} existe déjà`,
    html: text,
    icon: "warning",
    showDenyButton: true,
    showCancelButton: true,
    confirmButtonText: "C'est la même personne",
    denyButtonText: "C'est une autre personne",
    cancelButtonText: "Annuler",
  });

  if (result.isConfirmed) {
    newApplicant.encryptedId = encryptedId;
    console.log("encryptedId", encryptedId);
    console.log("asjson", newApplicant.asJson());
    await handleApplicantCreation(newApplicant, organisationId);
  } else if (result.isDenied) {
    const objectAttribute = duplicateAttribute === "email" ? "email" : "phoneNumber";
    newApplicant[objectAttribute] = null;
    await handleApplicantCreation(newApplicant, organisationId);
  }
};

export default createOrUpdateApplicant;
