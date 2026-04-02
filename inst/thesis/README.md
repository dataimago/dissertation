# thesis.cls - Annotated for University Adaptation

This directory contains the CU Boulder `thesis.cls` (v1.14, Ken Anderson, August 2020) with comprehensive annotations to guide adaptation for other universities' dissertation requirements.

## Files

- **thesis.cls** - The annotated LaTeX class file (1,593 lines)
- **ANNOTATION_GUIDE.txt** - Detailed guide on how to use the annotations (450 lines)
- **README.md** - This file

## Quick Start

1. **Read the header comment** in `thesis.cls` (first 150 lines)
   - Explains overall purpose
   - Shows Quarto YAML integration
   - Lists key customization points

2. **Search for key annotations** in `thesis.cls`
   - `%%%% SECTION:` - Major functional blocks
   - `%% CU-SPECIFIC:` - Things to change for your university
   - `%% ADAPT:` - How to make changes
   - `%% UNIVERSAL:` - Don't change these

3. **Consult ANNOTATION_GUIDE.txt** for detailed explanations
   - How to use the annotations
   - Common customization tasks with examples
   - Troubleshooting guide

## What Was Annotated

**Original file:** 1,282 lines  
**Annotated file:** 1,593 lines  
**Comments added:** ~311 lines of guidance

The original LaTeX code has NOT been modified - only comments have been added.

## Annotation Categories

### Section Headers
```
%%%% SECTION: Section Name %%%%
```
Delineate major functional areas. Use Find to navigate between sections.

### Guidance Prefixes

**%% UNIVERSAL:**  
Core LaTeX mechanism that should not be changed.

**%% CU-SPECIFIC:**  
Requirements unique to CU Boulder. Compare with your university's requirements and adapt as needed.

**%% ADAPT:**  
Detailed guidance on how to make changes, with examples.

**%% GUIDE:**  
Educational comments explaining LaTeX concepts and mechanisms.

## Most Common Changes Needed

1. **Margins** (Search: "SET THE OVERALL DOCUMENT PROPERTIES")
   - Your school's margin requirements almost certainly differ from CU's
   - Adjust `\setlength{\oddsidemargin}`, `\setlength{\textwidth}`, etc.

2. **Title Page** (Search: "TITLE PAGE GENERATION")
   - Most visually distinctive element per university
   - Reorder/reformat author, degree, committee, date, etc.

3. **Heading Styles** (Search: "CHAPTER AND SECTION HEADING DEFINITIONS")
   - If your school requires different chapter/section formatting
   - Adjust bold, centering, spacing, font sizes

4. **Page Style** (Search: "PAGE STYLE DEFINITION")
   - If page numbers should be in different location (footer vs. header)
   - Or if your school requires running headers

5. **Approval Page** (Search: "APPROVAL PAGE")
   - Currently commented out (CU v1.14 removed signature page)
   - Can be uncommented if your university requires it

## Integration with Quarto

This class is designed to work with Quarto documents. In your Quarto file:

```yaml
---
title: "My Dissertation Title"
author: "Your Name"
degree: "Doctor of Philosophy"
department: "Your Department"
year: 2024
advisor: "Dr. Name"
advisortitle: "Chair"
reader: "Dr. Reader Name"

format:
  pdf:
    documentclass: thesis
    classoption: [letterpaper, 12pt, defaultstyle]
---
```

Each YAML field maps to a LaTeX command in thesis.cls:
- `title` → `\title{...}`
- `author` → `\author{...}`
- `degree` → `\degree{...}`
- `department` → `\department{...}`
- etc.

The annotations in thesis.cls explain where these commands are defined.

## How to Adapt

### Step 1: Gather Requirements
- Get your university's dissertation formatting guidelines
- Note margin requirements, title page format, heading styles
- Check for any other unique requirements

### Step 2: Create a Copy
- Keep the original as backup
- Work on a copy for your university

### Step 3: Identify Changes
- Compare CU's requirements (marked "CU-SPECIFIC") with yours
- Make a list of what needs to change

### Step 4: Make Changes
- Edit sections marked "ADAPT:" (they have guidance)
- Only modify sections marked "CU-SPECIFIC:"
- Never modify sections marked "UNIVERSAL:"
- One section at a time

