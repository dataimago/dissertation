# dissertation

An AI-native dissertation framework built on R package architecture.

## Overview

The `dissertation` R package provides a forkable framework for writing dissertations that treat AI as a collaborator in analysis, writing, and dissemination. It unifies Quarto source files, reproducible statistical analyses, machine-readable REST APIs, and MCP (Model Context Protocol) endpoints into a single coherent system.

The framework produces three outputs from the same `.qmd` source files:

- An **interactive website** (`quarto render`) — navigation, search, chapter exploration
- A **thesis-ready PDF** (`quarto render --profile thesis`) — using your institution's `thesis.cls` for formal submission
- A **working paper** (`quarto render --profile working-paper`) — clean HTML + PDF for sharing and versioning (v1.0 → v1.1 → ...)

Plus cross-cutting capabilities:

- **REST API endpoints** that expose analysis functions for programmatic access
- **MCP tools** that enable AI agents to responsibly access and reason about the research

## Quick Start

```r
# Install the package
devtools::install("dissertation")

# Load and explore
library(dissertation)
data(assessmentData)

# Run analyses
summarizeAssessment(content_area = "READING", group_by = "GRADE")
analyzeAssessment("achievement_trends", content_area = "MATHEMATICS")
analyzeAssessment("district_comparison")
getChapterSummary("results", include_data = TRUE)

# Start the API
run_dissertation_api(port = 8000)
```

## Repository Structure

```
dissertation-rpkg/
└── dissertation/           # R package
    ├── R/                  # Analysis functions and API
    │   ├── analysis.R      # summarizeAssessment(), analyzeAssessment(), etc.
    │   ├── api.R           # REST API endpoints
    │   ├── data.R          # Dataset documentation
    │   └── ...
    ├── data/               # Bundled datasets
    │   └── assessmentData.rda
    ├── tests/              # testthat test suite
    ├── man/                # Generated documentation
    ├── inst/
    │   └── thesis/         # Thesis cls, preamble, annotation guide
    ├── quarto_website/     # Quarto source files
    │   ├── content/chapters/       # Dissertation chapters (.qmd)
    │   ├── assets/css/             # Working paper CSS
    │   ├── _quarto.yml             # Website config (default profile)
    │   ├── _quarto-thesis.yml      # Thesis PDF profile
    │   └── _quarto-working-paper.yml # Working paper profile
    ├── DESCRIPTION
    ├── NAMESPACE
    └── CLAUDE.md           # AI development guidelines
```

## Dataset

The package includes `assessmentData` — a longitudinal assessment dataset with 368,301 records across 3 academic years, containing Reading and Mathematics scale scores, achievement levels, and organizational identifiers (district, school) for students across multiple grade levels.

## Analysis Functions

| Function | Purpose |
|----------|---------|
| `summarizeAssessment()` | Summary statistics with filtering and grouping |
| `analyzeAssessment()` | Detailed analyses: achievement trends, score distributions, district comparisons, cohort progress |
| `getChapterSummary()` | Dissertation chapter info with linked analyses |
| `getAvailableAnalyses()` | Discovery endpoint for available analyses and parameters |
| `run_dissertation_api()` | Start the REST API server |

## Companion Repository

This package is designed to be embedded in the **dissertation-ai** NextJS application:
- Repository: [github.com/dbetebenner/dissertation-ai](https://github.com/dbetebenner/dissertation-ai)
- The R package is included as a git submodule
- The NextJS app consumes the REST API for interactive visualizations and chatbot

## For Training Participants

This framework was presented at a training session on writing AI-native dissertations. To use it:

1. Fork both repositories (`dissertation` and `dissertation-ai`)
2. Replace the seed dataset with your own data
3. Modify the analysis functions for your research questions
4. Write your dissertation chapters in the Quarto files
5. Configure the thesis PDF profile for your institution
6. The web application automatically adapts to your API

See the [Customization Guide](https://dbetebenner.github.io/dissertation/customization_guide.html) for details.

## License

MIT
