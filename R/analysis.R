#' Summarize Assessment Data
#'
#' @title Generate Summary Statistics from Assessment Data
#' @description Produces structured summary statistics from the assessmentData dataset,
#' suitable for direct consumption by web frontends, REST APIs, and AI agents.
#' Returns a consistent list structure with status, results, and optional metadata.
#'
#' @param content_area Character string specifying the content area to summarize.
#' Options: "READING", "MATHEMATICS", or "All" (default: "All").
#' Case-insensitive matching.
#' @param year Character or "All" specifying the academic year to filter.
#' Use the "YYYY_YYYY" format (e.g., "2022_2023"). Default: "All" (all years).
#' @param group_by Character string specifying a grouping variable for disaggregated
#' summaries. Options: "NONE", "CONTENT_AREA", "GRADE", "DISTRICT_NUMBER",
#' "SCHOOL_NUMBER", "YEAR" (default: "NONE").
#' @param include_meta Logical indicating whether to include metadata (default: FALSE).
#'
#' @return A list containing:
#' \itemize{
#'   \item \code{status}: "success" or "error"
#'   \item \code{summary}: A data.table with summary statistics (mean_score, median_score, sd_score, pct_proficient, n)
#'   \item \code{filters}: List documenting which filters were applied
#'   \item \code{metadata}: (optional) List with dataset info, available groupings, timestamp
#'   \item \code{message}: (error case only) Description of the error
#' }
#'
#' @details
#' This function demonstrates the pattern of creating analysis functions that return
#' structured, JSON-compatible output suitable for programmatic consumption. The
#' return structure is designed to be serialized directly to JSON for REST API
#' responses and MCP tool outputs.
#'
#' @section Model Context Protocol Integration:
#' This function is designed to be exposed through MCP tools, enabling AI systems to:
#' \itemize{
#'   \item Generate on-demand summaries for chatbot responses
#'   \item Answer reader questions about dissertation results
#'   \item Produce disaggregated analyses interactively
#'   \item Provide contextual data for follow-up questions
#' }
#'
#' @export
#' @import data.table
#'
#' @examples
#' # Overall summary
#' summarizeAssessment()
#'
#' # Summary for Mathematics only
#' summarizeAssessment(content_area = "MATHEMATICS")
#'
#' # Disaggregated by grade
#' summarizeAssessment(group_by = "GRADE")
#'
#' # Specific year and content area with metadata
#' summarizeAssessment(content_area = "READING", year = "2024_2025", include_meta = TRUE)
#'
#' @seealso
#' \code{\link{analyzeAssessment}} for detailed analyses
#' \code{\link{assessmentData}} for the underlying dataset
#' \code{\link{getAvailableAnalyses}} for discovering analysis options
#'
summarizeAssessment <- function(content_area = "All", year = "All", group_by = "NONE", include_meta = FALSE) {

    ## Input validation
    if (!is.character(content_area)) {
        return(list(status = "error", message = "content_area must be a character string"))
    }
    if (!is.character(group_by)) {
        return(list(status = "error", message = "group_by must be a character string"))
    }

    ## Normalize inputs
    content_area_upper <- toupper(content_area)
    group_by_upper <- toupper(group_by)

    valid_content_areas <- c("ALL", "READING", "MATHEMATICS")
    valid_groups <- c("NONE", "CONTENT_AREA", "GRADE", "DISTRICT_NUMBER", "SCHOOL_NUMBER", "YEAR")

    if (!content_area_upper %in% valid_content_areas) {
        return(list(
            status = "error",
            message = sprintf("Invalid content_area '%s'. Valid options: %s", content_area, paste(valid_content_areas, collapse = ", "))
        ))
    }

    if (!group_by_upper %in% valid_groups) {
        return(list(
            status = "error",
            message = sprintf("Invalid group_by '%s'. Valid options: %s", group_by, paste(valid_groups, collapse = ", "))
        ))
    }

    ## Filter data
    tmp_data <- copy(dissertation::assessmentData)

    if (content_area_upper != "ALL") {
        tmp_data <- tmp_data[toupper(CONTENT_AREA) == content_area_upper]
    }

    if (!identical(year, "All") && !identical(year, "all")) {
        tmp_data <- tmp_data[YEAR == year]
    }

    if (nrow(tmp_data) == 0L) {
        return(list(
            status = "error",
            message = "No data found for the specified filters."
        ))
    }

    ## Achievement levels considered "proficient or above"
    proficient_levels <- c("Proficient", "Advanced")

    ## Compute summary
    if (group_by_upper == "NONE") {
        summary_dt <- tmp_data[, .(
            mean_score = round(mean(SCALE_SCORE, na.rm = TRUE), 1),
            median_score = round(median(SCALE_SCORE, na.rm = TRUE), 1),
            sd_score = round(sd(SCALE_SCORE, na.rm = TRUE), 1),
            pct_proficient = round(100 * mean(ACHIEVEMENT_LEVEL %in% proficient_levels, na.rm = TRUE), 1),
            n_students = uniqueN(ID),
            n = .N
        )]
    } else {
        summary_dt <- tmp_data[, .(
            mean_score = round(mean(SCALE_SCORE, na.rm = TRUE), 1),
            median_score = round(median(SCALE_SCORE, na.rm = TRUE), 1),
            sd_score = round(sd(SCALE_SCORE, na.rm = TRUE), 1),
            pct_proficient = round(100 * mean(ACHIEVEMENT_LEVEL %in% proficient_levels, na.rm = TRUE), 1),
            n_students = uniqueN(ID),
            n = .N
        ), keyby = group_by_upper]
    }

    ## Build response
    response <- list(
        status = "success",
        summary = summary_dt,
        filters = list(
            content_area = content_area,
            year = year,
            group_by = group_by
        )
    )

    if (include_meta) {
        response[["metadata"]] <- list(
            dataset = "assessmentData",
            total_observations = nrow(dissertation::assessmentData),
            total_students = uniqueN(dissertation::assessmentData[["ID"]]),
            available_years = sort(unique(dissertation::assessmentData[["YEAR"]])),
            available_content_areas = sort(unique(dissertation::assessmentData[["CONTENT_AREA"]])),
            available_grades = sort(unique(dissertation::assessmentData[["GRADE"]])),
            available_groups = valid_groups,
            timestamp = Sys.time()
        )
    }

    return(response)
}


