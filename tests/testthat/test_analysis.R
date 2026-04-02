# Tests for dissertation analysis functions

library(testthat)
library(data.table)

# Load the package data
data(assessmentData, envir = environment())

# ============================================================================
# summarizeAssessment tests
# ============================================================================

test_that("summarizeAssessment returns success with default parameters", {
    result <- summarizeAssessment()
    expect_type(result, "list")
    expect_equal(result$status, "success")
    expect_true(is.data.table(result$summary))
    expect_true("mean_score" %in% names(result$summary))
    expect_true("median_score" %in% names(result$summary))
    expect_true("n" %in% names(result$summary))
    expect_true("pct_proficient" %in% names(result$summary))
})

test_that("summarizeAssessment filters by content area", {
    result_read <- summarizeAssessment(content_area = "READING")
    result_math <- summarizeAssessment(content_area = "MATHEMATICS")
    result_all <- summarizeAssessment(content_area = "All")

    expect_equal(result_read$status, "success")
    expect_equal(result_math$status, "success")
    expect_equal(result_all$status, "success")

    # All should have more observations than either individual
    expect_true(result_all$summary$n >= result_read$summary$n)
    expect_true(result_all$summary$n >= result_math$summary$n)
})

test_that("summarizeAssessment is case-insensitive for content_area", {
    result1 <- summarizeAssessment(content_area = "reading")
    result2 <- summarizeAssessment(content_area = "READING")
    result3 <- summarizeAssessment(content_area = "Reading")

    expect_equal(result1$summary$mean_score, result2$summary$mean_score)
    expect_equal(result2$summary$mean_score, result3$summary$mean_score)
})

test_that("summarizeAssessment handles group_by correctly", {
    result <- summarizeAssessment(group_by = "GRADE")
    expect_equal(result$status, "success")
    expect_true(nrow(result$summary) > 1)  # Multiple groups
    expect_true("GRADE" %in% names(result$summary))
})

test_that("summarizeAssessment handles group_by DISTRICT_NUMBER", {
    result <- summarizeAssessment(group_by = "DISTRICT_NUMBER")
    expect_equal(result$status, "success")
    expect_true(nrow(result$summary) > 1)
    expect_true("DISTRICT_NUMBER" %in% names(result$summary))
})

test_that("summarizeAssessment includes metadata when requested", {
    result <- summarizeAssessment(include_meta = TRUE)
    expect_true(!is.null(result$metadata))
    expect_true(is.list(result$metadata))
    expect_true(!is.null(result$metadata$total_students))
    expect_true(!is.null(result$metadata$available_years))
    expect_true(!is.null(result$metadata$available_grades))
    expect_true(!is.null(result$metadata$timestamp))
})

test_that("summarizeAssessment handles invalid inputs gracefully", {
    result <- summarizeAssessment(content_area = "SCIENCE")
    expect_equal(result$status, "error")
    expect_true(grepl("Invalid", result$message))

    result <- summarizeAssessment(group_by = "INVALID_GROUP")
    expect_equal(result$status, "error")
    expect_true(grepl("Invalid", result$message))
})

test_that("summarizeAssessment filters by year", {
    years <- sort(unique(assessmentData$YEAR))
    result <- summarizeAssessment(year = years[1])
    expect_equal(result$status, "success")
    expect_true(result$summary$n > 0)
})

# ============================================================================
# analyzeAssessment tests
# ============================================================================

test_that("analyzeAssessment achievement_trends works", {
    result <- analyzeAssessment("achievement_trends")
    expect_equal(result$status, "success")
    expect_equal(result$analysis_type, "achievement_trends")
    expect_true(is.data.table(result$results))
    expect_true(is.character(result$interpretation))
    expect_true("mean_score" %in% names(result$results))
    expect_true("pct_proficient" %in% names(result$results))
})

test_that("analyzeAssessment score_distribution works", {
    result <- analyzeAssessment("score_distribution")
    expect_equal(result$status, "success")
    expect_true(all(c("p10", "p25", "p50", "p75", "p90") %in% names(result$results)))
})

test_that("analyzeAssessment district_comparison works", {
    result <- analyzeAssessment("district_comparison")
    expect_equal(result$status, "success")
    expect_true("DISTRICT_NUMBER" %in% names(result$results))
    expect_true(nrow(result$results) > 1)
})

