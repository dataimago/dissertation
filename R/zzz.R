#' @importFrom utils packageDescription
#' @importFrom crayon bold cyan green magenta red
#' @importFrom toOrdinal toOrdinalDate

.onLoad <- function(libname, pkgname) {
}

.onAttach <- function(libname, pkgname) {
    if (interactive()) {
        # Extract version information
        installed.version <- utils::packageDescription("dissertation")[["Version"]]

        # Define startup message
        message_text <- paste0(
            magenta(bold("\U1F393 dissertation v", installed.version, sep = "")), " - ", toOrdinal::toOrdinalDate("2026-4-1"), "\n",
            strrep("\u2501", 50), "\n",
            bold("\U1F4CA "), "An AI-Native Dissertation Framework\n",
            strrep("\u2501", 50), "\n",
            "\U1F4A1 Tip: ", magenta(bold("> help(package=\"dissertation\")")), "\n",
            "\U1F310 Docs: ", magenta(bold("https://dataimago.github.io/dissertation")), "\n",
            "\U1F680 API:  ", magenta(bold("> run_dissertation_api()")), "\n",
            strrep("\u2501", 50), "\n",
            "\u2728 Happy dissertating!")

        packageStartupMessage(message_text)
    }
}
