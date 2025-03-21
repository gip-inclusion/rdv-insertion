module.exports = {
  meta: {
    type: "suggestion",
    docs: {
      description: "Enforce using safeTippy instead of tippy directly",
      category: "Security",
      recommended: true,
    },
    fixable: "code",
    schema: [], // no options
    messages: {
      useSafeTippy: "Use safeTippy from 'app/javascript/lib/safeTippy' instead of tippy directly for proper HTML sanitization"
    }
  },
  create(context) {
    return {
      // Check for CallExpression (like tippy(...))
      CallExpression(node) {
        // Check if the function called is tippy
        if (
          node.callee.type === "Identifier" &&
          node.callee.name === "tippy"
        ) {
          // Report the error
          context.report({
            node,
            messageId: "useSafeTippy",
            // Provide an automatic fix if possible
            fix(fixer) {
              return fixer.replaceText(node.callee, "safeTippy");
            }
          });
        }
      }
    };
  }
};