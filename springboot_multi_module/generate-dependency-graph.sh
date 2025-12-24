#!/bin/bash
# Dependency Graph Generator Script
# This script generates various dependency reports for the Spring Boot multi-module project

set -e

echo "=============================================="
echo "  Dependency Graph Generator"
echo "=============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Navigate to project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}[1/5]${NC} Generating project structure..."
./gradlew printProjectStructure

echo ""
echo -e "${BLUE}[2/5]${NC} Generating dependency trees..."
echo ""
echo "Common module dependencies:"
echo "=============================="
./gradlew :common:dependencies --configuration implementation

echo ""
echo "Search module dependencies:"
echo "=============================="
./gradlew :search:dependencies --configuration implementation

echo ""
echo -e "${BLUE}[3/5]${NC} Generating comprehensive dependency reports..."
./gradlew generateDependencyGraph

echo ""
echo -e "${BLUE}[4/5]${NC} Generating HTML dependency report..."
./gradlew htmlDependencyReport

echo ""
echo -e "${BLUE}[5/5]${NC} Dependency graph generation complete!"
echo ""
echo -e "${GREEN}Reports generated:${NC}"
echo "  1. Console output: See above"
echo "  2. HTML Report: build/reports/project/dependencies/index.html"
echo "  3. Documentation: DEPENDENCY_GRAPH.md"
echo ""
echo -e "${GREEN}View documentation:${NC}"
echo "  cat DEPENDENCY_GRAPH.md"
echo ""
echo -e "${GREEN}Open HTML report:${NC}"
echo "  open build/reports/project/dependencies/index.html  # macOS"
echo "  xdg-open build/reports/project/dependencies/index.html  # Linux"
echo ""
echo "=============================================="
