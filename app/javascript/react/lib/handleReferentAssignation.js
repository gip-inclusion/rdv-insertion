import Swal from "sweetalert2";
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
    Swal.fire(`Impossible d'assigner le référent ${user.referentEmail}`, result.errors[0], "error");
  }
  return result;
};

export default handleReferentAssignation;
