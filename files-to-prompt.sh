#!/bin/bash
# files-to-prompt.sh - Quick batch file ingestion for Claude
# Created for CH405_047 | Chaos Line

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default values
RECURSIVE=true
SHOW_TREE=true
SHOW_INSTRUCTIONS=true
OUTPUT_FILE=""

# Help function
show_help() {
    cat << EOF
files-to-prompt - Batch file ingestion tool for Claude

USAGE:
    ./files-to-prompt.sh [OPTIONS] <directory>

OPTIONS:
    -o FILE         Output to file instead of stdout
    -n              Non-recursive (current directory only)
    -t              Skip directory tree
    -i              Skip instructions
    -h              Show this help message

EXAMPLES:
    # Process Downloads directory
    ./files-to-prompt.sh ~/Downloads

    # Save to file
    ./files-to-prompt.sh ~/Downloads -o prompt.txt

    # Quick mode (no tree, no instructions)
    ./files-to-prompt.sh ~/Downloads -t -i -o prompt.txt

    # Current directory only
    ./files-to-prompt.sh . -n

Created for CH405_047 | Chaos Line
EOF
    exit 0
}

# Parse arguments
while getopts "o:ntih" opt; do
    case $opt in
        o) OUTPUT_FILE="$OPTARG" ;;
        n) RECURSIVE=false ;;
        t) SHOW_TREE=false ;;
        i) SHOW_INSTRUCTIONS=false ;;
        h) show_help ;;
        \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    esac
done

shift $((OPTIND-1))

# Check directory argument
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Directory argument required${NC}" >&2
    echo "Use -h for help" >&2
    exit 1
fi

DIRECTORY="$1"

# Validate directory
if [ ! -d "$DIRECTORY" ]; then
    echo -e "${RED}Error: '$DIRECTORY' is not a directory${NC}" >&2
    exit 1
fi

# Convert to absolute path
DIRECTORY=$(cd "$DIRECTORY" && pwd)

echo -e "${BLUE}Scanning: $DIRECTORY${NC}" >&2

# Function to check if file is text
is_text_file() {
    local file="$1"
    
    # Check by extension
    case "${file,,}" in
        *.txt|*.md|*.py|*.js|*.jsx|*.ts|*.tsx|*.json|*.html|*.css|*.scss|\
        *.xml|*.yaml|*.yml|*.sh|*.bash|*.bat|*.cmd|*.ps1|*.c|*.cpp|*.h|\
        *.java|*.go|*.rs|*.rb|*.php|*.sql|*.conf|*.ini|*.toml)
            return 0
            ;;
    esac
    
    # Check if binary
    if file "$file" | grep -q text; then
        return 0
    fi
    
    return 1
}

# Function to generate tree
generate_tree() {
    local dir="$1"
    local prefix="$2"
    
    tree -a -I '.git|node_modules|__pycache__|.DS_Store|*.pyc|venv|dist|build' -L 3 "$dir" 2>/dev/null || \
    find "$dir" -maxdepth 3 -not -path '*/\.*' -not -path '*/node_modules/*' -not -path '*/__pycache__/*' | \
    sed "s|$dir|.|" | sort
}

# Collect files
collect_files() {
    local dir="$1"
    local recursive="$2"
    
    if [ "$recursive" = true ]; then
        find "$dir" -type f \
            ! -path '*/.*' \
            ! -path '*/node_modules/*' \
            ! -path '*/__pycache__/*' \
            ! -path '*/venv/*' \
            ! -path '*/dist/*' \
            ! -path '*/build/*' \
            ! -name '*.pyc' \
            ! -name '.DS_Store'
    else
        find "$dir" -maxdepth 1 -type f \
            ! -name '.*' \
            ! -name '*.pyc'
    fi
}

# Generate prompt
generate_prompt() {
    local dir="$1"
    local files="$2"
    local file_count=$(echo "$files" | wc -l)
    
    # Header
    echo "================================================================================"
    echo "FILE INGESTION PROMPT"
    echo "Source Directory: $dir"
    echo "Total Files: $file_count"
    echo "================================================================================"
    echo ""
    
    # Directory tree
    if [ "$SHOW_TREE" = true ]; then
        echo "DIRECTORY STRUCTURE:"
        echo "--------------------------------------------------------------------------------"
        generate_tree "$dir" ""
        echo ""
        echo "================================================================================"
        echo ""
    fi
    
    # Instructions
    if [ "$SHOW_INSTRUCTIONS" = true ]; then
        echo "INSTRUCTIONS:"
        echo "--------------------------------------------------------------------------------"
        echo "Please analyze the following files and help me:"
        echo "1. Extract and organize components into /components directory"
        echo "2. Create templates in /templates directory"
        echo "3. Set up proper project structure with fonts, public, pages"
        echo "4. Generate a comprehensive README.md"
        echo ""
        echo "Focus on:"
        echo "- Component separation (Hero, CTA, Testimonials, PricingSection, Header, Footer)"
        echo "- Template creation (LandingPageBusiness, AgencySite, PortfolioSite)"
        echo "- Configuration files and scripts organization"
        echo "- Best practices and code quality"
        echo ""
        echo "================================================================================"
        echo ""
    fi
    
    # File contents
    echo "FILE CONTENTS:"
    echo "================================================================================"
    echo ""
    
    local i=1
    while IFS= read -r file; do
        if [ -f "$file" ] && is_text_file "$file"; then
            local relative_path="${file#$dir/}"
            local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            local file_ext="${file##*.}"
            
            echo "[FILE $i/$file_count]"
            echo "Path: $relative_path"
            echo "Info: ${file_ext^^} | $file_size bytes"
            echo "--------------------------------------------------------------------------------"
            cat "$file"
            echo ""
            echo "--------------------------------------------------------------------------------"
            echo ""
            
            ((i++))
        fi
    done <<< "$files"
    
    # Footer
    echo "================================================================================"
    echo "END OF FILE INGESTION"
    echo "Total Files Processed: $file_count"
    echo "================================================================================"
}

# Main execution
echo -e "${GREEN}Collecting files...${NC}" >&2
FILES=$(collect_files "$DIRECTORY" "$RECURSIVE")
FILE_COUNT=$(echo "$FILES" | wc -l)

if [ -z "$FILES" ]; then
    echo -e "${RED}No files found${NC}" >&2
    exit 1
fi

echo -e "${GREEN}Found $FILE_COUNT files${NC}" >&2
echo -e "${BLUE}Generating prompt...${NC}" >&2

# Generate and output
if [ -n "$OUTPUT_FILE" ]; then
    generate_prompt "$DIRECTORY" "$FILES" > "$OUTPUT_FILE"
    echo -e "${GREEN}Prompt written to $OUTPUT_FILE${NC}" >&2
else
    generate_prompt "$DIRECTORY" "$FILES"
fi

echo -e "${GREEN}Done!${NC}" >&2
