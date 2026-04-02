# Package-level documentation

## Suppress R CMD check NOTEs for data.table NSE column references
## and intermediate variables used in chained expressions.
utils::globalVariables(c(
  "CONTENT_AREA", "YEAR", "GRADE", "ID", "SCALE_SCORE",
  "ACHIEVEMENT_LEVEL", "DISTRICT_NUMBER", "SCHOOL_NUMBER",
  ".", "mean_score", "avg", "n_years"
))

#' dissertation: An AI-Native Dissertation Framework Built on R Package Architecture
#'
#' The \code{dissertation} package provides a forkable framework for writing an AI-native
#' dissertation that treats AI as a collaborator in analysis, writing, and dissemination.
#' It unifies Quarto (.qmd) source files, reproducible statistical analyses, machine-readable
#' REST APIs, and MCP (Model Context Protocol) endpoints into a single coherent package.
#'
#' The framework compiles a thesis-ready PDF via institutional thesis.cls and publishes an
#' interactive website with a chatbot that lets readers explore methods, results, and code.
#'
#' @details
#' \tabular{ll}{
#'   Package: \tab dissertation \cr
#'   Type: \tab Package \cr
#'   Version: \tab 0.0-0.1 \cr
#'   Date: \tab 2026-4-1 \cr
#'   License: \tab MIT \cr
#'   LazyLoad: \tab yes \cr
#' }
#'
#' @section Core Analysis Functions:
#' \itemize{
#'   \item \code{\link{summarizeAssessment}}: Generate summary statistics with filtering and grouping
#'   \item \code{\link{analyzeAssessment}}: Detailed analyses (trends, distributions, district comparisons, cohorts)
#'   \item \code{\link{getChapterSummary}}: Dissertation chapter information and linked analyses
#'   \item \code{\link{getAvailableAnalyses}}: Discover analysis types and parameters
#' }
#'
#' @section REST API:
#' \itemize{
#'   \item \code{\link{create_dissertation_api}}: Create configured RestRserve application
#'   \item \code{\link{run_dissertation_api}}: Start the API server
#' }
#'
#' @section Datasets:
#' \itemize{
#'   \item \code{\link{assessmentData}}: Longitudinal assessment data (368,301 records across 3 years)
#' }
#'
#' @section For Dissertation Authors:
#' This package is designed to be forked and customized. The workflow is:
#' \enumerate{
#'   \item Fork the repository and replace \code{assessmentData} with your own data
#'   \item Modify the analysis functions in \code{R/analysis.R} for your research questions
#'   \item Update the Quarto documents in \code{quarto_website/} with your dissertation text
#'   \item Customize the API endpoints in \code{R/api.R} to expose your analyses
#'   \item The NextJS frontend (dissertation-ai) automatically adapts to your API
#' }
#'
#' @docType package
#' @name dissertation-package
#' @title An AI-native dissertation framework
#' @keywords package
#' @importFrom stats IQR median quantile sd
"_PACKAGE"
