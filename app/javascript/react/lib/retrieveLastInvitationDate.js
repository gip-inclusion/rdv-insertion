const retrieveLastInvitationDate = (invitations, format = null) => {
  if (format !== null) {
    invitations = invitations.filter(invitation => invitation.format === format);
  }

  const sendedInvitations = invitations.filter(invitation => !!invitation.sent_at);
  // Trier de la plus récente à la plus ancienne
  sendedInvitations.sort((a,b) => new Date(b.sent_at) - new Date(a.sent_at));
  const [lastInvitation] = sendedInvitations;

  return lastInvitation?.sent_at;
};

export default retrieveLastInvitationDate;
