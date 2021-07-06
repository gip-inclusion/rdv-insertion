const inviteApplicant = async (applicantId) => {
  const response = await fetch(`/applicants/${applicantId}/invitations`, {
    method: "POST",
    credentials: "same-origin",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
    },
  });

  return response.json();
};

export default inviteApplicant;
