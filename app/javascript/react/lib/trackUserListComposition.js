// https://developer.matomo.org/guides/tagmanager/datalayer

/* eslint-disable no-underscore-dangle */
const trackUserListComposition = async (users) => {
  try {
    if (!window._mtm || !users?.length) return;

    const payload = {
      event: "Fichier uploadé",
      numberOfUsers: users.length,
      numberOfExistingUsers: users.filter((user) => user.id).length,
      numberOfUsersInvitedBySMS: users.filter((user) => user.lastInvitationDate("sms")).length,
      numberOfUsersInvitedByPostal: users.filter((user) => user.lastInvitationDate("postal")).length,
      numberOfUsersInvitedByEmail: users.filter((user) => user.lastInvitationDate("email")).length,
      numberOfUsersFromCurrentOrganisation: users.filter((user) => user.belongsToCurrentOrg()).length,
    };

    window._mtm.push(payload)
  } catch (error) {
    console.warn("Impossible de tracker la composition de la liste des usagers", error);
  }
};

export default trackUserListComposition;