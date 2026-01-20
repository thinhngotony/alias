export default {
  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname;

    const routes = {
      '/install': 'https://raw.githubusercontent.com/thinhngotony/alias/main/install.sh',
      '/install.ps1': 'https://raw.githubusercontent.com/thinhngotony/alias/main/install.ps1',
      '/install.fish': 'https://raw.githubusercontent.com/thinhngotony/alias/main/install.fish',
      '/uninstall': 'https://raw.githubusercontent.com/thinhngotony/alias/main/uninstall.sh',
      '/uninstall.ps1': 'https://raw.githubusercontent.com/thinhngotony/alias/main/uninstall.ps1',
      '/load.sh': 'https://raw.githubusercontent.com/thinhngotony/alias/main/load.sh',
      '/load.ps1': 'https://raw.githubusercontent.com/thinhngotony/alias/main/load.ps1',
    };

    if (path === '/') {
      return new Response(`Hyber Alias API v1.1.0

Install:
  Bash/Zsh:   bash <(curl -s https://alias.hyberorbit.com/install)
  Fish:       curl -s https://alias.hyberorbit.com/install.fish | fish
  PowerShell: iwr -useb https://alias.hyberorbit.com/install.ps1 | iex

Uninstall:
  Bash/Zsh:   bash <(curl -s https://alias.hyberorbit.com/uninstall)
  PowerShell: iwr -useb https://alias.hyberorbit.com/uninstall.ps1 | iex

Documentation: https://github.com/thinhngotony/alias
`, {
        headers: { 'Content-Type': 'text/plain' }
      });
    }

    const targetUrl = routes[path];
    if (!targetUrl) {
      return new Response('Not found', { status: 404 });
    }

    // Add cache-busting parameter to bypass GitHub CDN cache
    const cacheBuster = Math.floor(Date.now() / 60000); // Changes every minute
    const fetchUrl = `${targetUrl}?v=${cacheBuster}`;

    const response = await fetch(fetchUrl, {
      cf: { cacheTtl: 0, cacheEverything: false }
    });
    return new Response(response.body, {
      status: response.status,
      headers: {
        'Content-Type': 'text/plain',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
};
