FROM nginx:1.27-alpine

LABEL maintainer="GEOScore AI <https://geoscoreai.com>"
LABEL description="Nginx with GEO (Generative Engine Optimization) configurations"

# Install curl for healthcheck
RUN apk add --no-cache curl

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy GEO-optimized Nginx configs
COPY nginx/geo-headers.conf /etc/nginx/conf.d/geo-headers.conf
COPY nginx/robots-llms.conf /etc/nginx/conf.d/robots-llms.conf
COPY nginx/ai-crawler-rate-limit.conf /etc/nginx/conf.d/ai-crawler-rate-limit.conf

# Copy main nginx config with GEO optimizations
RUN cat > /etc/nginx/conf.d/default.conf <<'NGINX'
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    # Include GEO configs
    include /etc/nginx/conf.d/robots-llms.conf;

    # Apply rate limiting
    location / {
        limit_req zone=ai_crawlers burst=20 nodelay;
        limit_req zone=regular burst=40 nodelay;
        limit_req_status 429;

        try_files $uri $uri/ /index.html;
    }

    # Serve static assets with long cache
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff2?)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Health check endpoint
    location = /health {
        access_log off;
        return 200 "ok\n";
        add_header Content-Type text/plain;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}
NGINX

# Create default html directory
RUN mkdir -p /usr/share/nginx/html

# Create a default index page
RUN echo '<!DOCTYPE html><html><head><meta charset="utf-8"><title>GEO Ready</title></head><body><h1>GEO-Optimized Server</h1><p>Replace this with your site content.</p></body></html>' > /usr/share/nginx/html/index.html

EXPOSE 80 443

# Validate config on startup
CMD ["sh", "-c", "nginx -t && nginx -g 'daemon off;'"]
