const appFetch = async (url, method = "GET", body = null, type = "json") => {
  const response = await fetch(url, {
    method,
    credentials: "same-origin",
    headers: {
      Accept: `application/${type}`,
      "Content-Type": `application/${type}`,
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
    },
    ...(body && { body: JSON.stringify(body) }),
  });

  return response.json();
};

export default appFetch;
