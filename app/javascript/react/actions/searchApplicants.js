import Swal from "sweetalert2";

/* eslint no-await-in-loop: "off" */
const searchApplicants = async (uids) => {
  let nextPage = 1;
  let retrievedApplicants = [];

  while (nextPage) {
    const response = await fetch("/applicants/search", {
      method: "POST",
      credentials: "same-origin",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
      },
      body: JSON.stringify({
        applicants: { uids },
        page: nextPage,
      }),
    });
    const result = await response.json();
    if (!result.success) {
      Swal.fire(
        "Impossible de récupérer les infos des utilisateurs",
        result.errors && result.errors.join(" - "),
        "warning"
      );
      break;
    }
    retrievedApplicants = retrievedApplicants.concat(result.applicants);
    nextPage = result.next_page;
  }
  return retrievedApplicants;
};

export default searchApplicants;
