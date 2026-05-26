#!/usr/bin/env bash
set -e

echo "→ Cleaning..."
npx hexo clean

echo "→ Generating..."
npx hexo generate

echo "→ Deploying..."
npx hexo deploy

echo "✓ Done"
