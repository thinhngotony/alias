export default {
  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname;

    const routes = {
      "/install":
        "https://raw.githubusercontent.com/thinhngotony/alias/main/install-universal.sh",
      "/install.sh":
        "https://raw.githubusercontent.com/thinhngotony/alias/main/install.sh",
      "/install.ps1":
        "https://raw.githubusercontent.com/thinhngotony/alias/main/install.ps1",
      "/install.fish":
        "https://raw.githubusercontent.com/thinhngotony/alias/main/install.fish",
      "/uninstall":
        "https://raw.githubusercontent.com/thinhngotony/alias/main/uninstall.sh",
      "/uninstall.ps1":
        "https://raw.githubusercontent.com/thinhngotony/alias/main/uninstall.ps1",
      "/load.sh":
        "https://raw.githubusercontent.com/thinhngotony/alias/main/load.sh",
      "/load.ps1":
        "https://raw.githubusercontent.com/thinhngotony/alias/main/load.ps1",
    };

    if (path === "/") {
      let version = "latest";
      try {
        const release = await fetch(
          "https://api.github.com/repos/thinhngotony/alias/releases/latest",
          {
            headers: { "User-Agent": "hyber-alias-worker" },
            cf: { cacheTtl: 300 },
          },
        );
        if (release.ok) {
          const data = await release.json();
          version = (data.tag_name || "latest").replace(/^v/, "");
        }
      } catch {
        // fall through with 'latest'
      }

      return new Response(
        `Hyber Alias API v${version}

Install:
  Linux/Mac:  curl -sfS https://alias.hyberorbit.com/install | sh
  Windows:    iwr -useb https://alias.hyberorbit.com/install.ps1 | iex

Uninstall:
  Linux/Mac:  curl -sfS https://alias.hyberorbit.com/uninstall | sh
  Windows:    iwr -useb https://alias.hyberorbit.com/uninstall.ps1 | iex

Auto-detects: Bash, Zsh, Fish shells

Documentation: https://github.com/thinhngotony/alias
`,
        {
          headers: { "Content-Type": "text/plain" },
        },
      );
    }

    const targetUrl = routes[path];
    if (!targetUrl) {
      return new Response("Not found", { status: 404 });
    }

    // Add cache-busting parameter to bypass GitHub CDN cache
    const cacheBuster = Math.floor(Date.now() / 60000); // Changes every minute
    const fetchUrl = `${targetUrl}?v=${cacheBuster}`;

    const response = await fetch(fetchUrl, {
      cf: { cacheTtl: 0, cacheEverything: false },
    });
    return new Response(response.body, {
      status: response.status,
      headers: {
        "Content-Type": "text/plain",
        "Cache-Control": "no-cache, no-store, must-revalidate",
        Pragma: "no-cache",
        Expires: "0",
        "Access-Control-Allow-Origin": "*",
      },
    });
  },
};
