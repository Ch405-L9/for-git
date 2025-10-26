# files-to-prompt

**Batch File Ingestion Tool for Claude**  
Created for CH405_047 | Chaos Line

A powerful CLI tool to concatenate multiple files into a single, Claude-ready prompt. Perfect for ingesting entire project directories, configuration files, scripts, and documentation into Claude for analysis, refactoring, or component extraction.

---

## Features

- **Multi-file ingestion**: Process dozens of files in one shot
- **Smart filtering**: Automatically excludes `.git`, `node_modules`, `__pycache__`, and other noise
- **Directory tree visualization**: Generates a clean file structure overview
- **File metadata**: Includes file paths, types, and sizes
- **Configurable instructions**: Built-in prompt templates for common tasks
- **Cross-platform**: Python CLI, Bash script, and Windows batch file
- **Text file detection**: Automatically identifies and processes text-based files

---

## Installation

### Python CLI (Recommended)

**Requirements**: Python 3.6+

```bash
# Download the script
curl -O https://path-to-script/files_to_prompt.py

# Make executable (Unix/macOS)
chmod +x files_to_prompt.py

# Run
python files_to_prompt.py <directory>
```

### Bash Script (Unix/macOS/Linux)

```bash
# Download
curl -O https://path-to-script/files-to-prompt.sh

# Make executable
chmod +x files-to-prompt.sh

# Run
./files-to-prompt.sh <directory>
```

### Windows Batch File

```cmd
REM Download files-to-prompt.bat to your system

REM Run
files-to-prompt.bat C:\path\to\directory
```

---

## Quick Start

### Basic Usage

```bash
# Python
python files_to_prompt.py ~/Downloads

# Bash
./files-to-prompt.sh ~/Downloads

# Windows
files-to-prompt.bat C:\Users\YourName\Downloads
```

### Save to File

```bash
# Python
python files_to_prompt.py ~/Downloads -o prompt.txt

# Bash
./files-to-prompt.sh ~/Downloads -o prompt.txt

# Windows
files-to-prompt.bat C:\Users\YourName\Downloads -o prompt.txt
```

### Current Directory Only (Non-recursive)

```bash
# Python
python files_to_prompt.py . --no-recursive

# Bash
./files-to-prompt.sh . -n

# Windows
files-to-prompt.bat . -n
```

---

## Command-Line Options

### Python CLI

| Option | Description |
|--------|-------------|
| `directory` | Directory to process (required) |
| `-o, --output FILE` | Write output to file instead of stdout |
| `-r, --no-recursive` | Don't process subdirectories |
| `-t, --no-tree` | Skip directory tree visualization |
| `-i, --no-instructions` | Skip default instructions section |
| `-e, --exclude PATTERN` | Exclude additional patterns (repeatable) |

### Bash Script

| Option | Description |
|--------|-------------|
| `directory` | Directory to process (required) |
| `-o FILE` | Write output to file |
| `-n` | Non-recursive mode |
| `-t` | Skip tree |
| `-i` | Skip instructions |
| `-h` | Show help |

### Windows Batch

| Option | Description |
|--------|-------------|
| `directory` | Directory to process (required) |
| `-o FILE` | Write output to file |
| `-n` | Non-recursive mode |
| `-t` | Skip tree |
| `-i` | Skip instructions |
| `-h` | Show help |

---

## Use Cases

### 1. Component Extraction from Mixed Files

You have a directory with HTML, CSS, JS, Markdown guides, and config files. You want Claude to extract React components.

```bash
python files_to_prompt.py ~/project-files -o prompt.txt
```

Then paste `prompt.txt` into Claude with:
> "Extract all reusable components and organize them into /components, /templates, and proper project structure"

### 2. Codebase Analysis

Analyze an entire project structure:

```bash
python files_to_prompt.py ~/my-app -o analysis-prompt.txt
```

Claude can now review your entire codebase and provide:
- Architecture recommendations
- Code quality issues
- Security vulnerabilities
- Performance optimizations

### 3. Documentation Generation

Feed all your scripts and configs to Claude:

```bash
./files-to-prompt.sh ~/scripts -o docs-prompt.txt
```

Ask Claude to:
> "Generate comprehensive documentation for these scripts including usage examples, prerequisites, and troubleshooting"

### 4. Configuration Migration

Migrate configs from old to new format:

```bash
python files_to_prompt.py ~/old-configs -o migration.txt
```

Prompt Claude:
> "Convert these configuration files from format X to format Y, maintaining all functionality"

