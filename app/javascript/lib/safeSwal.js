import Swal from "sweetalert2";
import DOMPurify from "dompurify";

export default function safeSwal(options) {
  const sanitizedHtml = DOMPurify.sanitize(options.html);
  return Swal.fire({ ...options, html: sanitizedHtml });
}
