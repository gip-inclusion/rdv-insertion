const sortInvitationsByFormatsAndDates = (invitations) => {
  const invitationsDatesByFormat = { sms: [], email: [], postal: [] };
  const formats = ["sms", "email", "postal"];

  // Sort from the newest to the oldest
  const sortedInvitations = invitations.sort(
    (a, b) => new Date(b.created_at) - new Date(a.created_at)
  );
  formats.forEach((format) => {
    const invitationsFilteredByFormat = sortedInvitations.filter(
      (invitation) => invitation.format === format
    );
    // We only keep invitations dates because we don't need anything else + when we create postal invitations,
    // the client don't receive the full invitation object from server & can only deduct sent date
    invitationsDatesByFormat[format] = invitationsFilteredByFormat.map(
      (invitation) => invitation.created_at
    );
  });
  return invitationsDatesByFormat;
};

export default sortInvitationsByFormatsAndDates;
