#!/bin/env bash

APP_ENV="${APP_ENV:-production}" HOME_DIR="${PWD}" bundle exec puma
