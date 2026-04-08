# SETUP.md — AI-Native Dissertation Framework

> **What this file is:** Drop this into an empty directory, point your AI agent at it, and say
> "I'm ready to get started writing my dissertation." The agent will scaffold a complete,
> multi-format dissertation framework customized to your research topic.
>
> **Works with:** Claude Code, Codex, Cursor Agent, Windsurf, Aider, or any AI coding assistant
> that can read project files.

---

## How to Use This File

```
mkdir my-dissertation
cp SETUP.md my-dissertation/
cd my-dissertation

# Optional: add your research notes, papers, proposal, data files
# The agent will use them as context.

# Then open your AI agent and say:
# "I'm ready to get started writing my dissertation. Read SETUP.md first."
```

**For tool-specific auto-loading**, copy or symlink this file:

| Tool | Convention |
|------|-----------|
| Claude Code | `CLAUDE.md` |
| Cursor | `.cursorrules` |
| Codex / OpenAI | `AGENTS.md` |
| Windsurf | `.windsurfrules` |
| Generic | `SETUP.md` (reference it in your first message) |

---

## Agent Instructions

You are helping a user build an **AI-native dissertation** — a modern dissertation framework
that produces the traditional thesis PDF universities require, PLUS an interactive website,
a REST API, and AI-agent-readable structured data. The user writes once; the framework
renders to every format.

### Your first task: understand the user's research

Before writing any code, have a conversation. Ask about:

1. **Research topic and field** — What is the dissertation about? What discipline?
2. **Research questions** — What are the 2-4 questions driving the work?
3. **Data** — What kind of data will they analyze? Do they have it yet? What format?
4. **Methods** — What analytic approaches? Quantitative, qualitative, mixed?
5. **Institution** — Which university? Do they have a thesis LaTeX class file?
6. **Audience** — Who needs to read this beyond the committee?
7. **Experience level** — How comfortable are they with R, git, command line?

Use their answers to customize EVERYTHING below. Do not build a generic template —
build THEIR dissertation from the start.

---

## Architecture Overview

The framework has two repositories that work together:

```
my-dissertation/
├── dissertation-rpkg/          # R package: analysis engine + Quarto documents
│   └── dissertation/           # The actual R package
│       ├── R/                  # Analysis functions, API definitions
│       ├── data/               # User's dataset(s) as .rda files
│       ├── inst/thesis/        # Thesis class file + preamble
│       ├── quarto_website/     # All Quarto source files
│       │   ├── content/chapters/   # Dissertation chapters
│       │   ├── _quarto.yml         # Website profile
│       │   └── ...
│       ├── tests/              # Test suite
│       └── DESCRIPTION         # R package metadata
│
└── dissertation-ai/            # NextJS monorepo: interactive web application
    ├── apps/web-app/           # Next.js 14 application
    ├── packages/
    │   ├── shared-utils/       # TypeScript types, API clients
    │   └── mcp-tools/          # MCP schema validation
    ├── turbo.json
    └── package.json
```

### Why two repos?

- **dissertation-rpkg**: Contains ALL the intellectual content — chapters, analysis,
  data. This is what the user spends most of their time in. It produces the thesis PDF,
  the Quarto website, and exposes data through a REST API.

- **dissertation-ai**: The interactive presentation layer. It consumes the R package's
  API to create a modern web application with visualizations, an analysis explorer, and
  AI-agent-accessible endpoints. Most users won't need to touch this directly.

### The key insight

The R package's analysis functions return **structured data + plain-language interpretation**.
This single contract enables every output format:

```r
# Every analysis function returns this structure:
list(
  status = "success",
  results = data.table(...),          # The data
  interpretation = "In plain English...",  # Human-readable narrative
  filters = list(content_area = "..."),   # What was queried
  metadata = list(n = 4850, ...)          # Context
)
```

- **Quarto chapters** embed R code chunks that call these functions and render the
  results as tables, figures, and inline narrative.
- **The REST API** wraps the same functions as HTTP endpoints, returning JSON.
- **The NextJS app** calls the API to render interactive visualizations.
- **AI agents** can discover and query the API via MCP (Model Context Protocol).

---

