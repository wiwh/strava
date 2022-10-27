library(tidyverse)
require(ggplot2)
require(wesanderson)
require(bslib)
require(DT)
require(shinyjs)

#data_load <- read_csv("../data/all_activities_df.csv")

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
                                       choices = c("Plus longue",
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
    
        
    if (input$actchoice == "Plus longue"){
      data_max <- data_load %>% group_by(activity_id) %>% summarise_all(max)
      num_act <- unique(data_load$activity_id)[which.max(data_max$distance)]
    } 
    
    if (input$actchoice == "Plus puissante moyenne"){
      data_mean <- data_load %>%
        group_by(activity_id) %>% 
        select(activity_id, watts)
      data_mean <- data_mean %>% group_by(activity_id) %>% summarise_all(mean, na.rm = T)
      data_mean <- data_mean[(!is.nan(data_mean$watts)), ]
      num_act <- data_mean$activity_id[which.max(data_mean$watts)]
    }
    
    if (input$actchoice == "Plus vite moyenne, min 15km"){
      data_max <- data_load %>% group_by(activity_id) %>% summarise_all(max)
      data_max <- data_max[data_max$distance > 15000, ]
      distance_tot <- data_max$distance / 1000
      temps_heure <- data_max$time / 3600
      vitesse_moy <- round(distance_tot / temps_heure, 2)
      
      num_act <- data_max$activity_id[which.max(vitesse_moy)]
    }

        
        

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
  if (input$actchoice == "Plus longue"){
    data_max <- data_load %>% group_by(activity_id) %>% summarise_all(max)
    num_act <- data_max$activity_id[which.max(data_max$distance)]
  } 
  
  if (input$actchoice == "Plus puissante moyenne"){
    data_mean <- data_load %>%
      group_by(activity_id) %>% 
      select(activity_id, watts)
    data_mean <- data_mean %>% group_by(activity_id) %>% summarise_all(mean, na.rm = T)
    data_mean <- data_mean[(!is.nan(data_mean$watts)), ]
    num_act <- data_mean$activity_id[which.max(data_mean$watts)]
  }
  
  if (input$actchoice == "Plus vite moyenne, min 15km"){
    data_max <- data_load %>% group_by(activity_id) %>% summarise_all(max)
    data_max <- data_max[data_max$distance > 15000, ]
    distance_tot <- data_max$distance / 1000
    temps_heure <- data_max$time / 3600
    vitesse_moy <- round(distance_tot / temps_heure, 2)
    
    num_act <- data_max$activity_id[which.max(vitesse_moy)]
  }
  
  data <- data_load %>%
    filter(activity_id == num_act) %>% 
    select(watts, heartrate, velocity_smooth, distance, moving, time, altitude)
  
  
  distance_tot <- diff(range(data$distance)) / 1000
  temps_heure <- diff(range(data$time)) / 3600
  vitesse_moy <- round(distance_tot / temps_heure, 2)
  
  vitesse_inst <- round((diff(data$distance) / 1000) / 
                          (diff(data$time) / 3600), 2)
  puissance_moy <- round(mean(data$watts, na.rm = T), 2)
  

  
  
  mat <- matrix(c(paste(distance_tot, "km"),
                  paste(floor(temps_heure),"h", 
                        round((temps_heure - floor(temps_heure)) * 60, 0), "min"),
                  paste(vitesse_moy, "km/h"),
                  paste(max(vitesse_inst), "km/h"),
                  paste(puissance_moy, "watts"),
                  paste(num_act)),
                nrow = 6, byrow = T)
  
  df <- data.frame(mat,
                   row.names = c("Distance totale",
                                 "Durée totale",
                                 "Vitesse moyenne", 
                                 "Vitesse max",
                                 "Puissance moyenne",
                                 "Numéro d'activité"))
    
    noms <- c("Sommaire")
    names(df) <- noms
    df
    
                                
})
  
}
shinyApp(ui = ui, server = server)
