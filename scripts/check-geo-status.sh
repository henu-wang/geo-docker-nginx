#!/usr/bin/env bash
# check-geo-status.sh - Verify GEO signals on your site
# Usage: bash scripts/check-geo-status.sh https://example.com

set -euo pipefail

URL="${1:-http://localhost:8080}"
URL="${URL%/}"  # Remove trailing slash
PASS=0
FAIL=0

green() { printf "\033[32m%s\033[0m\n" "$1"; }
red()   { printf "\033[31m%s\033[0m\n" "$1"; }
bold()  { printf "\033[1m%s\033[0m\n" "$1"; }

check() {
    local label="$1" result="$2"
    if [ "$result" = "true" ]; then
        green "  [PASS] $label"
        PASS=$((PASS + 1))
    else
        red "  [FAIL] $label"
        FAIL=$((FAIL + 1))
    fi
}

bold "=== GEO Signal Check: $URL ==="
echo ""

# Check robots.txt
bold "1. robots.txt"
ROBOTS=$(curl -s -o /dev/null -w "%{http_code}" "$URL/robots.txt" 2>/dev/null)
check "robots.txt accessible" "$([ "$ROBOTS" = "200" ] && echo true || echo false)"
if [ "$ROBOTS" = "200" ]; then
    ROBOTS_BODY=$(curl -s "$URL/robots.txt")
    check "GPTBot allowed" "$(echo "$ROBOTS_BODY" | grep -qi "GPTBot" && echo true || echo false)"
    check "Sitemap declared" "$(echo "$ROBOTS_BODY" | grep -qi "Sitemap" && echo true || echo false)"
fi
echo ""

# Check llms.txt
bold "2. llms.txt"
LLMS=$(curl -s -o /dev/null -w "%{http_code}" "$URL/llms.txt" 2>/dev/null)
check "llms.txt accessible" "$([ "$LLMS" = "200" ] && echo true || echo false)"
echo ""

# Check response headers
bold "3. Response Headers"
HEADERS=$(curl -sI "$URL/" 2>/dev/null)
check "Content-Type present" "$(echo "$HEADERS" | grep -qi "content-type" && echo true || echo false)"
check "Cache-Control present" "$(echo "$HEADERS" | grep -qi "cache-control" && echo true || echo false)"
check "X-Robots-Tag present" "$(echo "$HEADERS" | grep -qi "x-robots-tag" && echo true || echo false)"
check "gzip supported" "$(curl -sI -H 'Accept-Encoding: gzip' "$URL/" | grep -qi "content-encoding.*gzip" && echo true || echo false)"
echo ""

# Check AI crawler simulation
bold "4. AI Crawler Access"
for BOT in "GPTBot/1.0" "PerplexityBot/1.0" "ClaudeBot/1.0"; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" -A "$BOT" "$URL/" 2>/dev/null)
    check "$BOT gets 200" "$([ "$CODE" = "200" ] && echo true || echo false)"
done
echo ""

# Summary
bold "=== Summary ==="
TOTAL=$((PASS + FAIL))
echo "  Passed: $PASS / $TOTAL"
if [ "$FAIL" -gt 0 ]; then
    red "  Failed: $FAIL checks need attention"
else
    green "  All checks passed!"
fi
echo ""
bold "Get your full GEO score at: https://geoscoreai.com"
echo "  Scan URL: ${URL}"
