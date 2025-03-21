import Swal from "sweetalert2";
import DOMPurify from "dompurify";

export default function safeSwal(options) {
  const sanitizedHtml = DOMPurify.sanitize(options.html);
  /* eslint-disable rdv-insertion/enforce-safe-swal */
  return Swal.fire({ ...options, html: sanitizedHtml });
  /* eslint-enable rdv-insertion/enforce-safe-swal */
}
