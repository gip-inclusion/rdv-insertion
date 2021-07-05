const createApplicant = async (applicant) => {
  const response = await fetch("/applicants", {
    method: "POST",
    credentials: "same-origin",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
    },
    body: JSON.stringify({
      applicant: applicant.asJson(),
    }),
  });

  return response.json();
};

export default createApplicant;
