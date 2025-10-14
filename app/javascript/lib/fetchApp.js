const fetchApp = async (url, opts = {}) => {
  console.log("fetchApp", url, opts)
  console.log("full opts", {
    method: opts.method || "GET",
    credentials: "same-origin",
    headers: {
      Accept: `${opts.accept || "application/json"}`,
      "Content-Type": `${opts.contentType || "application/json"}`,
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content,
    },
    ...(opts.body && { body: JSON.stringify(opts.body) }),
  })
  const response = await fetch(url, {
    method: opts.method || "GET",
    credentials: "same-origin",
    headers: {
      Accept: `${opts.accept || "application/json"}`,
      "Content-Type": `${opts.contentType || "application/json"}`,
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content,
    },
    ...(opts.body && { body: JSON.stringify(opts.body) }),
  });
  if (opts.parseJson) {
    return response.json();
  }
  return response;
};

export default fetchApp;