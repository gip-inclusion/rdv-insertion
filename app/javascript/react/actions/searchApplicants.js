/* eslint no-await-in-loop: "off" */
const searchApplicants = async (departmentId, uids) => {
  const response = await fetch(`/departments/${departmentId}/applicants/search`, {
    method: "POST",
    credentials: "same-origin",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
    },
    body: JSON.stringify({
      applicants: { uids },
    }),
  });

  return response.json();
};

export default searchApplicants;
