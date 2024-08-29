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
    })(window, document, "https://snippet.maze.co/maze-universal-loader.js", process.env.MAZE_API_KEY);
  }, []);

  return null;
};

export default MazePoll;