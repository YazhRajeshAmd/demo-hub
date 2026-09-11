# AMD ROCm Demo Hub — static landing page
# Runs as a non-root nginx (already the default for nginxinc/nginx-unprivileged),
# listens on 8080, no build step required beyond copying the static file.
FROM nginxinc/nginx-unprivileged:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