### Step 5: Test After Each Change
- Create a minimal test Quarto document
- Render to PDF
- Verify changes work correctly
- Adjust if needed

### Step 6: Document Your Changes
- Add a CHANGELOG at the top:
  ```
  %% MODIFIED FOR: University of XYZ
  %% MODIFIED DATE: 2024-04-01
  %% MODIFICATIONS:
  %% - Changed left margin from 1" to 1.25"
  %% - Modified title page layout
  ```
- This helps future users understand what was changed and why

## Example: Changing Margins

Your university requires 1.5" left margin, 1" all others. Here's how:

1. Search for "SET THE OVERALL DOCUMENT PROPERTIES" in thesis.cls
2. Find: `\setlength{\oddsidemargin}{0.00in}` (currently 1" margin)
3. Change to: `\setlength{\oddsidemargin}{0.5in}` (adds to 1" default = 1.5")
4. Find: `\setlength{\textwidth}{6.50in}` (currently 6.5")
5. Change to: `\setlength{\textwidth}{6.0in}` (8.5" - 1.5" - 1.0" = 6.0")
6. Test with sample document and measure margins

Note: LaTeX has a 1-inch default margin offset. To set a margin, you adjust relative to this default. The annotations explain this in detail.

## Understanding LaTeX Concepts

Some key concepts for adaptation:

**Margins in LaTeX:**
- LaTeX has a 1" default offset from page edges
- `\oddsidemargin{0.5in}` = 1.5" total left margin
- `\textwidth` = available width for text (8.5" page width - left margin - right margin)

**Title Page Spacing:**
- `\vfill` - Stretches to fill remaining space on page
- `\vspace{0.3in}` - Adds fixed amount of space
- `\\` - Line break
- `\centering` - Center text horizontally
- `\raggedright` - Left-align text

**Fonts:**
- `\textbf{...}` - Bold
- `\textit{...}` - Italic
- `\Large`, `\large` - Larger fonts
- `\normalsize` - Standard size
- `\bfseries` - Make subsequent text bold

**Line Spacing:**
- `\baselinestretch{1.0}` - Single spacing
- `\baselinestretch{1.5}` - 1.5 spacing
- `\baselinestretch{1.660}` - Double spacing (optical equivalent at 12pt)

## Troubleshooting

**Margins look wrong:**
- Double-check your school's margin requirements
- Remember the 1" LaTeX default offset
- Test with actual content, measure with ruler

**Title page elements overlap:**
- Adjust `\vfill` and `\vspace{}` values
- Check that text strings aren't too long
- Consider reducing font size if needed

**Chapter headings don't look right:**
- Verify your school's exact requirements
- Check centering, bold, and spacing settings
- Test with multiple chapters

**Compilation errors:**
- Ensure all required packages are installed
- Check for unmatched braces `{}` or brackets `[]`
- Search LaTeX error messages online (TeX Stack Exchange)

## Getting Help

**LaTeX Questions:**
- Stack Exchange (tex.stackexchange.com)
- CTAN (ctan.org)
- TeXBook (comprehensive reference)

**Quarto Questions:**
- Quarto documentation (quarto.org)
- Quarto GitHub issues

**University-Specific Help:**
- Your Graduate School office
- Your department's technical support
- Other students who've formatted dissertations

## Maintaining Your Modified Version

Once adapted for your university:

1. **Version control:** Use Git to track changes
2. **Documentation:** Keep CHANGELOG of modifications
3. **Testing:** Create sample documents for regression testing
4. **Sharing:** Share with other students, note university clearly
5. **Updates:** Check for CU updates to thesis.cls periodically

## Key Files to Read

Start here (in this order):

1. **thesis.cls** - First 150 lines (comprehensive header comment)
2. **ANNOTATION_GUIDE.txt** - Complete guide to using annotations
3. **thesis.cls** - Search for "%%%% SECTION:" to navigate
4. **ADAPTATION_GUIDE.txt** (if present) - Step-by-step adaptation workflow

## Original Source

- Original class: CU Boulder thesis.cls v1.14
- Original author: Ken Anderson, August 2020
- Based on: John P. Weiss, 1997 (v1.00)
- History: Multiple contributors (see header of thesis.cls)

These annotations were created to help anyone adapt this excellent class for their university's requirements.
