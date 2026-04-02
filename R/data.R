#' Student Assessment Data
#'
#' A longitudinal educational assessment dataset containing student-level scale scores
#' and achievement levels in Mathematics and Reading across three academic years.
#' This dataset provides the empirical foundation for the dissertation framework,
#' demonstrating how real assessment data can be analyzed, exposed via API, and
#' explored interactively through the AI-native web application.
#'
#' Training participants should replace this dataset with their own dissertation data
#' while preserving the structural patterns that enable API and MCP integration.
#'
#' @format A data.table with 368,301 rows and 8 variables:
#' \describe{
#'   \item{CONTENT_AREA}{Character. Subject area: "MATHEMATICS" or "READING"}
#'   \item{YEAR}{Character. Academic year in "YYYY_YYYY" format (e.g., "2022_2023", "2023_2024", "2024_2025")}
#'   \item{GRADE}{Character. Grade level at time of assessment (e.g., "3", "4", ..., "8")}
#'   \item{ID}{Character. Unique student identifier}
#'   \item{SCALE_SCORE}{Numeric. Assessment scale score}
#'   \item{ACHIEVEMENT_LEVEL}{Character. Performance level classification (e.g., "Proficient", "Partially Proficient")}
#'   \item{DISTRICT_NUMBER}{Integer. District identifier}
#'   \item{SCHOOL_NUMBER}{Integer. School identifier}
#' }
#'
#' @details
#' This dataset demonstrates several key concepts for dissertation data management:
#' \itemize{
#'   \item \strong{Longitudinal Structure}: Students tracked across multiple years and grades
#'   \item \strong{Achievement Classification}: Scale scores mapped to ordered performance levels
#'   \item \strong{Nested Structure}: Students nested within schools within districts
#'   \item \strong{Multiple Content Areas}: Parallel assessment in Mathematics and Reading
#'   \item \strong{Real Data Patterns}: Authentic distributions and relationships between variables
#' }
#'
#' The dataset spans three academic years (2022-2023 through 2024-2025) and includes
#' assessments in Mathematics and Reading. Achievement levels reflect the state's
#' performance standards applied to scale scores at each grade level.
#'
#' @section Replacing with Your Own Data:
#' To use this framework for your dissertation:
#' \enumerate{
#'   \item Create your dataset as a data.table with consistent column naming
#'   \item Save it to \code{data/} using \code{save(your_data, file = "data/your_data.rda", compress = "xz")}
#'   \item Update this documentation in \code{R/data.R}
#'   \item Modify the analysis functions in \code{R/analysis.R} to match your research questions
#'   \item Update the API endpoints in \code{R/api.R} accordingly
#' }
#'
#' @section Model Context Protocol Integration:
#' This dataset structure is designed to be discoverable by AI systems:
#' \itemize{
#'   \item Column names use SCREAMING_SNAKE_CASE for unambiguous identification
#'   \item Data types are explicitly documented for type checking
#'   \item Categorical variables use consistent, finite value sets
#'   \item The longitudinal key (ID, CONTENT_AREA, YEAR) is documented
#' }
#'
#' @usage data(assessmentData)
#' @import data.table
#'
#' @examples
#' # Load the dataset
#' data(assessmentData)
#'
#' # Explore the structure
#' str(assessmentData)
#' head(assessmentData)
#'
#' # Observations by year and content area
#' assessmentData[, .N, keyby = .(YEAR, CONTENT_AREA)]
#'
#' # Mean scale scores by content area and grade
#' assessmentData[, .(mean_score = mean(SCALE_SCORE, na.rm = TRUE), n = .N),
#'                keyby = .(CONTENT_AREA, GRADE)]
#'
#' # Proficiency rates by year
#' assessmentData[, .(pct_proficient = 100 * mean(ACHIEVEMENT_LEVEL == "Proficient")),
#'                keyby = .(YEAR, CONTENT_AREA)]
#'
#' @seealso
#' \code{\link{summarizeAssessment}} for summary statistics
#' \code{\link{analyzeAssessment}} for detailed analyses
"assessmentData"
