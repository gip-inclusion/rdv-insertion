import tippy from "tippy.js";
import DOMPurify from "dompurify";

export default function safeTippy(element, options) {
  const content = DOMPurify.sanitize(options.content);
  return tippy(element, { ...options, content });
}