### 5. Project Scaffolding

Extract patterns from example projects:

```bash
./files-to-prompt.sh ~/example-projects -t -i -o scaffold.txt
```

Ask Claude:
> "Create a project template based on these examples with best practices"

---

## Output Format

The generated prompt includes:

### 1. Header Section
```
================================================================================
FILE INGESTION PROMPT
Source Directory: /path/to/directory
Total Files: 47
================================================================================
```

### 2. Directory Structure (optional)
```
DIRECTORY STRUCTURE:
--------------------------------------------------------------------------------
project/
├── components/
│   ├── Hero.jsx
│   └── CTA.jsx
├── templates/
│   └── LandingPage.jsx
└── README.md
```

### 3. Instructions (optional)
```
INSTRUCTIONS:
--------------------------------------------------------------------------------
Please analyze the following files and help me:
1. Extract and organize components into /components directory
2. Create templates in /templates directory
3. Set up proper project structure
...
```

### 4. File Contents
```
[FILE 1/47]
Path: components/Hero.jsx
Info: JSX | 2.4 KB
--------------------------------------------------------------------------------
import React from 'react';
...
--------------------------------------------------------------------------------
```

### 5. Footer
```
================================================================================
END OF FILE INGESTION
Total Files Processed: 47
================================================================================
```

---

## Supported File Types

The tool automatically detects and processes:

**Code**: `.py`, `.js`, `.jsx`, `.ts`, `.tsx`, `.c`, `.cpp`, `.java`, `.go`, `.rs`, `.rb`, `.php`  
**Web**: `.html`, `.css`, `.scss`, `.sass`, `.xml`  
**Config**: `.json`, `.yaml`, `.yml`, `.toml`, `.ini`, `.conf`, `.env.example`  
**Scripts**: `.sh`, `.bash`, `.zsh`, `.fish`, `.bat`, `.cmd`, `.ps1`  
**Docs**: `.md`, `.txt`  
**Database**: `.sql`

Binary files, images, videos, and other non-text formats are automatically excluded.

---

## Default Exclusions

The tool automatically skips:

- `.git/` and `.gitignore`
- `node_modules/`
- `__pycache__/` and `*.pyc`
- `venv/`, `env/`, `.env`
- `dist/`, `build/`
- `.DS_Store`
- `.vscode/`, `.idea/`
- `*.egg-info`

Add custom exclusions with the `-e` flag (Python CLI):

```bash
python files_to_prompt.py ~/project -e "*.log" -e "temp*" -e "backup/"
```

---

## Advanced Examples

### Project Component Extraction

You have a messy download folder with HTML templates, React components, CSS files, and documentation. Extract everything into a clean structure:

```bash
# Step 1: Generate prompt
python files_to_prompt.py ~/Downloads -o project-prompt.txt

# Step 2: Upload to Claude with this prompt:
# "Analyze these files and create:
# 1. /components directory with: Hero, CTA, Testimonials, PricingSection, Header, Footer
# 2. /templates directory with: LandingPageBusiness, AgencySite, PortfolioSite
# 3. /fonts directory with font configurations
# 4. /public directory with assets
# 5. Sample pages using the components
# 6. Complete README.md with setup instructions"
```

### Code Review Workflow

```bash
# Generate prompt without tree/instructions for cleaner output
python files_to_prompt.py ~/my-app --no-tree --no-instructions -o review.txt

# Ask Claude specific questions:
# - "Review for security vulnerabilities"
# - "Identify performance bottlenecks"
# - "Suggest architectural improvements"
# - "Check for code duplication"
```

### Documentation Sprint

```bash
# Batch process multiple directories
for dir in api-scripts automation-tools config-files; do
    python files_to_prompt.py ~/$dir -o ${dir}-docs.txt
done

# Feed each to Claude:
# "Generate complete API documentation with examples"
# "Create user guides for these automation tools"
# "Document all configuration options"
```

### Migration Assistant

```bash
# Old project
python files_to_prompt.py ~/legacy-project -o legacy.txt

# New framework docs
python files_to_prompt.py ~/new-framework-examples -o new-framework.txt

# Combine prompts and ask Claude:
# "Migrate this legacy project to the new framework, maintaining all functionality"
```

---

## Integration with Claude

### Workflow 1: Copy/Paste

```bash
# Generate to stdout and copy
python files_to_prompt.py ~/project | pbcopy  # macOS
python files_to_prompt.py ~/project | xclip    # Linux
python files_to_prompt.py ~/project | clip     # Windows

# Paste directly into Claude interface
```

