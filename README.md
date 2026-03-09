# Docker + Nginx for GEO (Generative Engine Optimization)

Server-level configurations to improve your site's visibility in AI-powered search engines like ChatGPT, Perplexity, Google AI Overviews, and Claude.

## Why Server Config Matters for GEO

AI crawlers (GPTBot, PerplexityBot, ClaudeBot, Google-Extended) behave differently from traditional search bots. Your Nginx configuration directly affects whether AI engines can efficiently crawl, parse, and cite your content.

Key factors:
- **Response headers** signal content freshness and structure to AI crawlers
- **robots.txt + llms.txt** tell AI systems what to index and how to cite you
- **Rate limiting** prevents abuse while keeping AI crawlers welcome
- **Caching and compression** ensure fast responses that AI crawlers prefer

## What's Included

| File | Purpose |
|------|---------|
| `nginx/geo-headers.conf` | Headers for AI crawler compatibility and content signals |
| `nginx/robots-llms.conf` | Serve robots.txt and llms.txt for AI discovery |
| `nginx/ai-crawler-rate-limit.conf` | Rate limiting tuned for AI crawlers |
| `docker-compose.yml` | One-command deployment with Docker Compose |
| `Dockerfile` | Nginx image with GEO optimizations baked in |
| `scripts/check-geo-status.sh` | Verify your GEO signals are working |

## Quick Start

```bash
# Clone and start
git clone https://github.com/henu-wang/geo-docker-nginx.git
cd geo-docker-nginx

# Add your site content to ./html/
mkdir -p html
echo "<h1>Hello</h1>" > html/index.html

# Start Nginx with GEO configs
docker compose up -d

# Verify GEO signals
bash scripts/check-geo-status.sh http://localhost:8080
```

## Customization

1. Edit `nginx/robots-llms.conf` to set your site name, description, and contact
2. Adjust rate limits in `nginx/ai-crawler-rate-limit.conf` for your traffic
3. Mount your actual site content into the container via `docker-compose.yml`

## Verify Your GEO Score

After deploying, scan your site with **[GEOScore AI](https://geoscoreai.com)** to measure your Generative Engine Optimization score and get actionable recommendations.

## How AI Crawlers Discover Content

```
AI Crawler Request
    -> robots.txt (permission check)
    -> llms.txt (site summary + structure)
    -> HTML pages (with proper headers)
    -> AI engine indexes and cites your content
```

## License

MIT
