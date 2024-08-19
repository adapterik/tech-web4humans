#!/bin/bash

if [ ! -f /app/ssl/test.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /app/ssl/test.key -out /kb/deployment/ssl/test.crt -subj "/C=US/ST=California/L=Berkeley/O=Adaptations/OU=WebDevelopment/CN=tech.web4humans.com"
fi