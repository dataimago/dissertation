#' Create Dissertation API Application
#'
#' @title Initialize Dissertation REST API using RestRserve
#' @description Creates and configures a RestRserve application exposing dissertation
#' analysis functions as REST endpoints. Provides CORS support, structured JSON responses,
#' OpenAPI documentation, and error handling. Designed for integration with the NextJS
#' frontend and MCP tools in the dissertation-ai framework.
#'
#' @details
#' The API provides the following endpoints:
#' \itemize{
#'   \item \code{GET /summary}: Assessment summary statistics with filtering and grouping
#'   \item \code{GET /analysis}: Detailed analyses (trends, distributions, district comparisons)
#'   \item \code{GET /chapters}: Dissertation chapter information and linked analyses
#'   \item \code{GET /analyses}: Discover available analysis types and parameters
#'   \item \code{GET /data/variables}: Dataset variable metadata
#'   \item \code{GET /openapi.json}: OpenAPI 3.0 specification
#' }
#'
#' @section NextJS Integration:
#' This API is consumed by the dissertation-ai NextJS application:
#' \itemize{
#'   \item CORS headers enabled for cross-origin requests
#'   \item Consistent JSON response structure for TypeScript integration
#'   \item OpenAPI specification for automatic client generation
#'   \item Structured errors compatible with frontend error handling
#' }
#'
#' @return A configured RestRserve application object
#' @export
#' @import RestRserve
#' @importFrom jsonlite toJSON
#'
#' @examples
#' \dontrun{
#' app <- create_dissertation_api()
#' backend <- BackendRserve$new()
#' backend$start(app, http_port = 8000)
#'
#' # Test endpoints:
#' # GET http://localhost:8000/summary?content_area=READING&group_by=GRADE
#' # GET http://localhost:8000/analysis?type=achievement_trends&content_area=MATHEMATICS
#' # GET http://localhost:8000/chapters?chapter=results&include_data=true
#' # GET http://localhost:8000/analyses
#' # GET http://localhost:8000/openapi.json
#' }
#'
#' @seealso
#' \code{\link{run_dissertation_api}} for simplified server startup
#' \code{\link{summarizeAssessment}}, \code{\link{analyzeAssessment}} for underlying functions
#'
create_dissertation_api <- function() {
    app <- RestRserve::Application$new()

    ## CORS helper
    add_cors_headers <- function(response) {
        response$set_header("Access-Control-Allow-Origin", "*")
        response$set_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        response$set_header("Access-Control-Allow-Headers", "Content-Type")
    }

    ## ---- /summary endpoint ----
    summary_handler <- function(request, response) {
        add_cors_headers(response)
        tryCatch({
            content_area <- request$get_query_parameter("content_area", default = "All")
            year <- request$get_query_parameter("year", default = "All")
            group_by <- request$get_query_parameter("group_by", default = "NONE")
            include_meta <- as.logical(request$get_query_parameter("include_meta", default = "false"))
            if (is.na(include_meta)) include_meta <- FALSE

            result <- summarizeAssessment(
                content_area = content_area,
                year = year,
                group_by = group_by,
                include_meta = include_meta
            )

            response$set_content_type("application/json")
            response$set_status_code(if (result$status == "success") 200L else 400L)
            response$set_body(jsonlite::toJSON(result, auto_unbox = TRUE, dataframe = "rows"))
        }, error = function(e) {
            error_result <- list(
                status = "error", message = as.character(e$message),
                endpoint = "/summary", timestamp = as.character(Sys.time()), code = "INTERNAL_ERROR"
            )
            response$set_content_type("application/json")
            response$set_status_code(500L)
            response$set_body(jsonlite::toJSON(error_result, auto_unbox = TRUE))
        })
    }

    ## ---- /analysis endpoint ----
    analysis_handler <- function(request, response) {
        add_cors_headers(response)
        tryCatch({
            analysis_type <- request$get_query_parameter("type", default = "achievement_trends")
            content_area <- request$get_query_parameter("content_area", default = "All")
            grade <- request$get_query_parameter("grade", default = "All")
            include_meta <- as.logical(request$get_query_parameter("include_meta", default = "false"))
            if (is.na(include_meta)) include_meta <- FALSE

            result <- analyzeAssessment(
                analysis_type = analysis_type,
                content_area = content_area,
                grade = grade,
                include_meta = include_meta
            )

            response$set_content_type("application/json")
            response$set_status_code(if (result$status == "success") 200L else 400L)
            response$set_body(jsonlite::toJSON(result, auto_unbox = TRUE, dataframe = "rows"))
        }, error = function(e) {
            error_result <- list(
                status = "error", message = as.character(e$message),
                endpoint = "/analysis", timestamp = as.character(Sys.time()), code = "INTERNAL_ERROR"
            )
            response$set_content_type("application/json")
            response$set_status_code(500L)
            response$set_body(jsonlite::toJSON(error_result, auto_unbox = TRUE))
        })
    }

    ## ---- /chapters endpoint ----
    chapters_handler <- function(request, response) {
        add_cors_headers(response)
        tryCatch({
            chapter <- request$get_query_parameter("chapter", default = "all")
            include_data <- as.logical(request$get_query_parameter("include_data", default = "false"))
            if (is.na(include_data)) include_data <- FALSE

            result <- getChapterSummary(chapter = chapter, include_data = include_data)

            response$set_content_type("application/json")
            response$set_status_code(if (result$status == "success") 200L else 400L)
            response$set_body(jsonlite::toJSON(result, auto_unbox = TRUE, dataframe = "rows"))
        }, error = function(e) {
            error_result <- list(
                status = "error", message = as.character(e$message),
                endpoint = "/chapters", timestamp = as.character(Sys.time()), code = "INTERNAL_ERROR"
            )
            response$set_content_type("application/json")
            response$set_status_code(500L)
            response$set_body(jsonlite::toJSON(error_result, auto_unbox = TRUE))
        })
    }

    ## ---- /analyses (discovery) endpoint ----
    analyses_handler <- function(request, response) {
        add_cors_headers(response)
        tryCatch({
            result <- getAvailableAnalyses()
            response$set_content_type("application/json")
            response$set_status_code(200L)
            response$set_body(jsonlite::toJSON(result, auto_unbox = TRUE, dataframe = "rows"))
        }, error = function(e) {
            error_result <- list(
                status = "error", message = as.character(e$message),
                endpoint = "/analyses", timestamp = as.character(Sys.time()), code = "INTERNAL_ERROR"
            )
            response$set_content_type("application/json")
            response$set_status_code(500L)
            response$set_body(jsonlite::toJSON(error_result, auto_unbox = TRUE))
        })
    }

    ## ---- /data/variables endpoint ----
    variables_handler <- function(request, response) {
        add_cors_headers(response)
        tryCatch({
            dt <- dissertation::assessmentData
            vars <- lapply(names(dt), function(col) {
                vals <- dt[[col]]
                info <- list(name = col, type = class(vals)[1])
                if (is.character(vals) || is.factor(vals)) {
                    uvals <- sort(unique(as.character(vals)))
                    info$unique_values <- if (length(uvals) <= 20) uvals else sprintf("%d unique values", length(uvals))
                } else if (is.numeric(vals) || is.integer(vals)) {
                    info$range <- range(vals, na.rm = TRUE)
                    info$na_count <- sum(is.na(vals))
                }
                info
            })
            names(vars) <- names(dt)
            result <- list(status = "success", variables = vars, n_rows = nrow(dt), n_cols = ncol(dt))
            response$set_content_type("application/json")
            response$set_status_code(200L)
            response$set_body(jsonlite::toJSON(result, auto_unbox = TRUE))
        }, error = function(e) {
            error_result <- list(
                status = "error", message = as.character(e$message),
                endpoint = "/data/variables", timestamp = as.character(Sys.time()), code = "INTERNAL_ERROR"
            )
            response$set_content_type("application/json")
            response$set_status_code(500L)
            response$set_body(jsonlite::toJSON(error_result, auto_unbox = TRUE))
        })
    }

    ## ---- /openapi.json endpoint ----
    openapi_handler <- function(request, response) {
        add_cors_headers(response)
        tryCatch({
            spec <- list(
                openapi = "3.0.0",
                info = list(
                    title = "Dissertation API",
                    version = "0.0.1",
                    description = "REST API for an AI-native dissertation on student achievement patterns. Exposes analysis functions for the NextJS frontend and MCP tools."
                ),
                paths = list(
                    "/summary" = list(get = list(
                        summary = "Get assessment summary statistics",
                        parameters = list(
                            list(name = "content_area", `in` = "query", description = "Content area filter", required = FALSE,
                                 schema = list(type = "string", default = "All", enum = list("All", "READING", "MATHEMATICS"))),
                            list(name = "year", `in` = "query", description = "Year filter (YYYY_YYYY format)", required = FALSE,
                                 schema = list(type = "string", default = "All")),
                            list(name = "group_by", `in` = "query", description = "Grouping variable", required = FALSE,
                                 schema = list(type = "string", default = "NONE",
                                               enum = list("NONE", "CONTENT_AREA", "GRADE", "DISTRICT_NUMBER", "SCHOOL_NUMBER", "YEAR"))),
                            list(name = "include_meta", `in` = "query", description = "Include metadata", required = FALSE,
                                 schema = list(type = "boolean", default = FALSE))
                        ),
                        responses = list("200" = list(description = "Summary statistics"), "400" = list(description = "Invalid parameters"), "500" = list(description = "Server error"))
                    )),
                    "/analysis" = list(get = list(
                        summary = "Run detailed assessment analysis",
                        parameters = list(
                            list(name = "type", `in` = "query", description = "Analysis type", required = FALSE,
                                 schema = list(type = "string", default = "achievement_trends",
                                               enum = list("achievement_trends", "score_distribution", "district_comparison", "cohort_progress"))),
                            list(name = "content_area", `in` = "query", description = "Content area", required = FALSE,
                                 schema = list(type = "string", default = "All")),
                            list(name = "grade", `in` = "query", description = "Grade level filter", required = FALSE,
                                 schema = list(type = "string", default = "All")),
                            list(name = "include_meta", `in` = "query", description = "Include metadata", required = FALSE,
                                 schema = list(type = "boolean", default = FALSE))
                        ),
                        responses = list("200" = list(description = "Analysis results"), "400" = list(description = "Invalid parameters"), "500" = list(description = "Server error"))
                    )),
                    "/chapters" = list(get = list(
                        summary = "Get dissertation chapter information",
                        parameters = list(
                            list(name = "chapter", `in` = "query", description = "Chapter name or number", required = FALSE,
                                 schema = list(type = "string", default = "all")),
                            list(name = "include_data", `in` = "query", description = "Include associated data summaries", required = FALSE,
                                 schema = list(type = "boolean", default = FALSE))
                        ),
                        responses = list("200" = list(description = "Chapter information"), "400" = list(description = "Invalid chapter"), "500" = list(description = "Server error"))
                    )),
                    "/analyses" = list(get = list(
                        summary = "Discover available analyses and parameters",
                        responses = list("200" = list(description = "Available analyses"))
                    )),
                    "/data/variables" = list(get = list(
                        summary = "Get dataset variable metadata",
                        responses = list("200" = list(description = "Variable information"))
                    ))
                )
            )

            response$set_content_type("application/json")
            response$set_status_code(200L)
            response$set_body(jsonlite::toJSON(spec, auto_unbox = TRUE, pretty = TRUE))
        }, error = function(e) {
            error_result <- list(status = "error", message = as.character(e$message), endpoint = "/openapi.json",
                                 timestamp = as.character(Sys.time()), code = "OPENAPI_ERROR")
            response$set_content_type("application/json")
            response$set_status_code(500L)
            response$set_body(jsonlite::toJSON(error_result, auto_unbox = TRUE))
        })
    }

    ## Register endpoints
    app$add_get("/summary", summary_handler)
    app$add_get("/analysis", analysis_handler)
    app$add_get("/chapters", chapters_handler)
    app$add_get("/analyses", analyses_handler)
    app$add_get("/data/variables", variables_handler)
    app$add_get("/openapi.json", openapi_handler)

    ## CORS preflight handlers
    cors_preflight <- function(req, res) {
        add_cors_headers(res)
        res$set_status_code(204L)
    }
    for (path in c("/summary", "/analysis", "/chapters", "/analyses", "/data/variables")) {
        app$add_options(path, cors_preflight)
    }

    return(app)
}


#' Run Dissertation API
#'
#' @title Start Dissertation API Server
#' @description Starts the dissertation REST API server using RestRserve.
#' @param port Integer. The port number to listen on (default: 8000).
#' @param host Character. The host address to listen on (default: "127.0.0.1").
#' @return None (starts server, blocks until terminated)
#' @export
#'
#' @examples
#' \dontrun{
#' run_dissertation_api(port = 8000)
#' }
#'
run_dissertation_api <- function(port = 8000, host = "127.0.0.1") {
    app <- create_dissertation_api()
    backend <- RestRserve::BackendRserve$new()
    backend$start(app, http_port = port, host = host)
}