#' Analyze Assessment Patterns
#'
#' @title Detailed Assessment Data Analysis
#' @description Performs detailed analyses on the assessmentData dataset, including
#' achievement trends over time, scale score distributions, district comparisons,
#' and longitudinal cohort tracking. Returns structured output for API and MCP consumption.
#'
#' @param analysis_type Character string specifying the analysis type. Options:
#' \itemize{
#'   \item "achievement_trends": Mean scores and proficiency rates by year
#'   \item "score_distribution": Scale score percentile breakdown by content area and grade
#'   \item "district_comparison": Compare achievement across districts
#'   \item "cohort_progress": Track cohorts of students across years
#' }
#' Default: "achievement_trends".
#' @param content_area Character string: "READING", "MATHEMATICS", or "All" (default: "All").
#' @param grade Character string specifying grade to filter, or "All" (default: "All").
#' @param include_meta Logical (default: FALSE).
#'
#' @return A list containing:
#' \itemize{
#'   \item \code{status}: "success" or "error"
#'   \item \code{analysis_type}: The type of analysis performed
#'   \item \code{results}: A data.table with analysis results
#'   \item \code{interpretation}: A character string with a plain-language interpretation
#'   \item \code{metadata}: (optional) Analysis metadata
#'   \item \code{message}: (error case only) Description of the error
#' }
#'
#' @section Dissertation Integration:
#' This function maps to dissertation chapters:
#' \itemize{
#'   \item \code{achievement_trends} -> Results Chapter, Section on Longitudinal Achievement Patterns
#'   \item \code{score_distribution} -> Methods/Results Chapter, Section on Distribution Properties
#'   \item \code{district_comparison} -> Results Chapter, Section on District-Level Variation
#'   \item \code{cohort_progress} -> Results Chapter, Section on Cohort Tracking
#' }
#'
#' @export
#' @import data.table
#'
#' @examples
#' # Achievement trends over time
#' analyzeAssessment("achievement_trends")
#'
#' # Score distributions for Mathematics
#' analyzeAssessment("score_distribution", content_area = "MATHEMATICS")
#'
#' # District comparison in Reading
#' analyzeAssessment("district_comparison", content_area = "READING")
#'
#' # Cohort progress
#' analyzeAssessment("cohort_progress", content_area = "MATHEMATICS")
#'
#' @seealso
#' \code{\link{summarizeAssessment}} for summary statistics
#' \code{\link{getAvailableAnalyses}} for discovering analysis options
#'
analyzeAssessment <- function(analysis_type = "achievement_trends", content_area = "All",
                               grade = "All", include_meta = FALSE) {

    ## Input validation
    valid_types <- c("achievement_trends", "score_distribution", "district_comparison", "cohort_progress")
    if (!analysis_type %in% valid_types) {
        return(list(
            status = "error",
            message = sprintf("Invalid analysis_type '%s'. Valid options: %s", analysis_type, paste(valid_types, collapse = ", "))
        ))
    }

    ## Filter data
    tmp_data <- copy(dissertation::assessmentData)
    content_area_upper <- toupper(content_area)
    if (content_area_upper != "ALL") {
        tmp_data <- tmp_data[toupper(CONTENT_AREA) == content_area_upper]
    }

    grade_upper <- toupper(grade)
    if (grade_upper != "ALL") {
        tmp_data <- tmp_data[GRADE == grade]
    }

    if (nrow(tmp_data) == 0L) {
        return(list(status = "error", message = "No data found for the specified filters."))
    }

    ## Achievement levels considered "proficient or above"
    proficient_levels <- c("Proficient", "Advanced")

    ## Perform analysis
    results <- switch(analysis_type,
        "achievement_trends" = {
            res <- tmp_data[, .(
                mean_score = round(mean(SCALE_SCORE, na.rm = TRUE), 1),
                median_score = round(median(SCALE_SCORE, na.rm = TRUE), 1),
                pct_proficient = round(100 * mean(ACHIEVEMENT_LEVEL %in% proficient_levels, na.rm = TRUE), 1),
                n_students = uniqueN(ID),
                n = .N
            ), keyby = .(YEAR, CONTENT_AREA)]

            year_scores <- res[, .(avg = mean(mean_score)), keyby = YEAR]
            trend_direction <- if (nrow(year_scores) >= 2) {
                diff_val <- year_scores[.N, avg] - year_scores[1L, avg]
                if (diff_val > 2) "an upward trend" else if (diff_val < -2) "a downward trend" else "relative stability"
            } else "a single year snapshot"

            interp <- sprintf(
                "Achievement trends across %d year(s) show %s in mean scale scores. The overall mean score is %.1f with a proficiency rate of %.1f%%.",
                length(unique(res$YEAR)),
                trend_direction,
                mean(res$mean_score),
                mean(res$pct_proficient)
            )
            list(results = res, interpretation = interp)
        },
        "score_distribution" = {
            res <- tmp_data[, .(
                p10 = round(quantile(SCALE_SCORE, 0.10, na.rm = TRUE)),
                p25 = round(quantile(SCALE_SCORE, 0.25, na.rm = TRUE)),
                p50 = round(quantile(SCALE_SCORE, 0.50, na.rm = TRUE)),
                p75 = round(quantile(SCALE_SCORE, 0.75, na.rm = TRUE)),
                p90 = round(quantile(SCALE_SCORE, 0.90, na.rm = TRUE)),
                mean = round(mean(SCALE_SCORE, na.rm = TRUE), 1),
                sd = round(sd(SCALE_SCORE, na.rm = TRUE), 1),
                n = .N
            ), keyby = .(CONTENT_AREA, GRADE)]

            overall_iqr <- IQR(tmp_data$SCALE_SCORE, na.rm = TRUE)
            interp <- sprintf(
                "Scale score distributions show a median of %d with an interquartile range of %.0f points, indicating %s variation in student achievement.",
                round(median(tmp_data$SCALE_SCORE, na.rm = TRUE)),
                overall_iqr,
                ifelse(overall_iqr > 60, "substantial", ifelse(overall_iqr > 30, "moderate", "limited"))
            )
            list(results = res, interpretation = interp)
        },
        "district_comparison" = {
            res <- tmp_data[, .(
                mean_score = round(mean(SCALE_SCORE, na.rm = TRUE), 1),
                median_score = round(median(SCALE_SCORE, na.rm = TRUE), 1),
                pct_proficient = round(100 * mean(ACHIEVEMENT_LEVEL %in% proficient_levels, na.rm = TRUE), 1),
                n_students = uniqueN(ID),
                n_schools = uniqueN(SCHOOL_NUMBER),
                n = .N
            ), keyby = .(DISTRICT_NUMBER, CONTENT_AREA)]

            score_range <- range(res$mean_score)
            interp <- sprintf(
                "District comparison reveals mean scale scores ranging from %.1f to %.1f across %d districts (gap of %.1f points). Proficiency rates range from %.1f%% to %.1f%%.",
                score_range[1], score_range[2],
                uniqueN(res$DISTRICT_NUMBER),
                diff(score_range),
                min(res$pct_proficient), max(res$pct_proficient)
            )
            list(results = res, interpretation = interp)
        },
        "cohort_progress" = {
            ## Track students who appear in at least 2 years
            student_years <- tmp_data[, .(n_years = uniqueN(YEAR)), by = ID]
            cohort_ids <- student_years[n_years >= 2, ID]
            cohort_data <- tmp_data[ID %in% cohort_ids]

            res <- cohort_data[, .(
                mean_score = round(mean(SCALE_SCORE, na.rm = TRUE), 1),
                pct_proficient = round(100 * mean(ACHIEVEMENT_LEVEL %in% proficient_levels, na.rm = TRUE), 1),
                n_students = uniqueN(ID),
                n_observations = .N
            ), keyby = .(YEAR, CONTENT_AREA)]

            interp <- sprintf(
                "Cohort analysis tracks %s students with 2+ years of data. Across the cohort, the mean scale score is %.1f with an overall proficiency rate of %.1f%%.",
                format(length(cohort_ids), big.mark = ","),
                mean(cohort_data$SCALE_SCORE, na.rm = TRUE),
                100 * mean(cohort_data$ACHIEVEMENT_LEVEL %in% proficient_levels, na.rm = TRUE)
            )
            list(results = res, interpretation = interp)
        }
    )

    ## Build response
    response <- list(
        status = "success",
        analysis_type = analysis_type,
        results = results$results,
        interpretation = results$interpretation,
        filters = list(content_area = content_area, grade = grade)
    )

    if (include_meta) {
        response[["metadata"]] <- list(
            available_analyses = valid_types,
            available_content_areas = sort(unique(dissertation::assessmentData[["CONTENT_AREA"]])),
            available_grades = sort(unique(dissertation::assessmentData[["GRADE"]])),
            available_years = sort(unique(dissertation::assessmentData[["YEAR"]])),
            dataset = "assessmentData",
            timestamp = Sys.time()
        )
    }

    return(response)
}


