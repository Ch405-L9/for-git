#!/usr/bin/env python3
"""
files-to-prompt: A CLI tool to batch ingest files and generate Claude-ready prompts
Created for CH405_047 | Chaos Line
"""

import os
import sys
import argparse
from pathlib import Path
from typing import List, Set
import mimetypes

# Default exclusions
DEFAULT_EXCLUDES = {
    '.git', '.gitignore', '__pycache__', 'node_modules', '.DS_Store',
    '.vscode', '.idea', '*.pyc', '*.pyo', '*.pyd', '.Python',
    'venv', 'env', '.env', 'dist', 'build', '*.egg-info'
}

# Supported text file extensions
TEXT_EXTENSIONS = {
    '.txt', '.md', '.py', '.js', '.jsx', '.ts', '.tsx', '.json',
    '.html', '.css', '.scss', '.sass', '.xml', '.yaml', '.yml',
    '.sh', '.bash', '.zsh', '.fish', '.bat', '.cmd', '.ps1',
    '.c', '.cpp', '.h', '.hpp', '.java', '.go', '.rs', '.rb',
    '.php', '.pl', '.r', '.sql', '.conf', '.config', '.ini',
    '.toml', '.properties', '.env.example', '.gitattributes'
}


def is_text_file(filepath: Path) -> bool:
    """Determine if a file is a text file."""
    if filepath.suffix.lower() in TEXT_EXTENSIONS:
        return True
    
    # Try to read first few bytes to detect binary
    try:
        with open(filepath, 'rb') as f:
            chunk = f.read(1024)
            if b'\x00' in chunk:
                return False
        return True
    except:
        return False


def should_exclude(path: Path, excludes: Set[str]) -> bool:
    """Check if path should be excluded."""
    path_str = str(path)
    name = path.name
    
    for exclude in excludes:
        if exclude.startswith('*.'):
            if name.endswith(exclude[1:]):
                return True
        elif exclude in path_str or name == exclude:
            return True
    
    return False


def collect_files(directory: Path, excludes: Set[str], recursive: bool = True) -> List[Path]:
    """Collect all valid text files from directory."""
    files = []
    
    try:
        items = sorted(directory.iterdir())
    except PermissionError:
        print(f"Warning: Permission denied for {directory}", file=sys.stderr)
        return files
    
    for item in items:
        if should_exclude(item, excludes):
            continue
        
        if item.is_file():
            if is_text_file(item):
                files.append(item)
        elif item.is_dir() and recursive:
            files.extend(collect_files(item, excludes, recursive))
    
    return files


def generate_tree(directory: Path, excludes: Set[str], prefix: str = "", is_last: bool = True) -> str:
    """Generate a visual tree structure of the directory."""
    tree_lines = []
    
    try:
        items = sorted(directory.iterdir())
    except PermissionError:
        return ""
    
    # Filter out excluded items
    items = [item for item in items if not should_exclude(item, excludes)]
    
    for i, item in enumerate(items):
        is_last_item = i == len(items) - 1
        connector = "└── " if is_last_item else "├── "
        
        if item.is_file():
            tree_lines.append(f"{prefix}{connector}{item.name}")
        elif item.is_dir():
            tree_lines.append(f"{prefix}{connector}{item.name}/")
            extension = "    " if is_last_item else "│   "
            tree_lines.append(generate_tree(item, excludes, prefix + extension, is_last_item))
    
    return "\n".join(filter(None, tree_lines))


def get_file_info(filepath: Path) -> str:
    """Get metadata about the file."""
    size = filepath.stat().st_size
    
    if size < 1024:
        size_str = f"{size} bytes"
    elif size < 1024 * 1024:
        size_str = f"{size / 1024:.1f} KB"
    else:
        size_str = f"{size / (1024 * 1024):.1f} MB"
    
    return f"{filepath.suffix[1:].upper() if filepath.suffix else 'TXT'} | {size_str}"