### Workflow 2: File Upload

```bash
# Save to file
python files_to_prompt.py ~/project -o prompt.txt

# Upload prompt.txt to Claude
# Add your specific instructions
```

### Workflow 3: API Integration

```python
# Use with Claude API
import anthropic

# Generate prompt
prompt = subprocess.check_output(['python', 'files_to_prompt.py', '/path/to/dir'])

# Send to Claude
client = anthropic.Anthropic(api_key="your-key")
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    messages=[{
        "role": "user",
        "content": prompt.decode('utf-8') + "\n\nExtract all components..."
    }]
)
```

---

## Tips & Best Practices

### Optimize File Selection

**DO**: Use focused directories with relevant files only  
**DON'T**: Feed Claude your entire drive

```bash
# Good
python files_to_prompt.py ~/project/src/components

# Bad
python files_to_prompt.py ~/
```

### Manage Token Limits

Claude has context window limits. For large projects:

1. Process subdirectories separately
2. Use `--no-tree` and `--no-instructions` for minimal output
3. Focus on specific file types

```bash
# Process only JavaScript files
python files_to_prompt.py ~/project -e "*.py" -e "*.md" -e "*.json"
```

### Combine with Custom Instructions

Skip default instructions and add your own:

```bash
python files_to_prompt.py ~/project --no-instructions -o base.txt

# Then manually add:
# "Based on these files, create a microservices architecture with:
# - Service discovery
# - Load balancing
# - Health checks
# - Monitoring endpoints"
```

### Iterative Refinement

1. First pass: General analysis
   ```bash
   python files_to_prompt.py ~/project -o analysis.txt
   ```

2. Second pass: Specific components
   ```bash
   python files_to_prompt.py ~/project/components -o components.txt
   ```

3. Third pass: Integration
   ```bash
   python files_to_prompt.py ~/project/config -o config.txt
   ```

---

## Troubleshooting

### "No files found"

**Cause**: Directory empty or all files excluded  
**Solution**: Check exclusion patterns, verify directory path

```bash
# Check what would be processed
ls -la ~/your-directory
```

### "Permission denied"

**Cause**: Insufficient read permissions  
**Solution**: Run with appropriate permissions or change directory ownership

```bash
chmod -R +r ~/your-directory
```

### Output too large

**Cause**: Too many files or very large files  
**Solution**: Process subdirectories separately or use exclusions

```bash
# Exclude large log files
python files_to_prompt.py ~/project -e "*.log" -e "*.dump"
```

### Binary files included

**Cause**: File detection failure  
**Solution**: Manually exclude file types

```bash
python files_to_prompt.py ~/project -e "*.pdf" -e "*.jpg" -e "*.png"
```

---

## Changelog

**v1.0.0** - Initial release
- Python CLI tool
- Bash script
- Windows batch file
- Directory tree generation
- Configurable instructions
- Smart file detection
- Cross-platform support

---

## Contributing

Created for CH405_047 | Chaos Line

Suggestions and improvements welcome! Key areas for enhancement:
- Additional file type support
- Custom instruction templates
- Cloud storage integration (Drive, S3, etc.)
- Git integration (process diffs, specific commits)
- Parallel processing for large directories

---

## License

MIT License - Free to use, modify, and distribute

---

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review examples for similar use cases
3. Verify file permissions and paths
4. Test with a small directory first

---

## Quick Reference Card

```bash
# BASIC USAGE
python files_to_prompt.py <directory>                    # Process directory
python files_to_prompt.py <directory> -o file.txt        # Save to file

# OPTIONS
-o, --output FILE           Write to file
-r, --no-recursive          Current directory only
-t, --no-tree              Skip directory tree
-i, --no-instructions      Skip instructions
-e, --exclude PATTERN      Exclude pattern

# EXAMPLES
python files_to_prompt.py ~/Downloads                    # All files
python files_to_prompt.py ~/project -o prompt.txt        # Save output
python files_to_prompt.py . --no-recursive               # Current dir
python files_to_prompt.py ~/code -t -i                   # Minimal output
python files_to_prompt.py ~/app -e "*.log" -e "test*"    # Custom exclude

# WORKFLOW
1. Generate prompt     → python files_to_prompt.py ~/dir -o prompt.txt
2. Upload to Claude    → Drop prompt.txt into Claude interface
3. Add instructions    → "Extract components and create structure"
4. Review output       → Get organized components and templates
```

---

**Created with precision for CH405_047 | Chaos Line**
# for-git
Repo ready on main
