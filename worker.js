export default {
  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname;

    // Fetch latest version tag from GitHub API
    let version = "latest";
    try {
      const release = await fetch(
        "https://api.github.com/repos/thinhngotony/alias/releases/latest",
        {
          headers: { "User-Agent": "hyber-alias-worker" },
          cf: { cacheTtl: 60 },
        },
      );
      if (release.ok) {
        const data = await release.json();
        version = data.tag_name || "latest";
      }
    } catch {
      // fall through with 'latest'
    }

    // Use tag-based URL for immutable CDN content (no stale cache)
    // Fall back to main branch if version detection failed
    const ref = version !== "latest" ? version : "main";
    const base = `https://raw.githubusercontent.com/thinhngotony/alias/${ref}`;

    const routes = {
      "/install": `${base}/install-universal.sh`,
      "/install.sh": `${base}/install.sh`,
      "/install.ps1": `${base}/install.ps1`,
      "/install.fish": `${base}/install.fish`,
      "/uninstall": `${base}/uninstall.sh`,
      "/uninstall.ps1": `${base}/uninstall.ps1`,
      "/load.sh": `${base}/load.sh`,
      "/load.ps1": `${base}/load.ps1`,
    };

    if (path === "/") {
      const displayVersion = version.replace(/^v/, "");
      return new Response(
        `Hyber Alias API v${displayVersion}

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

    try {
      const response = await fetch(targetUrl, {
        cf: { cacheTtl: 60, cacheEverything: true },
      });

      if (!response.ok) {
        return new Response(`Upstream error: ${response.status}`, {
          status: 502,
          headers: { "Content-Type": "text/plain" },
        });
      }

      return new Response(response.body, {
        status: response.status,
        headers: {
          "Content-Type": "text/plain",
          "Cache-Control": "public, max-age=60",
          "Access-Control-Allow-Origin": "*",
        },
      });
    } catch (error) {
      return new Response("Failed to fetch upstream resource", {
        status: 502,
        headers: { "Content-Type": "text/plain" },
      });
    }
  },
};
