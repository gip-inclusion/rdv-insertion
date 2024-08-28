import { useEffect } from "react";

/* eslint-disable */
const MazePoll = () => {
  useEffect(() => {
    (function (m, a, z, e) {
      let s; let t;
      try {
        t = m.sessionStorage.getItem("maze-us");
      } catch (err) {}

      if (!t) {
        t = new Date().getTime();
        try {
          m.sessionStorage.setItem("maze-us", t);
        } catch (err) {}
      }

      s = a.createElement("script");
      s.src = `${z  }?apiKey=${  e}`;
      s.async = true;
      a.getElementsByTagName("head")[0].appendChild(s);
      m.mazeUniversalSnippetApiKey = e;
    })(window, document, "https://snippet.maze.co/maze-universal-loader.js", "dfa66380-6f7f-4d3b-99f9-439b5226c0c2");
  }, []);

  return null;
};

export default MazePoll;