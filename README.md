# Jazz & Democracy Australia Web Site

## Overview

The JazzDemocracy Australia web site uses Ruby to dynamically run a web site. It uses a simple system of templates and a simple site database to dynamically generate any page request.

Why?

[ why indeed ]

## Development

Start container and just shell into it:

```shell
make run-dev-server
```

which actually does this

```shell
docker compose run --rm --service-ports ruby
```

This will leave your terminal in a bash shell inside the container. The container is all ready to run the web server!

Now start the server like this:

```shell
HOME_DIR=`pwd` passenger start
```

After this, the server is available at `http://localhost:3000`

### Why do it like this?

This is a flexible approach to running a development environment inside a docker container. It is also IDE agnostic.

A better version of this, and one that will surely be added to this repo soon, is to use a Visual Studio Code devcontainer. The advantage of this approach is that the IDE is fully integrated with the container environment, and all tools work as expected, with the support installed inside the container (not on the host system.)

Unfortunately, RubyMine, my preferred development tool, does not support such a convenient container integration -- yet!

## Deployment

The web server is deployed at a 3rd party service ("Digital Ocean") which automatically builds and deploys the service image upon every commit pushed to the main branch. The hosting service provides domain mapping, automatically detects and maps the internal to the standard ports, and even installs appropriate ssl certificates to cover any configured domain.

## Update Deps

Please regenerate the Gemfile.lock on host. The image will fail to build if the lock file is inconsistent with the Gemfile.

Better, regenerate Gemfile like this:

```bash
docker compose run ruby-dev
bundler install 
or 
bundler check
```

This builds the equivalent image without bundler in deployment mode.

> There must be a more elegant way by passing an environment variable; perhaps have a RUN step which runs a
> script rather than bundler directly.


TODO: okay, it looks like we started a generic ruby tool, tools/ruby, so that is the preferred (mine!) way to run a generic ruby interpreter using the same image as the prod one.