#' Get Available Analyses
#'
#' @title List Available Analysis Types
#' @description Returns information about all available analysis functions and their
#' parameters. Designed for programmatic discovery by APIs, MCP tools, and chatbots.
#'
#' @return A list containing:
#' \itemize{
#'   \item \code{analyses}: Named list of available analysis functions with descriptions and parameters
#'   \item \code{content_areas}: Character vector of available content areas
#'   \item \code{years}: Character vector of available years
#'   \item \code{grades}: Character vector of available grades
#' }
#'
#' @export
#' @import data.table
#'
#' @examples
#' info <- getAvailableAnalyses()
#' names(info$analyses)
#'
#' @seealso
#' \code{\link{summarizeAssessment}}, \code{\link{analyzeAssessment}}
#'
getAvailableAnalyses <- function() {
    list(
        analyses = list(
            summarizeAssessment = list(
                description = "Generate summary statistics (mean, median, SD of scale scores; proficiency rates; student counts)",
                parameters = list(
                    content_area = "READING, MATHEMATICS, or All",
                    year = "Academic year in YYYY_YYYY format or All",
                    group_by = "NONE, CONTENT_AREA, GRADE, DISTRICT_NUMBER, SCHOOL_NUMBER, YEAR"
                )
            ),
            analyzeAssessment = list(
                description = "Detailed assessment analyses including achievement trends, score distributions, district comparisons, and cohort tracking",
                parameters = list(
                    analysis_type = "achievement_trends, score_distribution, district_comparison, cohort_progress",
                    content_area = "READING, MATHEMATICS, or All",
                    grade = "Grade level (e.g., '3', '4') or All"
                )
            )
        ),
        content_areas = sort(unique(dissertation::assessmentData[["CONTENT_AREA"]])),
        years = sort(unique(dissertation::assessmentData[["YEAR"]])),
        grades = sort(unique(dissertation::assessmentData[["GRADE"]])),
        districts = sort(unique(dissertation::assessmentData[["DISTRICT_NUMBER"]])),
        n_students = uniqueN(dissertation::assessmentData[["ID"]]),
        n_observations = nrow(dissertation::assessmentData)
    )
}


