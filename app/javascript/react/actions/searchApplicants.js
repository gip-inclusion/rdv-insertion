/* eslint no-await-in-loop: "off" */
const searchApplicants = async (departmentInternalIds, uids) => {
  const response = await fetch("/applicants/search", {
    method: "POST",
    credentials: "same-origin",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
    },
    body: JSON.stringify({
      applicants: { department_internal_ids: departmentInternalIds, uids },
    }),
  });

  return response.json();
};

export default searchApplicants;
