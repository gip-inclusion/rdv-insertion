import Swal from "sweetalert2";

const confirmationModal = (warningMessage, additionalArgs = {}) =>
  Swal.fire({
    title: warningMessage,
    icon: "warning",
    showCancelButton: true,
    confirmButtonColor: "#3085d6",
    cancelButtonColor: "#d33",
    ...additionalArgs,
  });
export default confirmationModal;
