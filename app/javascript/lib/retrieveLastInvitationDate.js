const retrieveLastInvitationDate = (invitations, format = null) => {
  if (format !== null) {
    invitations = invitations.filter((invitation) => invitation.format === format);
  }

  if (format === "postal") {
    const createdInvitations = invitations.filter((invitation) => !!invitation.created_at);
    // Trier de la plus récente à la plus ancienne
    createdInvitations.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
    const [lastInvitation] = createdInvitations;

    return lastInvitation?.created_at;
  }

  const sentInvitations = invitations.filter((invitation) => !!invitation.sent_at);
  // Trier de la plus récente à la plus ancienne
  sentInvitations.sort((a, b) => new Date(b.sent_at) - new Date(a.sent_at));
  const [lastInvitation] = sentInvitations;

  return lastInvitation?.sent_at;
};

export default retrieveLastInvitationDate;
