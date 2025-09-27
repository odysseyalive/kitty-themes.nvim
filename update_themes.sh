#!/bin/bash
# Script to update themes from upstream kitty-themes repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"
UPSTREAM_BASE_URL="https://raw.githubusercontent.com/kovidgoyal/kitty-themes/master/themes"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get all themes from upstream
get_upstream_themes() {
    log_info "Fetching list of themes from upstream..."
    
    # Use GitHub API to get all theme files
    curl -s "https://api.github.com/repos/kovidgoyal/kitty-themes/contents/themes" | \
        jq -r '.[] | select(.name | endswith(".conf")) | .name' | \
        sort > /tmp/upstream_themes.txt
    
    if [ ! -s /tmp/upstream_themes.txt ]; then
        log_error "Failed to fetch upstream themes list"
        exit 1
    fi
    
    local upstream_count=$(wc -l < /tmp/upstream_themes.txt)
    log_success "Found $upstream_count themes in upstream repository"
}

# Get current local themes
get_local_themes() {
    log_info "Scanning local themes..."
    
    ls -1 "$THEMES_DIR"/*.conf 2>/dev/null | xargs -n1 basename | sort > /tmp/local_themes.txt
    
    local local_count=$(wc -l < /tmp/local_themes.txt)
    log_success "Found $local_count themes locally"
}

# Find missing themes
find_missing_themes() {
    log_info "Comparing local and upstream themes..."
    
    comm -23 /tmp/upstream_themes.txt /tmp/local_themes.txt > /tmp/missing_themes.txt
    
    local missing_count=$(wc -l < /tmp/missing_themes.txt)
    
    if [ "$missing_count" -eq 0 ]; then
        log_success "All themes are up to date!"
        return 0
    fi
    
    log_warning "Found $missing_count missing themes:"
    while IFS= read -r theme; do
        echo "  - $theme"
    done < /tmp/missing_themes.txt
    
    return 1
}

# Download missing themes
download_missing_themes() {
    log_info "Downloading missing themes..."
    
    local downloaded=0
    local failed=0
    
    while IFS= read -r theme; do
        local theme_url="$UPSTREAM_BASE_URL/$theme"
        local theme_path="$THEMES_DIR/$theme"
        
        log_info "Downloading $theme..."
        
        if wget -q -O "$theme_path" "$theme_url"; then
            log_success "Downloaded $theme"
            ((downloaded++))
        else
            log_error "Failed to download $theme"
            ((failed++))
        fi
    done < /tmp/missing_themes.txt
    
    log_success "Downloaded $downloaded themes"
    if [ "$failed" -gt 0 ]; then
        log_warning "$failed themes failed to download"
    fi
}

# Rebuild colorschemes
rebuild_colorschemes() {
    log_info "Rebuilding colorscheme files..."
    
    if python3 "$SCRIPT_DIR/build.py"; then
        log_success "Colorscheme files rebuilt successfully"
    else
        log_error "Failed to rebuild colorscheme files"
        exit 1
    fi
}

# Update embedded data if build script supports it
update_embedded_data() {
    if [ -x "$SCRIPT_DIR/build.sh" ]; then
        log_info "Updating embedded theme data..."
        if "$SCRIPT_DIR/build.sh" --embedded; then
            log_success "Embedded theme data updated"
        else
            log_warning "Failed to update embedded data, but continuing..."
        fi
    fi
}

# Clean up temporary files
cleanup() {
    rm -f /tmp/upstream_themes.txt /tmp/local_themes.txt /tmp/missing_themes.txt
}

# Show help
show_help() {
    cat << EOF
Update Kitty Themes Script

This script updates the local themes directory with missing themes from
the upstream kitty-themes repository.

Usage: $0 [OPTIONS]

OPTIONS:
    --check, -c        Only check for missing themes (don't download)
    --force, -f        Download all themes (overwrite existing)
    --help, -h         Show this help message

Examples:
    $0                 # Check and download missing themes
    $0 --check         # Only show missing themes
    $0 --force         # Download all themes (overwrite existing)
EOF
}

# Main function
main() {
    local check_only=false
    local force_download=false
    
    case "${1:-}" in
        --check|-c)
            check_only=true
            ;;
        --force|-f)
            force_download=true
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        "")
            # Default behavior
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
    
    # Ensure themes directory exists
    mkdir -p "$THEMES_DIR"
    
    # Get theme lists
    get_upstream_themes
    get_local_themes
    
    if [ "$force_download" = true ]; then
        log_info "Force downloading all themes..."
        cp /tmp/upstream_themes.txt /tmp/missing_themes.txt
    else
        # Find missing themes
        if find_missing_themes && [ "$check_only" = true ]; then
            cleanup
            exit 0
        fi
    fi
    
    if [ "$check_only" = true ]; then
        cleanup
        exit 0
    fi
    
    # Download missing themes
    download_missing_themes
    
    # Rebuild everything
    rebuild_colorschemes
    update_embedded_data
    
    # Show final summary
    local final_count=$(ls -1 "$THEMES_DIR"/*.conf 2>/dev/null | wc -l)
    log_success "Theme update complete! Total themes: $final_count"
    
    cleanup
}

# Trap cleanup on exit
trap cleanup EXIT

main "$@"