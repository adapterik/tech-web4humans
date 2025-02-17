Start container and just shell into it:

```shellse
DIR=`pwd` docker compose run --service-ports ruby
```

Inside container:

```shell
HOME_DIR=`pwd` passenger start
```




```
cd tools/ruby
DIR="${PWD}/../.." docker compose build
DIR="${PWD}/../.." docker compose run --service-ports ruby 
```

then install deps

```
bundle install
```

add ssh key for this dev session

```
ssh-keygen -t ed25519 -C "erik@adaptations.com" -f /app/__local_only/github -N ""
eval "$(ssh-agent -s)"
ssh-add /app/__local_only/github
```

now you can use git to push up changes.

then the cycle is

git add -A

git commit -m "your comment"

git push origin main


actually, first git will want you to fix it:

git config --global --add safe.directory /app
git config --global user.email "erik@adaptations.com"
git config --global user.name "Erik Pearson"

it takes less than a minute to build at github

then at sliplane, redeploy