test_that("analyzeAssessment cohort_progress works", {
    result <- analyzeAssessment("cohort_progress")
    expect_equal(result$status, "success")
    expect_true("n_students" %in% names(result$results))
})

test_that("analyzeAssessment filters by content_area", {
    result <- analyzeAssessment("achievement_trends", content_area = "MATHEMATICS")
    expect_equal(result$status, "success")
    expect_true(all(result$results$CONTENT_AREA == "MATHEMATICS"))
})

test_that("analyzeAssessment filters by grade", {
    result <- analyzeAssessment("score_distribution", grade = "5")
    expect_equal(result$status, "success")
    expect_true(all(result$results$GRADE == "5"))
})

test_that("analyzeAssessment handles invalid analysis type", {
    result <- analyzeAssessment("nonexistent_analysis")
    expect_equal(result$status, "error")
    expect_true(grepl("Invalid", result$message))
})

test_that("analyzeAssessment includes metadata when requested", {
    result <- analyzeAssessment("achievement_trends", include_meta = TRUE)
    expect_true(!is.null(result$metadata))
    expect_true("available_analyses" %in% names(result$metadata))
    expect_true("available_content_areas" %in% names(result$metadata))
})

# ============================================================================
# getAvailableAnalyses tests
# ============================================================================

test_that("getAvailableAnalyses returns discovery information", {
    info <- getAvailableAnalyses()
    expect_true(is.list(info))
    expect_true("analyses" %in% names(info))
    expect_true("content_areas" %in% names(info))
    expect_true("years" %in% names(info))
    expect_true("grades" %in% names(info))

    expect_true("summarizeAssessment" %in% names(info$analyses))
    expect_true("analyzeAssessment" %in% names(info$analyses))
})

test_that("getAvailableAnalyses reports correct content areas", {
    info <- getAvailableAnalyses()
    expect_true("MATHEMATICS" %in% info$content_areas)
    expect_true("READING" %in% info$content_areas)
})

# ============================================================================
# getChapterSummary tests
# ============================================================================

test_that("getChapterSummary works for individual chapters", {
    result <- getChapterSummary("results")
    expect_equal(result$status, "success")
    expect_equal(result$chapter$number, 4)
    expect_true(is.character(result$summary))
})

test_that("getChapterSummary works with numeric input", {
    result <- getChapterSummary(3)
    expect_equal(result$status, "success")
    expect_equal(result$chapter$title, "Methods")
})

test_that("getChapterSummary returns all chapters", {
    result <- getChapterSummary("all")
    expect_equal(result$status, "success")
    expect_true(length(result$chapters) == 5)
})

test_that("getChapterSummary handles invalid chapter", {
    result <- getChapterSummary("nonexistent")
    expect_equal(result$status, "error")

    result <- getChapterSummary(99)
    expect_equal(result$status, "error")
})

test_that("getChapterSummary includes data when requested", {
    result <- getChapterSummary("results", include_data = TRUE)
    expect_equal(result$status, "success")
    expect_true(!is.null(result$data_summary))
    expect_true(length(result$data_summary) > 0)
})

# ============================================================================
# Dataset integrity tests
# ============================================================================

test_that("assessmentData is a proper data.table", {
    expect_true(is.data.table(dissertation::assessmentData))

    expected_cols <- c("CONTENT_AREA", "YEAR", "GRADE", "ID", "SCALE_SCORE",
                       "ACHIEVEMENT_LEVEL", "DISTRICT_NUMBER", "SCHOOL_NUMBER")
    expect_true(all(expected_cols %in% names(dissertation::assessmentData)))
})

test_that("assessmentData has valid scale scores", {
    scores <- dissertation::assessmentData[, SCALE_SCORE]
    expect_true(is.numeric(scores))
    # Some NAs are expected in real assessment data (e.g., absent students)
    # but the vast majority should be non-missing
    pct_non_na <- sum(!is.na(scores)) / length(scores)
    expect_true(pct_non_na > 0.95)
})

test_that("assessmentData has expected content areas", {
    expect_true(all(c("READING", "MATHEMATICS") %in% unique(dissertation::assessmentData$CONTENT_AREA)))
})

test_that("assessmentData has multiple years", {
    expect_true(length(unique(dissertation::assessmentData$YEAR)) >= 2)
})

test_that("assessmentData YEAR values are in expected format", {
    years <- unique(dissertation::assessmentData$YEAR)
    expect_true(all(grepl("^\\d{4}_\\d{4}$", years)))
})
