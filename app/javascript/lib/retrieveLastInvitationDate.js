const retrieveLastInvitationDate = (invitations, format = null, motifCategory = null) => {
  if (format !== null) {
    invitations = invitations.filter((invitation) => invitation.format === format);
  }
  if (motifCategory !== null) {
    invitations = invitations.filter((invitation) => invitation.motif_category === motifCategory);
  }
  const sentInvitations = invitations.filter((invitation) => !!invitation.sent_at);
  // Trier de la plus récente à la plus ancienne
  sentInvitations.sort((a, b) => new Date(b.sent_at) - new Date(a.sent_at));
  const [lastInvitation] = sentInvitations;

  return lastInvitation?.sent_at;
};

export default retrieveLastInvitationDate;