## Phase 1: Scaffold the R Package

Create the R package first. Everything else depends on it.

### 1.1 Initialize the package

```
dissertation-rpkg/
└── dissertation/
    ├── DESCRIPTION
    ├── NAMESPACE
    ├── LICENSE
    ├── R/
    │   ├── dissertation-package.R    # Package-level documentation
    │   ├── data.R                    # Dataset documentation (roxygen2)
    │   ├── analysis.R                # Core analysis functions
    │   ├── api.R                     # REST API endpoint definitions
    │   └── zzz.R                     # Package startup message
    ├── data/                         # Will contain .rda datasets
    ├── inst/
    │   ├── extdata/                  # Raw data files, processing scripts
    │   └── thesis/
    │       ├── thesis.cls            # University's LaTeX class file
    │       ├── thesis-preamble.tex   # Dissertation metadata
    │       └── thesis-quarto-fix.tex # Quarto/LaTeX compatibility fixes
    ├── man/                          # Auto-generated by roxygen2
    └── tests/
        ├── testthat.R
        └── testthat/
            └── test_analysis.R
```

### 1.2 DESCRIPTION file

```
Package: dissertation
Title: [User's Dissertation Title - Short Version]
Version: 0.0-0.1
Authors@R: person("[First]", "[Last]", email = "[email]", role = c("aut", "cre"))
Description: AI-native dissertation framework for [brief topic description].
    Provides analysis functions, a REST API, and multi-format Quarto rendering.
License: MIT + file LICENSE
Encoding: UTF-8
LazyData: true
Depends: R (>= 4.1.0)
Imports:
    crayon,
    data.table,
    jsonlite,
    RestRserve,
    toOrdinal
Suggests:
    devtools,
    knitr,
    rmarkdown,
    testthat (>= 3.0.0)
Config/testthat/edition: 3
RoxygenNote: 7.3.2
Roxygen: list(markdown = TRUE)
```

Customize: Replace bracketed values. Add discipline-specific packages to Imports
(e.g., `lme4` for mixed models, `tidytext` for text analysis, `sf` for spatial data).

### 1.3 The dataset

The user's data drives everything. Help them:

1. **Prepare the data** in R as a clean data.table or data.frame
2. **Save it** as `data/[datasetName].rda` using `usethis::use_data()`
3. **Document it** in `R/data.R` with roxygen2:

```r
#' [Dataset Name]
#'
#' [Description of what this data contains, where it comes from,
#'  and what each row represents.]
#'
#' @format A data.table with [N] rows and [M] columns:
#' \describe{
#'   \item{COLUMN_1}{Description}
#'   \item{COLUMN_2}{Description}
#'   ...
#' }
#'
#' @source [Where the data came from]
"datasetName"
```

**Important**: Column names should be UPPERCASE for consistency with the API layer.
The dataset name becomes the canonical reference throughout the framework.

### 1.4 Analysis functions (`R/analysis.R`)

Create two core exported functions. These are the heart of the framework.

#### `summarizeData()`

A flexible summary function that aggregates the dataset by any grouping variable.

```r
#' Summarize [Dataset]
#'
#' @param [filter_param_1] Character. Filter by [dimension]. Default: NULL (all).
#' @param [filter_param_2] Character. Filter by [dimension]. Default: NULL (all).
#' @param group_by Character. Variable to group results by.
#'   One of: [list valid grouping columns]. Default: "[default]".
#' @param include_meta Logical. Include metadata in response. Default: FALSE.
#'
#' @return A list with components:
#'   \item{status}{"success" or "error"}
#'   \item{summary}{data.table of summary statistics}
#'   \item{interpretation}{Plain-language description of results}
#'   \item{filters}{List of applied filters}
#'
#' @export
summarizeData <- function([params]) {
    # 1. Load data
    # 2. Apply filters
    # 3. Compute group-level statistics
    # 4. Generate interpretation string
    # 5. Return structured list
}
```

#### `analyzeData()`

A dispatch function for specific analysis types tied to research questions.

