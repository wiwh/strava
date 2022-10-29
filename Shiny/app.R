library(tidyverse)
require(ggplot2)
require(wesanderson)
require(bslib)
require(DT)
require(shinyjs)
library(zoo)

# if(!("data_load" %in% ls())) data_load <- read_csv("../data/all_activities_df.csv")
data_load$activity_id <- as.factor(data_load$activity_id)

activity_id <- unique(data_load$activity_id)

data_maxkm <- data_load %>% group_by(activity_id) %>% summarise_all(max)

data_mean <- data_load %>%
  group_by(activity_id) %>% 
  select(activity_id, watts)
data_mean <- data_mean %>% group_by(activity_id) %>% summarise_all(mean, na.rm = T)
data_mean <- data_mean[(!is.nan(data_mean$watts)), ]


data_maxspd <- data_load %>% group_by(activity_id) %>% summarise_all(max)
data_maxspd <- data_maxspd[data_maxspd$distance > 15000, ]

# data_load[data_load$activity_id == activity_id[555],]$watts
# 
# data_load <- data_load %>% replace_na(list(watts = 0, heartrate = 0))
# 
# data_filter <- data_load %>% group_by(activity_id) %>% summarise_all(max)
# 
# pwr <- rep(0, length = max(data_filter$time))
# 
# activity_id_watts <- activity_id[data_filter$watts > 0]
# 
# for (i in seq_along(activity_id_watts)){
#   data_test <- data_load %>%
#     filter(activity_id == activity_id_watts[i]) %>% 
#     select(watts)
#   
#   seq_along(data_test$watts)
#   
#   pwr[seq_along(data_test$watts)]
#   
#   
#   for (j in seq_along(data_test$watts)){
#     print(paste(i, j))
#     verif <- max(rollmean(x = data_test$watts, k = j))
#     if (verif > pwr[j]) pwr[j] <-  verif
#   }
#   
#   
# }
# 
# 

  



library(shiny)

ui <- navbarPage("STRAVA STATS", selected = "Top activité",
                 theme = bs_theme(version = 4, bootswatch = "minty"),
                 useShinyjs(),
                 tabPanel("Top activité", 
                  fluidRow(
                    column(4,
                           selectInput(inputId = "actchoice",
                                       label = "Choisir STAT activité",
                                       choices = c("Plus longue",
                                                   "Plus puissante moyenne",
                                                   "Plus vite moyenne, min 15km"), 
                                       selected = "Plus longue"),
                           ),
                    column(2,
                           selectInput(inputId = "coulmin",
                                       label = "Choisir couleur min",
                                       choices = c("Bleu" = "blue",
                                                   "Rouge" = "red",
                                                   "Jaune" = "yellow",
                                                   "Orange" = "orange",
                                                   "Pourpre" = "purple",
                                                   "Vert" = "green",
                                                   "Cyan" = "cyan"), 
                                       selected = "blue"),
                    ),
                    column(2,
                           selectInput(inputId = "coulmax",
                                       label = "Choisir couleur max",
                                       choices = c("Bleu" = "blue",
                                                   "Rouge" = "red",
                                                   "Jaune" = "yellow",
                                                   "Orange" = "orange",
                                                   "Pourpre" = "purple",
                                                   "Vert" = "green",
                                                   "Cyan" = "cyan"),
                                       selected = "yellow"),
                    ),
                    column(2,
                           selectInput(inputId = "coulfc",
                                       label = "Choisir couleur FC",
                                       choices = c("Bleu" = "blue",
                                                   "Rouge" = "red",
                                                   "Jaune" = "yellow",
                                                   "Orange" = "orange",
                                                   "Pourpre" = "purple",
                                                   "Vert" = "green",
                                                   "Cyan" = "cyan"),
                                       selected = "red"),
                    ),
                  ),
                  fluidRow(
                    column(2,
                           selectInput(inputId = "statchoice1",
                                       label = "Choisir stat",
                                       choices = c("Puissance" = "watts",
                                                   "FC" = "heartrate"), 
                                       selected = "watts"),
                    ),
                    column(2,
                           selectInput(inputId = "statchoice2",
                                       label = "Choisir stat 2",
                                       choices = c("Puissance" = "watts",
                                                   "FC" = "heartrate"), 
                                       selected = "heartrate"),
                    ),
                    column(6, sliderInput(inputId = "rolling", 
                                          label = "Rolling",
                                          min = 10, 
                                          max = 500, value = 100, step = 10)
                           ),
                  ),
                  fluidRow(
                 
                           plotOutput(outputId = "graph"),
                           column(3,
                                  tableOutput(outputId = "table"),
                           ),
                  ),
                    ),
                 tabPanel("Top", 
                          fluidRow(
                            column(4, "This is something"
   
                            ),
                          ),

                 )
               
               


)



