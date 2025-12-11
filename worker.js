export default {
  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname;

    const routes = {
      '/install': 'https://raw.githubusercontent.com/thinhngotony/alias/main/install.sh',
      '/install.ps1': 'https://raw.githubusercontent.com/thinhngotony/alias/main/install.ps1',
      '/uninstall': 'https://raw.githubusercontent.com/thinhngotony/alias/main/uninstall.sh',
      '/uninstall.ps1': 'https://raw.githubusercontent.com/thinhngotony/alias/main/uninstall.ps1',
      '/load.sh': 'https://raw.githubusercontent.com/thinhngotony/alias/main/load.sh',
      '/load.ps1': 'https://raw.githubusercontent.com/thinhngotony/alias/main/load.ps1',
    };

    if (path === '/') {
      return new Response(`Hyber Orbit Aliases API

Install:
  Linux/Mac:  bash <(curl -s https://alias.hyberorbit.com/install)
  Windows:    iwr -useb https://alias.hyberorbit.com/install.ps1 | iex

Uninstall:
  Linux/Mac:  bash <(curl -s https://alias.hyberorbit.com/uninstall)
  Windows:    iwr -useb https://alias.hyberorbit.com/uninstall.ps1 | iex
`, {
        headers: { 'Content-Type': 'text/plain' }
      });
    }

    const targetUrl = routes[path];
    if (!targetUrl) {
      return new Response('Not found', { status: 404 });
    }

    const response = await fetch(targetUrl, {
      cf: { cacheTtl: 60 }  // Cache for only 60 seconds
    });
    return new Response(response.body, {
      status: response.status,
      headers: {
        'Content-Type': 'text/plain',
        'Cache-Control': 'no-cache, must-revalidate',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
};
