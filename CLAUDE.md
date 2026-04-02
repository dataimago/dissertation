---
title: "CLAUDE.md: Dissertation R Package Development for AI-Native Applications"
description: "A companion guide for AI assistants developing the dissertation R package within the dataimago AI-native data science application framework."
version: "0.0-0.1"
author: "dataimago AI + Human Co-Creation"
---

## Overview

This document guides AI assistants contributing to the `dissertation` R package — a forkable framework for writing AI-native dissertations. The package is embedded within the `dissertation-ai` NextJS application as a git submodule, following the dataimago architecture pattern established by the HelloWorld proof-of-concept.

## Architecture Context

The dissertation framework has two repositories:

- **dissertation-rpkg** (this repo): R package with data, analyses, API, Quarto docs
- **dissertation-ai**: NextJS monorepo consuming this package via submodule, API, and MCP

### Layer Model

1. **R Package Core** — Data + analysis functions (this package)
2. **REST API** — RestRserve endpoints exposing functions as HTTP
3. **MCP Tools** — Model Context Protocol for AI agent access
4. **Web Application** — NextJS frontend with chatbot

## Development Commands

```bash
# R package development
Rscript -e 'devtools::document()'       # Generate docs
Rscript -e 'devtools::test()'           # Run tests
Rscript -e 'devtools::check()'          # R CMD check
Rscript -e 'devtools::install()'        # Install locally

# Quarto rendering (three profiles from same .qmd source)
cd quarto_website && quarto render                        # Website (default)
cd quarto_website && quarto render --profile thesis        # Thesis PDF (thesis.cls)
cd quarto_website && quarto render --profile working-paper # Working paper (HTML + PDF)

# API server
Rscript -e 'dissertation::run_dissertation_api()'  # Start on port 8000
```

## Core Principles

### 1. Structured Return Values
All analysis functions return lists with consistent structure:
```r
list(status = "success|error", results = data.table, interpretation = "text", ...)
```
This pattern ensures JSON serialization works cleanly for the API and MCP layers.

### 2. Separation of Concerns
- R functions do computation only — no UI, no HTML, no visualization
- Quarto documents handle narrative text with embedded R code chunks
- The NextJS app handles interactive presentation
- The API bridges R and TypeScript

### 3. Forkability
This package is a template. All content is designed to be replaced:
- `data/assessmentData.rda` → user's own dataset
- `R/analysis.R` → user's analysis functions
- `quarto_website/content/chapters/` → user's dissertation text
- `inst/thesis/` → user's institution's thesis.cls

### 4. Testing
- Every exported function has testthat tests
- Tests cover: success cases, error handling, edge cases, data integrity
- API endpoints are tested via the underlying functions

### 5. Documentation
- roxygen2 with markdown support for all exported functions
- `@section Model Context Protocol Integration` on all analysis functions
- Quarto website serves as both user docs and dissertation content

## Key Files

| File | Purpose |
|------|---------|
| `R/analysis.R` | Core analysis functions (summarizeAssessment, analyzeAssessment, etc.) |
| `R/api.R` | REST API endpoint definitions |
| `R/data.R` | Dataset documentation |
| `R/dissertation-package.R` | Package-level documentation |
| `R/zzz.R` | Startup messages |
| `data/assessmentData.rda` | Assessment dataset (368,301 records) |
| `tests/testthat/test_analysis.R` | Test suite |
| `quarto_website/_quarto.yml` | Website configuration |
| `quarto_website/_quarto-thesis.yml` | Thesis PDF profile (thesis.cls) |
| `quarto_website/_quarto-working-paper.yml` | Working paper profile (HTML + PDF) |
| `quarto_website/assets/css/working-paper.css` | Working paper CSS styles |
| `quarto_website/content/chapters/` | Dissertation chapter source |
| `inst/thesis/thesis.cls` | CU Boulder thesis class (annotated exemplar) |
| `inst/thesis/thesis-preamble.tex` | Preamble commands for thesis.cls |
| `inst/thesis/ANNOTATION_GUIDE.txt` | Guide for adapting thesis.cls |

## Exported Functions

| Function | Purpose |
|----------|---------|
| `summarizeAssessment()` | Summary statistics with filtering by content_area, year, group_by |
| `analyzeAssessment()` | Detailed analyses: achievement_trends, score_distribution, district_comparison, cohort_progress |
| `getChapterSummary()` | Dissertation chapter info with linked analyses |
| `getAvailableAnalyses()` | Discovery endpoint for available analyses and parameters |
| `create_dissertation_api()` | Create configured RestRserve application |
| `run_dissertation_api()` | Start the API server |

## Dataset: assessmentData

368,301 rows, 8 columns: CONTENT_AREA (chr), YEAR (chr, YYYY_YYYY format), GRADE (chr), ID (chr), SCALE_SCORE (num), ACHIEVEMENT_LEVEL (chr), DISTRICT_NUMBER (int), SCHOOL_NUMBER (int). Content areas: READING, MATHEMATICS. Achievement levels include Beginning, Developing, Proficient, Advanced.

## Success Criteria

The package is complete when:
- `R CMD check` passes with no errors or warnings
- All exported functions have testthat coverage
- API endpoints return valid JSON for all parameter combinations
- Quarto renders all three profiles: website, thesis PDF, and working paper
- A fresh fork + install + test workflow succeeds
- CLAUDE.md and README.md accurately reflect the current state