server <- function(input, output) {


  
  # Generate a plot of the requested variable against mpg ----
  # and only exclude outliers if requested
  output$graph <- renderPlot({
    
        
    if (input$actchoice == "Plus longue"){
      num_act <- data_maxkm$activity_id[which.max(data_maxkm$distance)]
    } 
    
    if (input$actchoice == "Plus puissante moyenne"){
      
      num_act <- data_mean$activity_id[which.max(data_mean$watts)]
    }
    
    if (input$actchoice == "Plus vite moyenne, min 15km"){
     
      distance_tot <- data_maxspd$distance / 1000
      temps_heure <- data_maxspd$time / 3600
      vitesse_moy <- round(distance_tot / temps_heure, 2)
      
      num_act <- data_maxspd$activity_id[which.max(vitesse_moy)]
    }

        
        

      data <- data_load %>%
        filter(activity_id == num_act) %>% 
        select(watts, heartrate, velocity_smooth, distance, moving, time, altitude)
      
      data <- data %>% replace_na(list(watts = 0, heartrate = 0))
      
      
      data_rolled <- tibble(rollmean(data$watts,
                                     input$rolling, 
                                     align = "left"),
                            rollmean(data$heartrate, 
                                     input$rolling, 
                                     align = "left"),
                            data$time[-(1:(input$rolling - 1))]) 
      
      names(data_rolled) <- c("watts", "heartrate", "time")
      
      
      coeff <- (diff(range(data_rolled$watts)) / 
                      diff(range(data_rolled$heartrate)))
      int <- range(data_rolled$watts)[1] - coeff * range(data_rolled$heartrate)[1]
      

      
      ggplot(data = data_rolled, aes(x = time)) +
        geom_line(aes_string(y = input$statchoice1, 
                             colour = input$statchoice1)) +
        scale_colour_gradient(low = input$coulmin, high = input$coulmax, 
                              na.value = NA) +
        geom_line(aes_string(y = input$statchoice2), color = input$coulfc) +
        scale_y_continuous(
          
          # Features of the first axis
          name = "First Axis",
          
          # Add a second axis and specify its features
          sec.axis = sec_axis(~ (. - int)/coeff, name="Second Axis")
        ) +
        theme_bw()

  })
  
  output$table <- renderTable(rownames = TRUE, width = 450,
{
  if (input$actchoice == "Plus longue"){
    num_act <- data_maxkm$activity_id[which.max(data_maxkm$distance)]
  } 
  
  if (input$actchoice == "Plus puissante moyenne"){
    num_act <- data_mean$activity_id[which.max(data_mean$watts)]
  }
  
  if (input$actchoice == "Plus vite moyenne, min 15km"){

    distance_tot <- data_maxspd$distance / 1000
    temps_heure <- data_maxspd$time / 3600
    vitesse_moy <- round(distance_tot / temps_heure, 2)
    
    num_act <- data_maxspd$activity_id[which.max(vitesse_moy)]
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
  
  output$link <- renderUI(a(input$text, href = "https://shiny.rstudio.com"))
  
}
shinyApp(ui = ui, server = server)