```r
#' Analyze [Dataset]
#'
#' @param analysis_type Character. One of: [list analysis types].
#'   Each maps to a research question.
#' @param ... Additional parameters passed to specific analysis functions.
#'
#' @return A list with status, results, interpretation, filters, metadata.
#'
#' @export
analyzeData <- function(analysis_type, ...) {
    # Dispatch to internal analysis functions based on type
    result <- switch(analysis_type,
        "type_for_rq1" = .analyze_rq1(...),
        "type_for_rq2" = .analyze_rq2(...),
        "type_for_rq3" = .analyze_rq3(...),
        stop("Unknown analysis type: ", analysis_type)
    )
    return(result)
}
```

**Design each analysis type around a research question.** For example:

| Research Question | analysis_type | What it computes |
|---|---|---|
| RQ1: How does X change over time? | `"temporal_trends"` | Group means by time period |
| RQ2: How does X vary across groups? | `"group_comparison"` | Between-group statistics |
| RQ3: What predicts Y? | `"regression_analysis"` | Model coefficients, fit stats |

#### Discovery function

```r
#' Get Available Analyses
#'
#' Returns metadata about all available analysis functions and their parameters.
#' Used by the API discovery endpoint and MCP tools.
#'
#' @return A list describing available analyses, parameters, and valid values.
#' @export
getAvailableAnalyses <- function() {
    list(
        status = "success",
        analyses = list(
            summary = list(
                description = "Summary statistics",
                parameters = list(
                    # ... valid parameter names and values
                )
            ),
            # ... one entry per analysis type
        )
    )
}
```

#### Chapter metadata function

```r
#' Get Chapter Summary
#'
#' Returns metadata for dissertation chapters including linked analyses.
#'
#' @param chapter Character. Chapter slug or NULL for all chapters.
#' @param include_data Logical. Include linked analysis results. Default: FALSE.
#'
#' @return A list with chapter metadata and optionally embedded data.
#' @export
getChapterSummary <- function(chapter = NULL, include_data = FALSE) {
    # Define chapter metadata — customize for user's dissertation
    chapters <- list(
        list(slug = "introduction", title = "Introduction", number = 1,
             description = "...", research_questions = list("RQ1", "RQ2", "RQ3")),
        # ... one per chapter
    )
    # Optionally attach analysis results
    # Return structured list
}
```

### 1.5 REST API (`R/api.R`)

The API wraps the analysis functions as HTTP endpoints using RestRserve.

```r
#' Create Dissertation API
#'
#' @return A RestRserve Application object with all endpoints configured.
#' @export
create_dissertation_api <- function() {
    app <- RestRserve::Application$new()

    # Helper: add CORS headers to every response
    add_cors_headers <- function(response) {
        response$set_header("Access-Control-Allow-Origin", "*")
        response$set_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        response$set_header("Access-Control-Allow-Headers", "Content-Type")
    }

    # Pattern for each endpoint:
    summary_handler <- function(request, response) {
        add_cors_headers(response)
        tryCatch({
            # Extract query params with defaults
            param1 <- request$get_query_parameter("param1", default = NULL)
            # Call analysis function
            result <- summarizeData(param1 = param1)
            # Return JSON
            response$set_content_type("application/json")
            response$set_status_code(200L)
            response$set_body(jsonlite::toJSON(result, auto_unbox = TRUE, dataframe = "rows"))
        }, error = function(e) {
            response$set_content_type("application/json")
            response$set_status_code(500L)
            response$set_body(jsonlite::toJSON(list(
                status = "error", message = e$message
            ), auto_unbox = TRUE))
        })
    }

    app$add_get("/summary", summary_handler)
    # ... add handlers for /analysis, /chapters, /analyses, /data/variables
    # ... add OPTIONS handlers for CORS preflight

    return(app)
}

#' Run Dissertation API
#'
#' @param port Integer. Port number. Default: 8000.
#' @param host Character. Host address. Default: "0.0.0.0".
#' @export
run_dissertation_api <- function(port = 8000, host = "0.0.0.0") {
    app <- create_dissertation_api()
    backend <- RestRserve::BackendRserve$new()
    backend$start(app, http_port = port, host = host)
}
```

**Required endpoints:**

