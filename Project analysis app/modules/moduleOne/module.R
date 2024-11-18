moduleOne <- list(
  
  "ui" = fluidPage(
    tags$head(tags$script(jsOptions)),
    flowLayout(
      pickerInput(
        inputId = "group", 
        label = "Which group(s)?", 
        choices = unique(observations$Group),
        selected = unique(observations$Group), 
        multiple = T,
        width = "200px",
        options = list(
          `actions-box` = TRUE,
          `deselect-all-text` = "None",
          `select-all-text` = "All",
          `none-selected-text` = "zero",
          `live-search`=TRUE
        )
      ),
      pickerInput(
        inputId = "plotFactor", 
        label = "Plot which factor?",
        choices = c("Genotype", "Group", "Rep"),
        selected = "Genotype",
        width = "200px",
        options = list(`live-search`=TRUE)
      )
    ),
    plotlyOutput("plot"),
    h4("We can use a t-test to test how likely it is that observed differences in A, H, or V are due to random chance."),
    flowLayout(
      pickerInput(
        "tTestLevels",
        "Which levels of Genotype do you want to compare?",
        choices = unique(observations$Genotype),
        multiple = T,
        selected = str_sort(unique(observations$Genotype), numeric = T)[1:2],
        options =  list("max-options" = 2),
        width = "200px"
      ),
      pickerInput(
        "tTestFeature",
        "Which feature you want to compare?",
        choices = str_sort(unique(observations$Class), numeric = T),
        width = "200px"
      ),
    ),
    verbatimTextOutput("tTest")
  ),
  
  "server" = function(input, output, session){
    
    output$plot <- renderPlotly({
      groupsName <- ifelse(
        length(input$group) == length(unique(observations$Group)),
        "All groups",
        paste0("Group",
          ifelse(length(input$group) > 1, "s ", " "),
          paste(input$group, collapse = ", ")
        )
      )
      observations %>%
        filter(Group %in% input$group) %>%
        plot_ly(
          x = ~get(input$plotFactor),
          y = ~Value,
          color = ~Class,
          hovertext = ~Student_name,
          type = "box"
          # boxpoints = "all"
        ) %>%
        layout(
          title = groupsName,
          xaxis = list(
            title = input$plotFactor,
            categoryorder = "array",
            categoryarray = str_sort(unique(observations[[input$plotFactor]]), numeric = T)
          ),
          legend = list(title = "Class"), 
          boxmode = "group"
        )
    })
    
    observeEvent(c(input$plotFactor, input$group), {
      updatePickerInput(
        session = session,
        inputId = "tTestLevels",
        label = paste0("Which levels of ", input$plotFactor, " do you want to compare?"),
        choices = observations %>% 
          filter(Group %in% input$group) %>%
          {str_sort(unique(.[[input$plotFactor]]), numeric = T)},
        selected = observations %>% 
          filter(Group %in% input$group) %>%
          {str_sort(unique(.[[input$plotFactor]]), numeric = T)[1:2]}
      )
    })
    
    output$tTest <- renderPrint({
      tTestLevels <- rep(input$tTestLevels, 2)[1:2]
      tTestData <- observations %>%
        filter(
          Group %in% input$group,
          get(input$plotFactor) %in% input$tTestLevels,
          Class == input$tTestFeature
        ) %>%
        select(input$plotFactor, Value)
      x <- filter(tTestData, get(input$plotFactor) == tTestLevels[1])$Value
      y <- filter(tTestData, get(input$plotFactor) == tTestLevels[2])$Value
      validate(need(length(x) > 1 & length(y) > 1, "Not enough data to perform t-test."))
      t.test(x, y)
    })
    
  }

)