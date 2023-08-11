# 1. Load required packages -----------------------------------------------

list.of.packages <- c("reactable", "data.table", "here", "htmltools", "htmlwidgets", "webshot", "stringr", "reactablefmtr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# 2. Retrieve data --------------------------------------------------------

data <- fread(here::here("comparison-data-replication.csv"),quote="", header=T)

column_transformer <- function(value) {
  string <- value
  if (str_detect(value, ":n:")) {
    string <- stringr::str_replace(value, ":n:", "<span><img alt='' src='./assets/icons/icon.png' style='width: 16.38px; height: 12.8px; margin-left: 0.00px; margin-top: 0.00px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);' title=''></i></span>")
  } else if (str_detect(value, ":y:")) {
    string <- stringr::str_replace(value, ":y:", "<span><img alt='' src='./assets/icons/62fc3b327bf0d9337241e112_check.png' style='width: 16.38px; height: 12.8px; margin-left: 0.00px; margin-top: 0.00px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);' title=''></i></span>")
  } else if (str_detect(value, ":u:")) {
    string <- stringr::str_replace(value, ":u:", "<span><img alt='' src='./assets/icons/62fc3b3276df8460a3e8d91b_output-onlinepngtools.png' style='width: 20.46px; height: 16.00px; margin-left: 0.00px; margin-top: 0.00px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);' title=''></i></span>")
  # } else if (!is.na(as.numeric(value))) {
  #   span(class = "number", value)
  }
  markdown::mark(string)
}

tbl <- reactable(data, 
                 pagination = FALSE,
                 borderless=T,
                 columnGroups = list(
                   #colGroup(name = "", columns = c("item"), sticky = "left"),
                   colGroup(name = "Open-Source", columns = c("Debezium", "Flink", "Airbyte","Estuary")),
                   colGroup(name = "Cloud Vendor Native Services", columns = c("AWS", "GCP")),
                   colGroup(name = "SAAS Vendors", columns = c("Qlik", "Fivetran","Arcion", "Decodable", "Striim", "StreamSets","Upsolver","Hevo"))
                 ),
                 defaultColDef = colDef(
                   vAlign = "center",
                   headerVAlign = "bottom",
                   class = "cell",
                   headerClass = "header"
                 ),
          columns = list(
            item = colDef(
              html = TRUE,
              name = "",
              align = "left",
              #resizable = TRUE,
              cell = function(value, index) {
                # this is ugly but will fix later
                title <- column_transformer(paste0(value, data[index, "description"][[1]]))
                title <- as.character(div(class = "item-content-left", HTML(title)))
                if (data[index, "is_advanced"][[1]]) {
                  advanced_tag <- div(class = "item-content-right", span(class = "tag", "Advanced"))
                  title <- paste0(title, tagList(advanced_tag))
                }
                title <- paste0("<div class = 'item-wrapper'>", title, "</div>")
                title
              },
              minWidth = 280
            ),
            `Debezium` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='highlight-tag'>Best open-source</div><div class='column-title'>Debezium</div></div>" #<img alt='' src='https://debezium.io/assets/images/color_black_debezium_type_600px.svg#svgView(viewBox(0, 0, 600, 130))' />
            ),            
            `Flink` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='highlight-tag'>Best open-source</div><div class='column-title'><img alt='' src='https://flink.apache.org/img/logo/png/1000/flink_squirrel_1000.png' style='width: 32.0px; height: 32.0px'><p style='padding-top: 3px;'>Flink CDC</p></div></div>"
            ),
            `Airbyte` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='https://assets.website-files.com/605e01bc25f7e19a82e74788/624d9c4a375a55100be6b257_Airbyte_logo_color_dark.svg#svgView(viewBox(-20, -50, 500, 200))' style='width: 83.85px; height: 33.54px'></div></div>"
            ),
            `Estuary` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='https://docs.estuary.dev/img/estuary-new.png' style='width: 32.0px; height: 32.0px'><p>Estuary</p></div></div>"
            ),            
            `AWS` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg' style='width: 48.38px; height: 36.80px'><p>DMS</p></div></div>"
            ),
            # `Azure` = colDef(
            #   html=TRUE,
            #   align = "center",
            #   cell = function(value) column_transformer(value),
            #   name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='https://upload.wikimedia.org/wikipedia/commons/a/a8/Microsoft_Azure_Logo.svg' style='width: 64.50px; height: 49.06px'><p>Data Factory</p></div></div>"
            # ),
            `GCP` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='https://brandeps.com/logo-download/G/Google-Cloud-logo-vector-01.svg' style='width: 48.38px; height: 36.80px'><p>GCP Datastream</p></div></div>"
            ),            
            `Qlik` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='https://upload.wikimedia.org/wikipedia/commons/3/32/Qlik_Logo.svg' style='width: 56.09px; height: 16.43px'><p>Replicate</p></div></div>"
            ),
            `Fivetran` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='https://assets-global.website-files.com/6130fa1501794ed4d11867ba/63d9599008ad50523f8ce26a_logo.svg' style='width: 80.63px; height: 22.40px'></div></div>"
            ),
            `Arcion` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='highlight-tag''>Best commercial</div><div class='column-title'><img alt='' src='https://assets.website-files.com/60ec496582f5cfe61dfe9c82/630b6bf7da07e33466d680f2_arcion-logo.svg' style='width: 77.40px; height: 15.56px'></div></div>"
            ),
            `Decodable` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='./assets/images/decodable.svg' style='width: 83.59px; height: 12.61px'></div></div>"
            ),
            `Striim` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='./assets/images/striim.jpg' style='width: 59.97px; height: 22.9px'></div></div>"
            ),
            `StreamSets` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='https://streamsets.b-cdn.net/wp-content/uploads/StreamSets-softwareAG-full-color-crop.svg' style='width: 83.85px; height: 23.66px'></div></div>"
            ),
            `Upsolver` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='./assets/images/upsolver.svg' style='width: 83.85px; height: 19.97px'></div></div>"
              
            ),
            `Hevo` = colDef(
              html=TRUE,
              align = "center",
              cell = function(value) column_transformer(value),
              class = "border-left",
              minWidth = 90,
              name = "<div class='header-wrapper'><div class='column-title'><img alt='' src='https://lever-client-logos.s3.us-west-2.amazonaws.com/3d73b5a9-c725-424d-962c-495d3d85c72f-1684919086376.png' style='width: 63.75px; height: 21.88px'></div></div>"
            ),
            description = colDef(show = FALSE),
            is_advanced = colDef(show = FALSE)
          ),
          highlight = F,
          theme = reactableTheme(
            #highlightColor = "#f3fafb",
            #borderColor = "hsl(0, 0%, 93%)",
            #padding = "2px",
            headerStyle = list(borderColor = "hsl(0, 0%, 90%)"),
            # Vertically center cells
            cellStyle = list(display = "flex", flexDirection = "column", justifyContent = "center")
          ),
          defaultExpanded = T,
          rowStyle = function(index) {
            if (index %in% c(2:11, 17:22, 26:27, 31:37)) list(backgroundColor = "rgb(247, 246, 235)")
            else if (index %in% c(13:15, 24, 29, 39:51)) list(backgroundColor = "rgb(237, 241, 246)")
          },
          sortable = F,
          class = "comparison-tbl")

#Make sure the locale is set to English
Sys.setlocale("LC_TIME", "C")

tbl <- div(class = "comparison",
    div(class = "comparison-header", id = 'header01',  tags$br(),
        h2(class = "comparison-title", "Feature comparison CDC data replication services"),
        paste0("Date of comparison: ", format(Sys.Date(), "%B")," 2023")
    ),
    tbl
)

tbl <- browsable(
  tagList(list(
    tags$head(
      tags$link(href = "https://fonts.googleapis.com/css?family=Karla:400,700|Fira+Mono&display=fallback", rel = "stylesheet"),
      tags$link(rel = "stylesheet", type = "text/css", href = "./assets/styles/styles.css")
    ),
    tbl
  ))
)

# Saving ------------------------------------------------------------------
html_file <- "www/table.html"
save_html(tbl, file = html_file, libdir = "lib")

Sys.setenv(OPENSSL_CONF="/dev/null")
webshot::webshot(url = html_file, file = "www/assets/images/img.png", delay = 0.1, vwidth = 2000)