| Method | Path | Maps to | Purpose |
|--------|------|---------|---------|
| GET | `/summary` | `summarizeData()` | Flexible summary statistics |
| GET | `/analysis` | `analyzeData()` | Research-question analyses |
| GET | `/chapters` | `getChapterSummary()` | Chapter metadata |
| GET | `/analyses` | `getAvailableAnalyses()` | API discovery |
| GET | `/data/variables` | (inline) | Dataset column metadata |
| GET | `/openapi.json` | (inline) | OpenAPI 3.0 specification |

---

## Phase 2: Quarto Documents

The Quarto layer turns the R package into readable documents.

### 2.1 Website profile (`_quarto.yml`)

```yaml
project:
  type: website
  output-dir: ../docs
  render:
   - "*.qmd"
   - "content/chapters/**"

execute:
  freeze: auto

website:
  site-url: "https://[username].github.io/[repo]/"
  repo-url: "https://github.com/[username]/[repo]"
  title: "[Dissertation Short Title]"
  page-navigation: true

  navbar:
    title: "[short-name]"
    search: false
    pinned: true
    right:
      - text: About
        href: about.qmd
      - text: Getting Started
        href: getting_started.qmd
      - text: Dissertation
        menu:
          - text: Overview
            href: overview.qmd
          - text: "Ch 1: Introduction"
            href: content/chapters/introduction.qmd
          - text: "Ch 2: Literature Review"
            href: content/chapters/literature_review.qmd
          - text: "Ch 3: Methods"
            href: content/chapters/methods.qmd
          - text: "Ch 4: Results"
            href: content/chapters/results.qmd
          - text: "Ch 5: Discussion"
            href: content/chapters/discussion.qmd
      - text: R Package
        menu:
          - text: API Reference
            href: api_reference.qmd
          - text: Data Dictionary
            href: data_dictionary.qmd

  search:
    location: navbar
    type: overlay

format:
  html:
    theme:
      light: cosmo
      dark: [cosmo]
    toc: true
```

### 2.2 Dissertation chapters

Each chapter is a `.qmd` file in `content/chapters/`. The critical pattern:
**chapters call R package functions and render their output.**

Example — `results.qmd`:

```qmd
---
title: "Results"
number-sections: true
---

```{r}
#| label: setup
#| include: false
library(dissertation)
library(data.table)
data(datasetName)
```

## Overview

This chapter presents findings organized by research question. All results
are generated programmatically from the `dissertation` R package, ensuring
narrative and data stay synchronized.

## RQ1: [Research Question 1]

```{r}
#| label: rq1-analysis
#| echo: false
rq1 <- analyzeData("type_for_rq1")
```

`r rq1$interpretation`

```{r}
#| label: tbl-rq1
#| tbl-cap: "[Table caption]"
#| echo: false
knitr::kable(rq1$results, digits = 1)
```
```

**Key patterns:**
- `library(dissertation)` loads the package — functions are available immediately
- `analyzeData()` returns structured results
- `` `r rq1$interpretation` `` injects the plain-language summary inline
- `knitr::kable()` renders the results data.table as a formatted table
- Cross-references: use `{#sec-label}` and `@sec-label`

### 2.3 Thesis PDF pipeline

**Master document** (`content/thesis-main.qmd`):

```qmd
---
bibliography: ../references.bib
format:
  pdf:
    documentclass: thesis
    classoption: [defaultstyle, 11pt]
    include-in-header:
      - ../../inst/thesis/thesis-preamble.tex
      - ../../inst/thesis/thesis-quarto-fix.tex
    toc: false
    number-sections: true
    colorlinks: true
    fig-pos: "H"
    keep-tex: true
    output-file: "dissertation-thesis.pdf"
---

# Introduction
{{< include chapters/introduction.qmd >}}

# Literature Review
{{< include chapters/literature_review.qmd >}}

# Methods
{{< include chapters/methods.qmd >}}

# Results
{{< include chapters/results.qmd >}}

# Discussion
{{< include chapters/discussion.qmd >}}

# References {.unnumbered}
```

**Thesis preamble** (`inst/thesis/thesis-preamble.tex`):

