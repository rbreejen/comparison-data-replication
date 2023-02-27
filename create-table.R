# 1. Load required packages -----------------------------------------------

list.of.packages <- c("reactable", "gh", "data.table", "here", "htmltools", "htmlwidgets", "webshot", "stringr", "reactablefmtr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# 2. Retrieve data --------------------------------------------------------

data <- fread(here::here("comparison-data-replication.csv"),quote="")

column_transformer <- function(value) {
  if (value == "N") {
    args <- c(list(role = "img", title = value), list("–", style = "color: #666; font-weight: 700"))
    do.call(span, args)
  } else if (value == "Y") {
    args <- c(list(role = "img", title = value), list(shiny::icon("check"), style = "color: green"))
    do.call(span, args)
  } else if (!is.na(as.numeric(value))) {
    span(class = "number", value)
  } else if (str_starts(value, "#")) {
  } else {
    markdown::renderMarkdown(value)
  }
}

tbl <- reactable(data, 
                 pagination = FALSE,
          columns = list(
            category = colDef(
              align = "left",
              name = ""
            ),
            item = colDef(
              html = TRUE,
              align = "left",
              minWidth = 180,
              name = ""
            ),
            `Flink CDC` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value)
            ),
            `Debezium + Kafka Connect` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value)
            ),
            `Airbyte` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value)
            ),
            `Singer` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value)
            )
          ),
          theme = reactableTheme(
            highlightColor = "#f3fafb",
            borderColor = "hsl(0, 0%, 93%)",
            #padding = "2px",
            headerStyle = list(borderColor = "hsl(0, 0%, 90%)"),
            # Vertically center cells
            cellStyle = list(display = "flex", flexDirection = "column", justifyContent = "center")
          ),
          defaultExpanded = T,
          sortable = F,
          class = "comparison-tbl")

tbl <- div(class = "comparison",
    div(class = "comparison-header",
        h2(class = "comparison-title", "Comparison log-based CDC replication"),
        "Date of comparison: Feb 2023"
    ),
    tbl
)

tbl <- browsable(
  tagList(list(
    tags$head(
      # you'll need to be very specific
      #tags$style(".rt-sort-header{color:red;}"),
      # could also use url
      tags$link(href = "https://fonts.googleapis.com/css?family=Karla:400,700|Fira+Mono&display=fallback", rel = "stylesheet"),
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    tbl
  ))
)

# Saving ------------------------------------------------------------------
html_file <- "table.html"
save_html(tbl, file = html_file)

sourceDir <- function (path, pattern = "\\.[rR]$", env = NULL, chdir = TRUE) 
{
  files <- sort(dir(path, pattern, full.names = TRUE))
  lapply(files, source, chdir = chdir)
}
#Sys.setenv(OPENSSL_CONF="/dev/null")
#webshot::webshot(url = html_file, file = "img.pdf", delay = 0.1, vwidth = 1028)
