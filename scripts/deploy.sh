#!/usr/bin/env bash
# Publish the journal to Vercel as prebuilt static output.
# Jekyll builds locally, then we ship _site via the Build Output API with
# `vercel deploy --prebuilt` so Vercel never runs Ruby/bundler.
set -euo pipefail
cd "$(dirname "$0")/.."

bundle exec jekyll build

rm -rf .vercel/output
mkdir -p .vercel/output/static
cp -R _site/. .vercel/output/static/
printf '{"version":3}\n' > .vercel/output/config.json

vercel deploy --prebuilt --prod --yes
