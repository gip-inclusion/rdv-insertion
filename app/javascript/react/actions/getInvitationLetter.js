const getInvitationLetter = async (
  applicantId,
  departmentId,
  organisation,
  isDepartmentLevel,
  invitationId
) => {
  let url;
  if (isDepartmentLevel) {
    url = `/departments/${departmentId}/applicants/${applicantId}/invitations/${invitationId}`;
  } else {
    url = `/organisations/${organisation.id}/applicants/${applicantId}/invitations/${invitationId}`;
  }

  const response = await fetch(url, {
    method: "GET",
    credentials: "same-origin",
    headers: {
      Accept: "application/pdf",
      "Content-Type": "application/pdf",
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
    },
  });

  const blob = await response.blob();

  if (blob) {
    const headerParts = response.headers.get("Content-Disposition").split(";");
    const filename = headerParts[1].split("=")[1];
    const filePath = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = filePath;
    a.download = filename;
    a.click();
    return { success: true };
  }
  return { success: false };
};

export default getInvitationLetter;