```latex
%% DISSERTATION METADATA — Edit these for your dissertation

\title{[Full Dissertation Title]}
\author{[First]}{[Last]}
\otherdegrees{[B.A., University, Year] \\
              [M.S., University, Year]}
\degree{Doctor of Philosophy}
       {Ph.D., [Field]}
\dept{[Department/School type]}{[Department Name]}
\advisor{[Title]}{[Advisor Name]}
\reader{[Committee Member 2]}
\readerThree{[Committee Member 3]}
\readerFour{[Committee Member 4]}

\abstract{
[Dissertation abstract — 150-350 words]
}

\dedication[Dedication]{
  [Optional dedication]
}

\acknowledgements{ \OnePageChapter
  [Acknowledgments text]
}

\ToCisShort
```

**Thesis LaTeX compatibility fix** (`inst/thesis/thesis-quarto-fix.tex`):

```latex
%% Fix for Quarto + older thesis.cls compatibility
%% Quarto's Pandoc template may use \AddToHook which older .cls files
%% don't expect. This file provides compatibility shims.

% Prevent double-loading of ToC
\usepackage{etoolbox}
\AtBeginDocument{%
  \ifdef{\contentsname}{}{\newcommand{\contentsname}{Contents}}%
}
```

**Render command:**
```bash
cd quarto_website
quarto render content/thesis-main.qmd --to pdf
```

**Customizing for other universities:**
1. Get your institution's thesis `.cls` file (check your grad school's website)
2. Place it in `inst/thesis/thesis.cls`
3. Update `thesis-preamble.tex` with the commands YOUR `.cls` expects
4. The chapter content stays the same — only the preamble and class change

### 2.4 Working paper profile

Create `_quarto-working-paper.yml`:

```yaml
project:
  type: book
  output-dir: ../inst/working-paper/output

book:
  title: "[Title]"
  author: "[Name]"
  chapters:
    - index.qmd
    - content/chapters/introduction.qmd
    - content/chapters/literature_review.qmd
    - content/chapters/methods.qmd
    - content/chapters/results.qmd
    - content/chapters/discussion.qmd
    - references.qmd

format:
  html:
    theme: cosmo
    css: assets/css/working-paper.css
    toc: true
    toc-depth: 3
  pdf:
    documentclass: article
    papersize: letter
    geometry: "margin=1in"
    fontsize: 11pt
    linestretch: 1.5
    colorlinks: true
```

**Render command:**
```bash
cd quarto_website
quarto render --profile working-paper
```

---

## Phase 3: NextJS Web Application

The web application is the interactive layer. It consumes the R package's REST API.

### 3.1 Monorepo structure

```
dissertation-ai/
├── turbo.json
├── package.json              # Workspaces: apps/*, packages/*
├── pnpm-workspace.yaml
│
├── packages/
│   ├── shared-utils/         # Types, constants, API clients
│   │   ├── src/
│   │   │   ├── types.ts      # Zod schemas matching R function signatures
│   │   │   ├── constants.ts  # API endpoints, colors, enums
│   │   │   └── clients.ts    # RApiClient (live), StaticClient (pre-rendered)
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── mcp-tools/            # MCP schema validation
│       ├── src/
│       │   └── mcp-schema-loader.ts
│       ├── package.json
│       └── tsconfig.json
│
├── apps/
│   └── web-app/              # Next.js 14 application
│       ├── next.config.js
│       ├── tailwind.config.js
│       ├── src/
│       │   ├── app/
│       │   │   ├── layout.tsx
│       │   │   ├── page.tsx          # Landing page
│       │   │   ├── chapters/
│       │   │   │   ├── page.tsx      # Chapter listing
│       │   │   │   └── [slug]/page.tsx  # Chapter detail
│       │   │   ├── explore/page.tsx  # Interactive analysis explorer
│       │   │   └── docs/page.tsx     # Embedded Quarto site
│       │   ├── components/
│       │   │   ├── navigation.tsx
│       │   │   ├── hero.tsx
│       │   │   ├── chapter-card.tsx
│       │   │   ├── analysis-explorer.tsx
│       │   │   └── [visualization components]
│       │   ├── hooks/
│       │   │   ├── useAnalysis.ts
│       │   │   ├── useSummary.ts
│       │   │   └── useChapters.ts
│       │   └── lib/
│       │       └── api.ts           # Dual-mode API client
│       └── public/
│           ├── api/                 # Pre-rendered static JSON
│           └── docs/                # Synced Quarto HTML
│
└── scripts/
    └── generate-static-data.R       # Pre-renders all API responses to JSON
```

