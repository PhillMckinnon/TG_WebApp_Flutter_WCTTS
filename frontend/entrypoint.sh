#!/bin/sh

# Fallback to default if API_URL is not set
: "${API_URL:=""}"
: "${CORS_ORIGIN:=.ngrok-free.app}"

# Write env.js dynamically
echo "window.env = { API_URL: '${API_URL}' };" > /usr/share/nginx/html/env.js

# Replace values in nginx.conf.template
envsubst '${CORS_ORIGIN}' < /etc/nginx/templates/nginx.conf.template > /etc/nginx/conf.d/default.conf

# Start nginx
exec nginx -g 'daemon off;'