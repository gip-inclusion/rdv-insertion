const retrieveLastRdvDate = (rdvs, pendingRdvs = false) => {
  // unknon rdvs are pending rdvs in rdv-solidarites
  if (pendingRdvs === true) {
    rdvs = rdvs.filter((rdv) => ["waiting", "unknown"].includes(rdv.status));
  } else {
    rdvs = rdvs.filter((rdv) => !["waiting", "unknown"].includes(rdv.status));
  }
  // Trier du plus récent au plus ancien
  rdvs.sort((a, b) => new Date(b.sent_at) - new Date(a.updated_at));
  const [lastRdv] = rdvs;

  return lastRdv?.starts_at;
};

export default retrieveLastRdvDate;
