const updateApplicant = async (organisationId, applicantId, attributes = {}) => {
  const response = await fetch(
    `/organisations/${organisationId}/applicants/${applicantId}`,
    {
      method: "PATCH",
      credentials: "same-origin",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
      },
      body: JSON.stringify({
        applicant: attributes,
      }),
    }
  );
  return response.json();
};

export default updateApplicant;
