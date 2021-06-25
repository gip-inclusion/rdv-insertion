const augmentApplicants = async (uids) => {
  const response = await fetch("/applicants/augment", {
    method: "POST",
    credentials: "same-origin",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
    },
    body: JSON.stringify({ uids }),
  });

  return response.json();
};

export default augmentApplicants;
