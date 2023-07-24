class MatomoScriptTag {
  constructor() {
    /* eslint no-underscore-dangle: "off" */
    window._mtm = window._mtm || [];
    window._mtm.push({ "mtm.startTime": new Date().getTime(), event: "mtm.Start" });
    const matomoScriptTag = document.createElement("script");
    matomoScriptTag.async = true;
    matomoScriptTag.src = `https://matomo.inclusion.beta.gouv.fr/js/container_${process.ENV.MATOMO_CONTAINER_ID}.js`;

    const firstScriptTag = document.getElementsByTagName("script")[0];
    firstScriptTag.parentNode.insertBefore(matomoScriptTag, firstScriptTag);
  }
}

export default MatomoScriptTag;
