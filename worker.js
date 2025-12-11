export default {
  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname;

    const routes = {
      '/install': 'https://raw.githubusercontent.com/thinhngotony/alias/main/install.sh',
      '/load.sh': 'https://raw.githubusercontent.com/thinhngotony/alias/main/load.sh',
    };

    if (path === '/') {
      return new Response('Hyber Orbit Dotfiles API\n\nInstall: bash <(curl -s https://alias.hyberorbit.com/install)', {
        headers: { 'Content-Type': 'text/plain' }
      });
    }

    const targetUrl = routes[path];
    if (!targetUrl) {
      return new Response('Not found', { status: 404 });
    }

    const response = await fetch(targetUrl);
    return new Response(response.body, {
      status: response.status,
      headers: {
        'Content-Type': 'text/plain',
        'Cache-Control': 'public, max-age=3600',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
};
