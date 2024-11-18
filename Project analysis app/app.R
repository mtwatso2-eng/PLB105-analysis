source("global.R")

ui <- navbarPage(id = "tabs", collapsible = TRUE, title = "PLB105 experiment",
  modulePanel("Data analysis helper", value = "moduleOne"),
  reloadWarning,
  tags$head(tags$link(rel="shortcut icon", href=""))
)
  
server <- function(input, output, session) {
  
  sapply(list.files(path = "modules"), function(module){
    get(module)$server(input, output, session)
  })
  
}

shinyApp(ui = ui, server = server)