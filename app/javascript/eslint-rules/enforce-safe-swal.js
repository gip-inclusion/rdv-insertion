module.exports = {
  meta: {
    type: "suggestion",
    docs: {
      description: "Enforce using safeSwal instead of Swal.fire directly",
      category: "Security",
      recommended: true,
    },
    fixable: "code",
    schema: [], // no options
    messages: {
      useSafeSwal: "Use safeSwal from 'app/javascript/lib/safeSwal' instead of Swal.fire directly for proper HTML sanitization"
    }
  },
  create(context) {
    return {
      // Check for MemberExpression (like Swal.fire)
      MemberExpression(node) {
        // Check if the member expression is Swal.fire
        if (
          node.object.type === "Identifier" &&
          node.object.name === "Swal" &&
          node.property.type === "Identifier" &&
          node.property.name === "fire"
        ) {
          // Report the error
          context.report({
            node,
            messageId: "useSafeSwal",
            // Provide an automatic fix if possible
            fix(fixer) {
              // Check if we're in a CallExpression
              if (node.parent && node.parent.type === "CallExpression") {
                // Return the fix
                return fixer.replaceText(node, "safeSwal");
              }
              return null;
            }
          });
        }
      }
    };
  }
};