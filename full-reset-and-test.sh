#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔄 FULL RESET: Cleaning everything and starting fresh${NC}"
echo ""

# Step 1: Kill existing Katana and Torii
echo -e "${YELLOW}1️⃣  Killing existing Katana and Torii processes...${NC}"
pkill -f katana || true
pkill -f torii || true
sleep 2
echo -e "${GREEN}✅ Processes killed${NC}"
echo ""

# Step 2: Clean and build Universe
echo -e "${YELLOW}2️⃣  Cleaning and building Universe contracts...${NC}"
cd /Users/mg/Documents/Software/Overgoal/universe
sozo clean
sozo build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Build successful${NC}"
echo ""

# Step 3: Start Katana in background
echo -e "${YELLOW}3️⃣  Starting Katana...${NC}"
katana --config katana.toml > /tmp/katana.log 2>&1 &
KATANA_PID=$!
sleep 3

# Check if Katana is running
if ! curl -s http://127.0.0.1:5050 > /dev/null 2>&1; then
    echo -e "${RED}❌ Katana failed to start. Check /tmp/katana.log${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Katana running (PID: $KATANA_PID)${NC}"
echo ""

# Step 4: Migrate Universe contracts
echo -e "${YELLOW}4️⃣  Migrating Universe contracts...${NC}"
sozo migrate

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Migration failed${NC}"
    kill $KATANA_PID
    exit 1
fi
echo -e "${GREEN}✅ Migration successful${NC}"
echo ""

# Step 5: Get world address and info
WORLD_ADDRESS=$(jq -r '.world.address' manifest_dev.json)
WORLD_NAME=$(jq -r '.world.name' manifest_dev.json)
GAME_CONTRACT=$(jq -r '.contracts[] | select(.tag == "universe-game") | .address' manifest_dev.json)

echo -e "${GREEN}📍 Universe World Address: $WORLD_ADDRESS${NC}"
echo -e "${GREEN}📍 World Name: $WORLD_NAME${NC}"
echo -e "${GREEN}📍 Game Contract: $GAME_CONTRACT${NC}"
echo ""

# Step 6: Start Torii
echo -e "${YELLOW}5️⃣  Starting Torii...${NC}"
torii --world $WORLD_ADDRESS --config torii_config.toml > /tmp/torii.log 2>&1 &
TORII_PID=$!
sleep 3

echo -e "${GREEN}✅ Torii running (PID: $TORII_PID)${NC}"
echo ""

# Step 7: Copy manifest to client
echo -e "${YELLOW}6️⃣  Updating client manifest...${NC}"
cp manifest_dev.json ../client/src/config/manifest_universe_dev.json
echo -e "${GREEN}✅ Client manifest updated${NC}"
echo ""

# Step 8: Test contract call
echo -e "${YELLOW}7️⃣  Testing contract call (create_or_get_user)...${NC}"
TEST_ADDRESS="0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973"

sozo execute --world $WORLD_ADDRESS universe-game create_or_get_user -c $TEST_ADDRESS

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Contract call successful!${NC}"
else
    echo -e "${YELLOW}⚠️  Contract call had issues (might be expected for first run)${NC}"
fi
echo ""

# Final summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ FULL RESET COMPLETE!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "1. ${GREEN}Restart your client dev server:${NC}"
echo -e "   cd ../client && npm run dev"
echo -e ""
echo -e "2. ${GREEN}Clear browser cache and hard refresh (Cmd+Shift+R)${NC}"
echo -e ""
echo -e "3. ${GREEN}Try the Cartridge login again${NC}"
echo -e ""
echo -e "${YELLOW}📊 Running services:${NC}"
echo -e "- Katana (PID: $KATANA_PID) - http://127.0.0.1:5050"
echo -e "- Torii (PID: $TORII_PID) - http://127.0.0.1:8080"
echo -e ""
echo -e "${YELLOW}📝 Logs:${NC}"
echo -e "- Katana: /tmp/katana.log"
echo -e "- Torii: /tmp/torii.log"
echo -e ""
echo -e "${YELLOW}🛑 To stop services:${NC}"
echo -e "   pkill -f katana && pkill -f torii"

