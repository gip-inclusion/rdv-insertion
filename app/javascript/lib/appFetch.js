const appFetch = async (url, method = "GET", body = null, accept = "application/json") => {
  const response = await fetch(url, {
    method,
    credentials: "same-origin",
    headers: {
      Accept: `${accept}`,
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
    },
    ...(body && { body: JSON.stringify(body) }),
  });

  if (!(accept === "application/json")) return response;
  return response.json();
};

export default appFetch;
