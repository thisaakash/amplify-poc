#!/bin/bash

# Script to create 120 branches from main and deploy each to Vercel progressively
# Usage: ./deploy-branches.sh

set -e  # Exit on error

TOTAL_BRANCHES=120
BASE_BRANCH="main"
BRANCH_PREFIX="test-deploy"

echo "🚀 Starting progressive branch creation and Vercel deployment"
echo "=================================================="

# Ensure we're on main branch and it's up to date
echo "📍 Switching to main branch..."
git checkout main
git pull origin main

# Loop through and create branches progressively
for i in $(seq 1 $TOTAL_BRANCHES); do
    BRANCH_NAME="${BRANCH_PREFIX}-${i}"
    
    echo ""
    echo "=================================================="
    echo "🌿 Processing branch ${i}/${TOTAL_BRANCHES}: ${BRANCH_NAME}"
    echo "=================================================="
    
    # Check if branch already exists locally
    if git show-ref --verify --quiet refs/heads/${BRANCH_NAME}; then
        echo "⏭️  Branch ${BRANCH_NAME} already exists locally, skipping..."
        continue
    fi
    
    # Create new branch from main
    echo "📝 Creating branch: ${BRANCH_NAME}"
    git checkout -b ${BRANCH_NAME}
    
    # Make a small change to trigger deployment (update README with timestamp)
    echo "✏️  Making a small change..."
    echo "<!-- Branch ${BRANCH_NAME} created at $(date) -->" >> README.md
    
    # Commit the change
    echo "💾 Committing changes..."
    git add README.md
    git commit -m "Deploy test for branch ${BRANCH_NAME}"
    
    # Push to remote
    echo "⬆️  Pushing branch to remote..."
    git push origin ${BRANCH_NAME}
    
    # Deploy to Vercel
    echo "🚀 Deploying to Vercel..."
    vercel
    
    echo "✅ Branch ${BRANCH_NAME} deployed successfully!"
    
    # Go back to main for next iteration
    git checkout main
    
    # Optional: Add a small delay to avoid rate limiting
    if [ $((i % 10)) -eq 0 ]; then
        echo "⏸️  Pausing for 5 seconds to avoid rate limiting..."
        sleep 5
    fi
done

echo ""
echo "=================================================="
echo "🎉 All ${TOTAL_BRANCHES} branches created and deployed!"
echo "=================================================="
echo ""
echo "📋 Summary:"
echo "- Base branch: ${BASE_BRANCH}"
echo "- Branch pattern: ${BRANCH_PREFIX}-1 to ${BRANCH_PREFIX}-${TOTAL_BRANCHES}"
echo "- All branches have been pushed to remote"
echo "- All branches have been deployed to Vercel"
