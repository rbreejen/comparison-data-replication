# 1. Load required packages -----------------------------------------------

list.of.packages <- c("reactable", "gh", "data.table", "here", "htmltools", "htmlwidgets", "webshot", "stringr", "reactablefmtr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# 2. Retrieve data --------------------------------------------------------

data <- fread(here::here("comparison-data-replication.csv"),quote="")

column_transformer <- function(value) {
  if (str_detect(value, "%N%")) {
    markdown::renderMarkdown(stringr::str_replace(value, "%N%", "<span><img alt='' src='https://uploads-ssl.webflow.com/61f2440c9fcbc37831846652/62fc3b33d02ef39b1fc3adfb_icon_x.png' style='width: 25.56px; height: 20.00px; margin-left: 0.00px; margin-top: 0.00px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);' title=''></i></span>"))
    #args <- c(list(role = "img", title = value), list("–", style = "color: #666; font-weight: 700"))
    #do.call(span, args)
  } else if (str_detect(value, "%Y%")) {
    markdown::renderMarkdown(stringr::str_replace(value, "%Y%", "<span><img alt='' src='https://uploads-ssl.webflow.com/61f2440c9fcbc37831846652/62fc3b327bf0d9337241e112_check.png' style='width: 25.56px; height: 20.00px; margin-left: 0.00px; margin-top: 0.00px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);' title=''></i></span>"))
    #args <- c(list(role = "img", title = value), list(shiny::icon("check"), style = "color: green"))
    #do.call(span, args)
  } else if (str_detect(value, "%U%")) {
    markdown::renderMarkdown(stringr::str_replace(value, "%U%", "<span><img alt='' src='https://uploads-ssl.webflow.com/61f2440c9fcbc37831846652/62fc3b3276df8460a3e8d91b_output-onlinepngtools.png' style='width: 25.56px; height: 20.00px; margin-left: 0.00px; margin-top: 0.00px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);' title=''></i></span>"))
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
              cell = function(value) column_transformer(value),
              minWidth = 180,
              name = ""
            ),
            `Debezium` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              name = "<img alt='' src='https://debezium.io/assets/images/color_black_debezium_type_600px.svg'><p>+</p><p> Kafka Connect / Debezium server</p>"
            ),            
            `Flink` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              name = "<img alt='' src='https://debezium.io/assets/images/color_black_debezium_type_600px.svg'<p>+</p><p>Flink CDC Datastream API</p>"
            ),
            `Airbyte` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              name = "<img alt='' src='https://assets.website-files.com/605e01bc25f7e19a82e74788/624d9c4a375a55100be6b257_Airbyte_logo_color_dark.svg' style='width: 64.50px; height: 49.06px'>"
            ),
            `AWS` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              name = "<img alt='' src='https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg' style='width: 64.50px; height: 49.06px'><p>DMS</p>"
            ),
            `Qlik` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              name = "<img alt='' src='https://upload.wikimedia.org/wikipedia/commons/3/32/Qlik_Logo.svg' style='width: 64.50px; height: 49.06px'><p>Replica</p>"
            ),
            `Fivetran` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              name = "<img alt='' src='https://assets-global.website-files.com/6130fa1501794ed4d11867ba/63d9599008ad50523f8ce26a_logo.svg' style='width: 64.50px; height: 49.06px'>"
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

#Sys.setenv(OPENSSL_CONF="/dev/null")
#webshot::webshot(url = html_file, file = "img.pdf", delay = 0.1, vwidth = 1028)
