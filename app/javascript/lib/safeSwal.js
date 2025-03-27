import Swal from "sweetalert2";
import DOMPurify from "dompurify";

export default function safeSwal({
  title,
  html,
  text,
  icon,
  input,
  inputOptions,
  confirmButtonText
} = {}) {
  const sanitizedOptions = {
    ...(title && { title: DOMPurify.sanitize(title) }),
    ...(html && { html: DOMPurify.sanitize(html) }),
    ...(text && { text: DOMPurify.sanitize(text) }),
    ...(confirmButtonText && { confirmButtonText: DOMPurify.sanitize(confirmButtonText) }),

    // Non-text properties
    ...(icon && { icon }),
    ...(input && { input })
  };

  // Sanitize inputOptions if it exists
  if (inputOptions) {
    const sanitizedInputOptions = {};
    Object.entries(inputOptions).forEach(([key, value]) => {
      sanitizedInputOptions[key] = value ? DOMPurify.sanitize(value) : value;
    });
    sanitizedOptions.inputOptions = sanitizedInputOptions;
  }

  // eslint-disable-next-line rdv-insertion/enforce-safe-swal
  return Swal.fire(sanitizedOptions);
}
