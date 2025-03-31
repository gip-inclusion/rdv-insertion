import safeSwal from "../../lib/safeSwal";
import assignReferent from "../actions/assignReferent";

const handleReferentAssignation = async (
  user,
  departmentId,
  organisationId,
  isDepartmentLevel,
  options = { raiseError: true }
) => {
  const result = await assignReferent(
    user.id,
    user.referentEmail,
    departmentId,
    organisationId,
    isDepartmentLevel
  );
  if (result.success) {
    user.updateWith(result.user);
  } else if (!result.success && options.raiseError) {
    safeSwal({
      title: `Impossible d'assigner le référent ${user.referentEmail}`,
      text: result.errors[0],
      icon: "error",
    });
  }
  return result;
};

export default handleReferentAssignation;