#' Get Chapter Summary
#'
#' @title Retrieve Dissertation Chapter Summary
#' @description Returns a structured summary for a specified dissertation chapter,
#' linking the chapter content to the underlying data analyses. Designed for the
#' chatbot to answer reader questions like "What does Chapter 4 cover?"
#'
#' @param chapter Character string or integer specifying the chapter.
#' Options: "introduction" (1), "literature_review" (2), "methods" (3),
#' "results" (4), "discussion" (5), or "all".
#' @param include_data Logical indicating whether to include associated data summaries (default: FALSE).
#'
#' @return A list containing:
#' \itemize{
#'   \item \code{status}: "success" or "error"
#'   \item \code{chapter}: Chapter name and number
#'   \item \code{summary}: Brief description of chapter content
#'   \item \code{key_analyses}: List of analyses relevant to this chapter
#'   \item \code{data_summary}: (optional) Associated data summaries
#' }
#'
#' @export
#'
#' @examples
#' getChapterSummary("results")
#' getChapterSummary(4, include_data = TRUE)
#' getChapterSummary("all")
#'
#' @seealso
#' \code{\link{analyzeAssessment}} for running the analyses referenced by chapters
#'
getChapterSummary <- function(chapter = "all", include_data = FALSE) {

    ## Chapter definitions (template - participants customize these)
    chapters <- list(
        introduction = list(
            number = 1,
            title = "Introduction",
            summary = "Establishes the research context, problem statement, and significance of examining student achievement patterns across grades, content areas, and districts. Presents the research questions guiding this dissertation.",
            key_analyses = list(),
            research_questions = c(
                "RQ1: What are the longitudinal achievement trends in Mathematics and Reading across the study period?",
                "RQ2: How do scale score distributions and proficiency rates vary across grade levels and districts?",
                "RQ3: What achievement patterns emerge when tracking student cohorts across multiple years?"
            )
        ),
        literature_review = list(
            number = 2,
            title = "Literature Review",
            summary = "Reviews the literature on student achievement measurement, standards-based assessment, proficiency classification, and the use of longitudinal assessment data in educational research and accountability.",
            key_analyses = list(),
            research_questions = list()
        ),
        methods = list(
            number = 3,
            title = "Methods",
            summary = "Describes the assessment data, sample characteristics, achievement level classifications, and analytic approach. Details the reproducible research workflow using the R package architecture and AI-native framework.",
            key_analyses = c("score_distribution", "summarizeAssessment"),
            research_questions = list()
        ),
        results = list(
            number = 4,
            title = "Results",
            summary = "Presents findings organized by research question: longitudinal achievement trends, district-level variation in outcomes, and cohort-based tracking of student progress.",
            key_analyses = c("achievement_trends", "district_comparison", "cohort_progress"),
            research_questions = list()
        ),
        discussion = list(
            number = 5,
            title = "Discussion",
            summary = "Interprets results in the context of the literature, discusses implications for educational policy and practice, acknowledges limitations, and suggests directions for future research.",
            key_analyses = list(),
            research_questions = list()
        )
    )

    ## Handle numeric chapter input
    if (is.numeric(chapter)) {
        chapter_names <- names(chapters)
        if (chapter >= 1 && chapter <= length(chapter_names)) {
            chapter <- chapter_names[chapter]
        } else {
            return(list(
                status = "error",
                message = sprintf("Chapter number %d is out of range. Valid: 1-%d.", chapter, length(chapters))
            ))
        }
    }

    chapter_lower <- tolower(chapter)

    if (chapter_lower == "all") {
        response <- list(
            status = "success",
            chapters = chapters
        )
        return(response)
    }

    if (!chapter_lower %in% names(chapters)) {
        return(list(
            status = "error",
            message = sprintf("Unknown chapter '%s'. Valid options: %s, or 'all'.", chapter, paste(names(chapters), collapse = ", "))
        ))
    }

    ch <- chapters[[chapter_lower]]
    response <- list(
        status = "success",
        chapter = list(number = ch$number, title = ch$title),
        summary = ch$summary,
        key_analyses = ch$key_analyses,
        research_questions = ch$research_questions
    )

    if (include_data && length(ch$key_analyses) > 0) {
        data_summaries <- list()
        for (analysis in ch$key_analyses) {
            if (analysis == "summarizeAssessment") {
                data_summaries[[analysis]] <- summarizeAssessment()
            } else {
                data_summaries[[analysis]] <- analyzeAssessment(analysis_type = analysis)
            }
        }
        response[["data_summary"]] <- data_summaries
    }

    return(response)
}
