# The secret sauce.

## Running locally

### With Host Ruby

This will start the server directly using Ruby:

bundle install

SPARKPOST_API_KEY=xxx HOME_DIR=`pwd` bundle exec puma

### With docker

But we also want to start it

## Running Remotely

How the server works:

It was originally at sloppy.io, but I moved it to digital ocean because sloppy.io is too slow.

## rbenv

Local development is typically with rbenv, the lightest weight way.

rbenv is installed with macports:

```text
erikapearson@Eriks-MBP ~ % port info rbenv
rbenv @1.1.2 (ruby)

Description:          Simple Ruby Version Management
Homepage:             https://github.com/rbenv/rbenv

Platforms:            darwin
License:              MIT
Maintainers:          Email: mojca@macports.org, GitHub: mojca
                      Policy: openmaintainer
```

To install a new version, say, 3.1.2:

```shell
rbenv install 3.1.2
```

To use a version (setting it in the local repo directory):

```shell
rbenv local 3.1.2
```

This creates or updates the file `.ruby-version` in the repo root. Checking this in ensures that development with a
freshly checked out repo will use the correct version (assuming rbenv is installed, and that version is installed...)

## Developing with `guard`

See https://github.com/guard/guard for setup:

E.g.

SPARKPOST_API_KEY=xxx HOME_DIR=`pwd` bundle exec guard -i



in container:

HOME_DIR=`pwd` bundle exec guard -i