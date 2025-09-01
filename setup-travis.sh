#!/bin/bash

# Travis CI Setup Script
# This script helps you set up Travis CI for your React/Vite project

set -e

echo "🚀 Travis CI Setup for React/Vite Project"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Travis CLI is installed
if ! command -v travis &> /dev/null; then
    echo -e "${YELLOW}Travis CLI not found. Installing...${NC}"
    if command -v gem &> /dev/null; then
        gem install travis
    else
        echo -e "${RED}Ruby/Gem not found. Please install Ruby first.${NC}"
        echo "Visit: https://www.ruby-lang.org/en/documentation/installation/"
        exit 1
    fi
fi

# Login to Travis
echo -e "${BLUE}Logging into Travis CI...${NC}"
echo "Please follow the authentication prompts:"
travis login --github

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Not in a git repository!${NC}"
    exit 1
fi

# Get repository information
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename -s .git "$REPO_URL")
REPO_OWNER=$(basename $(dirname "$REPO_URL"))

echo -e "${GREEN}Repository: ${REPO_OWNER}/${REPO_NAME}${NC}"

# Enable Travis for this repository
echo -e "${BLUE}Enabling Travis CI for this repository...${NC}"
travis enable

# Set up environment variables
echo -e "${YELLOW}Setting up environment variables...${NC}"

# Function to add encrypted environment variable
add_encrypted_env() {
    local var_name=$1
    local var_description=$2
    
    echo -e "${BLUE}Setting up ${var_name} (${var_description})${NC}"
    read -p "Enter ${var_name}: " var_value
    
    if [ ! -z "$var_value" ]; then
        travis env set "$var_name" "$var_value"
        echo -e "${GREEN}✅ ${var_name} set successfully${NC}"
    else
        echo -e "${YELLOW}⚠️ Skipping ${var_name}${NC}"
    fi
}

# Required environment variables
echo -e "${YELLOW}Required Environment Variables:${NC}"
add_encrypted_env "DOCKER_USERNAME" "Docker registry username"
add_encrypted_env "DOCKER_PASSWORD" "Docker registry password/token"
add_encrypted_env "DOCKER_IMAGE" "Docker image name (e.g., username/react-app)"

# Optional environment variables
echo -e "${YELLOW}Optional Environment Variables (press Enter to skip):${NC}"
add_encrypted_env "STAGING_SERVER" "Staging server hostname"
add_encrypted_env "PRODUCTION_SERVER" "Production server hostname"
add_encrypted_env "DEPLOY_USER" "Deployment user"
add_encrypted_env "SLACK_WEBHOOK_URL" "Slack webhook URL for notifications"

# SSH key setup for deployments
echo -e "${BLUE}SSH Key Setup for Deployments${NC}"
read -p "Do you want to set up SSH keys for deployment? (y/n): " setup_ssh

if [[ $setup_ssh =~ ^[Yy]$ ]]; then
    if [ -f "$HOME/.ssh/id_rsa" ]; then
        echo -e "${BLUE}Encrypting SSH private key...${NC}"
        travis encrypt-file "$HOME/.ssh/id_rsa" --add
        echo -e "${GREEN}✅ SSH key encrypted and added to .travis.yml${NC}"
    else
        echo -e "${YELLOW}No SSH key found at ~/.ssh/id_rsa${NC}"
        echo "Generate one with: ssh-keygen -t rsa -b 4096 -C 'your_email@example.com'"
    fi
fi

# Create Travis CI badge
echo -e "${BLUE}Creating Travis CI badge...${NC}"
BADGE_URL="https://travis-ci.com/${REPO_OWNER}/${REPO_NAME}.svg?branch=main"
BADGE_MARKDOWN="[![Build Status](${BADGE_URL})](https://travis-ci.com/${REPO_OWNER}/${REPO_NAME})"

echo -e "${GREEN}Add this badge to your README.md:${NC}"
echo "$BADGE_MARKDOWN"

# Validate .travis.yml
echo -e "${BLUE}Validating .travis.yml configuration...${NC}"
if travis lint .travis.yml; then
    echo -e "${GREEN}✅ .travis.yml is valid${NC}"
else
    echo -e "${RED}❌ .travis.yml has issues. Please check the configuration.${NC}"
fi

# Summary
echo -e "${GREEN}"
echo "================================================"
echo "🎉 Travis CI Setup Complete!"
echo "================================================"
echo -e "${NC}"

echo -e "${BLUE}Next Steps:${NC}"
echo "1. Commit your changes:"
echo "   git add .travis.yml deploy-*.sh"
echo "   git commit -m 'Add Travis CI configuration'"
echo "   git push origin main"
echo ""
echo "2. Visit https://travis-ci.com/${REPO_OWNER}/${REPO_NAME} to monitor builds"
echo ""
echo "3. Configure your deployment servers and update deploy scripts"
echo ""
echo "4. Test your first build by making a commit"

echo -e "${YELLOW}Important Files Created:${NC}"
echo "  📄 .travis.yml - Main Travis configuration"
echo "  🚀 deploy-staging.sh - Staging deployment script"
echo "  🌍 deploy-production.sh - Production deployment script"
echo "  🐳 Dockerfile.travis - Optimized Docker build"
echo "  📋 travis-setup.md - Complete setup guide"

echo -e "${GREEN}Happy building! 🚀${NC}"

