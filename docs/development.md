Start container and just shell into it:

```shell
DIR=`pwd` docker compose run --service-ports ruby
```

Inside container:

```shell
HOME_DIR=`pwd` passenger start
```