### 3.2 The dual-mode API client

The critical architectural piece in the web app:

```typescript
// src/lib/api.ts
const IS_LIVE = process.env.NEXT_PUBLIC_USE_LIVE_API === 'true';
const API_BASE = IS_LIVE ? '/api/r' : '/api';

// In development with R server running: calls localhost:8000 via proxy
// In production on Vercel: loads pre-rendered JSON files from /api/
```

**This means:**
- During development, run the R API server (`run_dissertation_api()`) and the
  NextJS dev server simultaneously. The proxy in `next.config.js` forwards
  `/api/r/*` to `http://localhost:8000/*`.
- For deployment, pre-render all API responses to static JSON files using
  `scripts/generate-static-data.R`, then deploy to Vercel as a static site.

### 3.3 Quarto docs sync

The Quarto-rendered website is embedded in the NextJS app:

```bash
# From dissertation-ai root:
# 1. Render Quarto in the R package
cd ../dissertation-rpkg/dissertation/quarto_website && quarto render

# 2. Copy rendered HTML to NextJS public folder
cp -r docs/ ../../../dissertation-ai/apps/web-app/public/docs/
```

This is automated via npm scripts in `package.json`:

```json
{
  "scripts": {
    "sync:docs": "pnpm run quarto:render && pnpm run sync:docs:copy",
    "sync:docs:copy": "rm -rf apps/web-app/public/docs && cp -r ../dissertation-rpkg/dissertation/docs apps/web-app/public/docs"
  }
}
```

### 3.4 Key dependencies

```json
{
  "dependencies": {
    "next": "^14.0.4",
    "react": "^18.2.0",
    "recharts": "^2.10.3",
    "swr": "^2.2.4",
    "lucide-react": "^0.294.0",
    "tailwindcss": "^3.4.0",
    "zod": "^3.22.4",
    "axios": "^1.6.2"
  }
}
```

---

## Phase 4: Integration and Deployment

### 4.1 Development workflow

```bash
# Terminal 1: R API server
cd dissertation-rpkg/dissertation
R -e 'devtools::load_all(); run_dissertation_api()'

# Terminal 2: NextJS dev server
cd dissertation-ai
pnpm dev

# Terminal 3: Quarto preview
cd dissertation-rpkg/dissertation/quarto_website
quarto preview
```

### 4.2 The write-render-review cycle

This is the user's daily workflow:

1. **Write** — Edit chapters in `quarto_website/content/chapters/`
2. **Render** — `quarto render` (website), `quarto render content/thesis-main.qmd --to pdf` (thesis)
3. **Review** — Check the website, PDF, and interactive dashboard
4. **Iterate** — Refine and repeat

AI assists with writing, analysis, and iteration — but the user retains
full editorial control over all scholarly conclusions.

### 4.3 Vercel deployment

The NextJS app deploys to Vercel:

1. Push to GitHub
2. Connect the `dissertation-ai` repo to Vercel
3. Set root directory to `apps/web-app`
4. Pre-render API data and commit `public/api/*.json` and `public/docs/`
5. Vercel builds and deploys automatically

The Quarto website deploys to GitHub Pages from the `docs/` directory.

### 4.4 Pre-rendering static data

Create `scripts/generate-static-data.R`:

```r
#!/usr/bin/env Rscript
library(dissertation)
library(jsonlite)

output_dir <- "apps/web-app/public/api"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# Pre-render every API response as static JSON
write_json <- function(data, filename) {
    writeLines(
        toJSON(data, auto_unbox = TRUE, dataframe = "rows", pretty = TRUE),
        file.path(output_dir, filename)
    )
}

# Summary endpoints
write_json(summarizeData(), "summary.json")
# ... one file per parameter combination the frontend needs

# Analysis endpoints
for (type in c("type_for_rq1", "type_for_rq2", "type_for_rq3")) {
    write_json(analyzeData(type), paste0("analysis-", type, ".json"))
}

# Discovery
write_json(getAvailableAnalyses(), "analyses.json")

# Chapters
write_json(getChapterSummary(), "chapters.json")

cat("Static data generated in", output_dir, "\n")
```

