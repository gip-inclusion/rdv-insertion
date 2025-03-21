import tippy from "tippy.js";
import DOMPurify from "dompurify";

export default function safeTippy(element, options) {
  const content = DOMPurify.sanitize(options.content);
  /* eslint-disable rdv-insertion/enforce-safe-tippy */
  return tippy(element, { ...options, content });
  /* eslint-enable rdv-insertion/enforce-safe-tippy */
}
