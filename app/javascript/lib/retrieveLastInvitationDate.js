const retrieveLastInvitationDate = (invitations, format = null, motifCategoryId = null) => {
  if (format !== null) {
    invitations = invitations.filter((invitation) => invitation.format === format);
  }
  if (motifCategoryId !== null) {
    invitations = invitations.filter(
      (invitation) => invitation.motif_category.id === motifCategoryId
    );
  }

  const sortedInvitations = invitations.sort(
    (a, b) => new Date(b.created_at) - new Date(a.created_at)
  );
  const [lastInvitation] = sortedInvitations;

  return lastInvitation?.created_at;
};

export default retrieveLastInvitationDate;
