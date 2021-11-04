const inviteApplicant = async (organisationId, applicantId, invitationFormat) => {
  const response = await fetch(
    `/organisations/${organisationId}/applicants/${applicantId}/invitations`,
    {
      method: "POST",
      credentials: "same-origin",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
      },
      body: JSON.stringify({
        format: invitationFormat,
      }),
    }
  );

  return response.json();
};

export default inviteApplicant;