def read_file_content(filepath: Path) -> str:
    """Read file content with error handling."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except UnicodeDecodeError:
        try:
            with open(filepath, 'r', encoding='latin-1') as f:
                return f.read()
        except Exception as e:
            return f"[Error reading file: {e}]"
    except Exception as e:
        return f"[Error reading file: {e}]"


def generate_prompt(directory: Path, files: List[Path], 
                    show_tree: bool = True, 
                    add_instructions: bool = True) -> str:
    """Generate the complete prompt with all files."""
    
    prompt_parts = []
    
    # Header
    prompt_parts.append("=" * 80)
    prompt_parts.append("FILE INGESTION PROMPT")
    prompt_parts.append(f"Source Directory: {directory.absolute()}")
    prompt_parts.append(f"Total Files: {len(files)}")
    prompt_parts.append("=" * 80)
    prompt_parts.append("")
    
    # Directory tree
    if show_tree:
        prompt_parts.append("DIRECTORY STRUCTURE:")
        prompt_parts.append("-" * 80)
        prompt_parts.append(f"{directory.name}/")
        prompt_parts.append(generate_tree(directory, DEFAULT_EXCLUDES))
        prompt_parts.append("")
        prompt_parts.append("=" * 80)
        prompt_parts.append("")
    
    # Optional instructions
    if add_instructions:
        prompt_parts.append("INSTRUCTIONS:")
        prompt_parts.append("-" * 80)
        prompt_parts.append("Please analyze the following files and help me:")
        prompt_parts.append("1. Extract and organize components into /components directory")
        prompt_parts.append("2. Create templates in /templates directory")
        prompt_parts.append("3. Set up proper project structure with fonts, public, pages")
        prompt_parts.append("4. Generate a comprehensive README.md")
        prompt_parts.append("")
        prompt_parts.append("Focus on:")
        prompt_parts.append("- Component separation (Hero, CTA, Testimonials, PricingSection, Header, Footer)")
        prompt_parts.append("- Template creation (LandingPageBusiness, AgencySite, PortfolioSite)")
        prompt_parts.append("- Configuration files and scripts organization")
        prompt_parts.append("- Best practices and code quality")
        prompt_parts.append("")
        prompt_parts.append("=" * 80)
        prompt_parts.append("")
    
    # File contents
    prompt_parts.append("FILE CONTENTS:")
    prompt_parts.append("=" * 80)
    prompt_parts.append("")
    
    for i, filepath in enumerate(files, 1):
        relative_path = filepath.relative_to(directory)
        file_info = get_file_info(filepath)
        
        prompt_parts.append(f"[FILE {i}/{len(files)}]")
        prompt_parts.append(f"Path: {relative_path}")
        prompt_parts.append(f"Info: {file_info}")
        prompt_parts.append("-" * 80)
        
        content = read_file_content(filepath)
        prompt_parts.append(content)
        
        prompt_parts.append("")
        prompt_parts.append("-" * 80)
        prompt_parts.append("")
    
    # Footer
    prompt_parts.append("=" * 80)
    prompt_parts.append("END OF FILE INGESTION")
    prompt_parts.append(f"Total Files Processed: {len(files)}")
    prompt_parts.append("=" * 80)
    
    return "\n".join(prompt_parts)


def main():
    parser = argparse.ArgumentParser(
        description="Batch file ingestion tool for generating Claude-ready prompts",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Process all files in Downloads directory
  python files_to_prompt.py ~/Downloads
  
  # Process with output to file
  python files_to_prompt.py ~/Downloads -o prompt.txt
  
  # Non-recursive (current directory only)
  python files_to_prompt.py . --no-recursive
  
  # Without instructions
  python files_to_prompt.py ~/Downloads --no-instructions
  
  # Exclude additional patterns
  python files_to_prompt.py ~/Downloads -e "*.log" -e "temp*"
        """
    )
    
    parser.add_argument(
        'directory',
        type=str,
        help='Directory to process'
    )
    
    parser.add_argument(
        '-o', '--output',
        type=str,
        help='Output file (default: stdout)'
    )
    
    parser.add_argument(
        '-r', '--no-recursive',
        action='store_true',
        help='Do not process subdirectories'
    )
    
    parser.add_argument(
        '-t', '--no-tree',
        action='store_true',
        help='Do not include directory tree'
    )
    
    parser.add_argument(
        '-i', '--no-instructions',
        action='store_true',
        help='Do not include default instructions'
    )
    
    parser.add_argument(
        '-e', '--exclude',
        action='append',
        help='Additional exclude patterns (can be used multiple times)'
    )
    
    args = parser.parse_args()
    
    # Setup
    directory = Path(args.directory).expanduser().resolve()
    
    if not directory.exists():
        print(f"Error: Directory '{directory}' does not exist", file=sys.stderr)
        sys.exit(1)
    
    if not directory.is_dir():
        print(f"Error: '{directory}' is not a directory", file=sys.stderr)
        sys.exit(1)
    
    # Build exclusion set
    excludes = DEFAULT_EXCLUDES.copy()
    if args.exclude:
        excludes.update(args.exclude)
    
    # Collect files
    print(f"Scanning {directory}...", file=sys.stderr)
    files = collect_files(directory, excludes, recursive=not args.no_recursive)
    print(f"Found {len(files)} files", file=sys.stderr)
    
    if not files:
        print("No files found to process", file=sys.stderr)
        sys.exit(1)
    
    # Generate prompt
    print("Generating prompt...", file=sys.stderr)
    prompt = generate_prompt(
        directory,
        files,
        show_tree=not args.no_tree,
        add_instructions=not args.no_instructions
    )
    
    # Output
    if args.output:
        output_path = Path(args.output)
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(prompt)
        print(f"Prompt written to {output_path}", file=sys.stderr)
    else:
        print(prompt)
    
    print(f"Done! Processed {len(files)} files", file=sys.stderr)


if __name__ == "__main__":
    main()
