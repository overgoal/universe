#!/bin/bash

# Script to redeploy Universe and update client manifest
# This fixes "invalid signature" errors caused by manifest/deployment mismatch

echo "🔧 Redeploying Universe and updating client manifest..."
echo ""

# Check if Katana is running
if ! curl -s http://127.0.0.1:5050 > /dev/null 2>&1; then
    echo "❌ Katana is not running!"
    echo "   Start it with: katana --config katana.toml"
    exit 1
fi

echo "✅ Katana is running"
echo ""

# Clean and build
echo "🧹 Cleaning..."
sozo clean

echo "🔨 Building..."
sozo build

# Deploy
echo "🚀 Deploying to Katana..."
sozo migrate

if [ $? -ne 0 ]; then
    echo "❌ Deployment failed!"
    exit 1
fi

echo "✅ Deployment successful!"
echo ""

# Update client manifest
echo "📋 Updating client manifest..."
cp manifest_dev.json ../client/src/config/manifest_universe_dev.json

if [ $? -eq 0 ]; then
    echo "✅ Client manifest updated!"
else
    echo "❌ Failed to update client manifest"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ ALL DONE!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📝 Next steps:"
echo "   1. cd ../client"
echo "   2. npm run dev"
echo "   3. Test Cartridge login"
echo ""
echo "🎉 The 'invalid signature' error should now be fixed!"
echo ""


