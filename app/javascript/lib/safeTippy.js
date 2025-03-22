import tippy from "tippy.js";
import DOMPurify from "dompurify";

export default function safeTippy(element, { content, allowHTML, placement, showOnCreate } = {}) {
  const sanitizedOptions = {
    content: DOMPurify.sanitize(content),

    ...(allowHTML !== undefined && { allowHTML }),
    ...(placement && { placement }),
    ...(showOnCreate !== undefined && { showOnCreate })
  };

  /* eslint-disable rdv-insertion/enforce-safe-tippy */
  return tippy(element, sanitizedOptions);
  /* eslint-enable rdv-insertion/enforce-safe-tippy */
}
