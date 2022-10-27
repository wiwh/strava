require(ggplot2)
require(wesanderson)
require(bslib)
require(DT)
require(shinyjs)

# data_load <- read_csv("all_activities_df.csv")

data_load$activity_id <- as.factor(data_load$activity_id)

activity_id <- unique(data_load$activity_id)


library(shiny)

ui <- navbarPage("vitesse", selected = "vitesse",
                 theme = bs_theme(version = 4, bootswatch = "minty"),
                 useShinyjs(),
                 tabPanel("vitesse", 
                  fluidRow(
                    column(4,
                           selectInput(inputId = "actchoice",
                                       label = "Choisir STAT activité",
                                       choices = c("Plus longue" = "pluslongue",
                                                   "Plus puissante moyenne",
                                                   "Plus vite moyenne, min 15km"), 
                                       selected = "Plus longue"),
                    ),
                  ),
                  fluidRow(

                    column(2,
                           selectInput(inputId = "statchoice1",
                                       label = "Choisir stat",
                                       choices = c("Puissance" = "watts",
                                                   "FC" = "heartrate",
                                                   "Distance" = "distance"), 
                                       selected = "watts"),
                    ),
                    column(2,
                           selectInput(inputId = "statchoice2",
                                       label = "Choisir stat 2",
                                       choices = c("Puissance" = "watts",
                                                   "FC" = "heartrate",
                                                   "Distance" = "distance"), 
                                       selected = "heartrate"),
                    ),
                  ),
                  fluidRow(
                 
                           plotOutput(outputId = "graph"),
                           column(3,
                                  tableOutput(outputId = "table"),
                           ),
    
                  )
               )


)



server <- function(input, output) {


  
  # Generate a plot of the requested variable against mpg ----
  # and only exclude outliers if requested
  output$graph <- renderPlot({
    
        
        
        data_max <- data_load %>% group_by(activity_id) %>% summarise_all(max)
        
        num_act <- unique(data_load$activity_id)[which.max(data_max$distance)]
        
        

      data <- data_load %>%
        filter(activity_id == num_act) %>% 
        select(watts, heartrate, velocity_smooth, distance, moving, time, altitude)
      
      
      
      
      
      ggplot(data = data, aes(x = time)) +
        geom_line(aes_string(y = input$statchoice1)) +
        geom_line(aes_string(y = input$statchoice2), color = "red") +
        theme_bw()

  })
  
  output$table <- renderTable(rownames = TRUE, width = 450,
                              {
                                data_max <- data_load %>% group_by(activity_id) %>% summarise_all(max)
                                
                                num_act <- unique(data_load$activity_id)[which.max(data_max$distance)]
                                
                                
                                
                                data <- data_load %>%
                                  filter(activity_id == num_act) %>% 
                                  select(watts, heartrate, velocity_smooth, distance, moving, time, altitude)
                                
  
  distance_tot <- diff(range(data$distance)) / 1000
  temps_heure <- diff(range(data$time)) / 3600
  vitesse_moy <- round(distance_tot / temps_heure, 2)
  
  vitesse_inst <- round((diff(data$distance) / 1000) / 
                          (diff(data$time) / 3600), 2)
  
  

    mat <- matrix(c(paste(distance_tot, "km"),
                    paste(vitesse_moy, "km/h"),
                    paste(max(vitesse_inst), "km/h")),
                  nrow = 3, byrow = T)

    df <- data.frame(mat,
                     row.names = c("Distance totale", 
                                   "Vitesse moyenne", 
                                   "Vitesse max"))
    
    noms <- c("Sommaire")
    names(df) <- noms
    df
    
                                
})
  
}
shinyApp(ui = ui, server = server)
