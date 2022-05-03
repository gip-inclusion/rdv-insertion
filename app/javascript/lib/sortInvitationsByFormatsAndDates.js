const sortInvitationsByFormatsAndDates = (invitations) => {
  const invitationsDatesByFormat = { sms: [], email: [], postal: [] };
  const formats = ["sms", "email", "postal"];

  // Don't displayed invitations not sended
  const sentInvitations = invitations.filter((invitation) => !!invitation.sent_at);
  // Sort from the newest to the oldest
  const sortedInvitations = sentInvitations.sort((a, b) => new Date(b.sent_at) - new Date(a.sent_at));
  formats.forEach(format => {
    const invitationsFilteredByFormat = sortedInvitations.filter((invitation) => invitation.format === format);
    // We only keep invitations dates because we don't need anything else + when we create postal invitations,
    // the client don't receive the full invitation object from server & can only deduct sent_at
    invitationsDatesByFormat[format] = invitationsFilteredByFormat.map((invitation) => invitation?.sent_at);
  });
  return (invitationsDatesByFormat)
};

export default sortInvitationsByFormatsAndDates;