---

## Phase 5: Customization Checklist

When helping the user set up, work through this checklist:

### Must customize (framework won't work without these):

- [ ] Dataset: Replace with user's actual data in `data/`
- [ ] Analysis functions: Rewrite `R/analysis.R` for user's research questions
- [ ] Chapter content: Write all 5 chapters in `content/chapters/`
- [ ] DESCRIPTION: Package title, author, description
- [ ] `_quarto.yml`: Site title, URLs, navigation labels
- [ ] `thesis-preamble.tex`: Author, title, committee, abstract, degree info

### Should customize (makes it theirs):

- [ ] API endpoints: Match the analysis function signatures
- [ ] TypeScript types: Mirror the R function return types
- [ ] Web app components: Visualization types appropriate for the data
- [ ] `references.bib`: Their bibliography
- [ ] `about.qmd`: Project description
- [ ] Color scheme and branding

### Can customize later:

- [ ] Working paper profile
- [ ] MCP tools schema
- [ ] GitHub Actions CI/CD
- [ ] Additional Quarto pages (API reference, data dictionary, ethics statement)

---

## Agent Behavior Guidelines

### Do:
- **Ask before generating.** Understand the research before writing code.
- **Build incrementally.** Start with the R package, get it working, then add Quarto, then NextJS.
- **Test at each phase.** Run `R CMD check`, `quarto render`, `pnpm build` before moving on.
- **Explain what you're building.** The user should understand the architecture.
- **Use the user's language.** Name functions, variables, and files using their domain terminology.
- **Generate the interpretation strings.** The `$interpretation` field is what makes this framework special — it turns every analysis into a sentence the user can put in their dissertation.

### Don't:
- **Don't use placeholder data.** If the user has data, use it. If not, help them create realistic seed data.
- **Don't skip the R package.** Everything depends on it. Don't jump to the web app.
- **Don't over-engineer.** Start with 2-3 analysis types. The user can add more as their research evolves.
- **Don't write the dissertation for them.** Generate infrastructure. The scholarly argument is theirs.

### When the user says "I'm ready to get started":
1. Read any documents they've provided (proposal, notes, papers)
2. Ask the clarifying questions from the top of this file
3. Scaffold Phase 1 (R package) with their data and research questions
4. Get it running (`R CMD check` passes, API serves, basic Quarto renders)
5. Then move to Phase 2, 3, 4 incrementally

---

## Quick Reference

### Essential commands

```bash
# R package
cd dissertation-rpkg/dissertation
R -e 'devtools::document()'           # Rebuild NAMESPACE and man/
R -e 'devtools::load_all()'           # Load without installing
R -e 'devtools::test()'               # Run tests
R CMD build .                          # Build package
R CMD check *.tar.gz                   # Full check
R -e 'devtools::load_all(); run_dissertation_api()'  # Start API

# Quarto
cd quarto_website
quarto render                          # Website → ../docs/
quarto render content/thesis-main.qmd --to pdf  # Thesis PDF
quarto render --profile working-paper  # Working paper
quarto preview                         # Live preview

# NextJS
cd dissertation-ai
pnpm install                           # Install dependencies
pnpm dev                               # Dev server
pnpm build                             # Production build
pnpm run sync:docs                     # Sync Quarto → NextJS

# Git
git init && git add -A && git commit -m "Initial scaffold"
```

### File editing priority

When the user is writing their dissertation, they spend 90% of their time in:

1. `quarto_website/content/chapters/*.qmd` — The actual dissertation text
2. `R/analysis.R` — Analysis functions as research evolves
3. `references.bib` — Bibliography
4. `inst/thesis/thesis-preamble.tex` — Metadata (once, near the end)

Everything else is infrastructure that rarely changes after initial setup.

---

## Version

SETUP.md v1.0 — AI-Native Dissertation Framework
Created: 2026-04-08
