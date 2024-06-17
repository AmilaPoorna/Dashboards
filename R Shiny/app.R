#install.packages("shiny")
library(shiny)
#install.packages("shinydashboard")
library(shinydashboard)
library(dplyr)
library(lubridate)
#install.packages("ggplot2")
library(ggplot2)
#install.packages("DT")
library(DT)
#install.packages("zoo")
library(zoo)

data <- readRDS("data/data.rds")

custom_table_data <- data.frame(
  Variable = c("holiday", "temp", "rain_1h", "snow_1h", "clouds_all", "weather_main", "weather_description", "date_time", "traffic_volume"),
  Type = c("Categorical", "Continuous", "Continuous", "Continuous", "Integer", "Categorical", "Categorical", "Date", "Integer"),
  Description = c("US National holidays plus regional holiday, Minnesota State Fair", "Average temp in kelvin", "Amount in mm of rain that occurred in the hour", "Amount in mm of snow that occurred in the hour", "Percentage of cloud cover", "Short textual description of the current weather", "Longer textual description of the current weather", "Hour of the data collected in local CST time", "Hourly I-94 reported westbound traffic volume"),
  Units = c("-", "Kelvin", "mm", "mm", "%", "-", "-", "-", "-")
)

ui <- dashboardPage(
  dashboardHeader(title = "Traffic Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Dataset Description", tabName = "description", icon = icon("database"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
                box(
                  title = "Average Traffic Volume by Weather Type",
                  status = "primary",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  plotOutput("plot1"),
                  selectInput("holiday_selector", "Select Holiday Category:",choices = unique(data$holiday)),
                  p("Users can observe average traffic volume with respect to weather types for different holidays and non-holidays by using the selector.")
                ),
                box(
                  title = "Average Traffic Volume by Weather Description",
                  status = "primary",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  plotOutput("plot3"),
                  selectInput("weather_selector", "Select Weather Category:",choices = unique(data$weather_main)),
                  p("Users can observe average traffic volume with respect to weather descriptions for different weather types by using the selector.")
                )
              ),
              fluidRow(
                box(
                  title = "Traffic Volume over Time",
                  status = "primary",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  plotOutput("plot2"),
                  sliderInput("year_slider", "Select Time Period:", 
                              min = min(year(data$date_time)), 
                              max = max(year(data$date_time)), 
                              value = c(min(year(data$date_time)), max(year(data$date_time))), 
                              step = 1,
                              sep = ""),
                  p("Users can observe how monthly traffic volume change throughout a year or more by adjusting the slider. The slider helps users to identify trends and seasonal patterns efficiently.")
                ),
                box(
                  title = "Impact of Continuous Features on Traffic Volume",
                  status = "primary",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  plotOutput("plot4"),
                  selectInput("x_var", "Select Feature:",
                              choices = c("Temperature", "Rain", "Snow")),
                  sliderInput("cloud_slider", "Select Cloud Percentage:",
                              min = min(data$clouds_all), 
                              max = max(data$clouds_all), 
                              value = c(min(data$clouds_all), max(data$clouds_all)), 
                              step = 1),
                  p("Users can observe how hourly traffic volume change with each feature variable temperature measured in Kelvin, rain and snow measured in milimeters by using the selector. The selector changes x-axis which outputs a different plot for each option. Users can also observe how each plot change with cloud percentage by using the slider.")
                )
              )
      ),
      tabItem(tabName = "description",
              fluidRow(
                box(
                  title = "Dataset Information",
                  status = "primary",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  p("The dataset is about hourly Interstate 94 Westbound traffic volume, roughly midway between Minneapolis and St Paul, MN."),
                  p("The target variable of the dataset is traffic volume and the dataset contains hourly weather features and holidays for impacts on traffic volume."),
                  p("The dataset has no missing values but has duplicate records."),
                  p("Data relabelling and outlier removal is also done to the dataset while cleaning besides removing duplicate records.")
                )
              ),
              fluidRow(
                column(12,
                       p(HTML("<strong>The below table shows the variable descriptions.</strong>")),
                       br(),
                       dataTableOutput("custom_table"),
                       br()
                )
              ),
              fluidRow(
                box(
                  title = "Link to the Dataset",
                  status = "primary",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  shiny::a("https://archive.ics.uci.edu/dataset/492/metro+interstate+traffic+volume", href = "https://archive.ics.uci.edu/dataset/492/metro+interstate+traffic+volume")
                )
              )
      )
    )
  )
)

server <- function(input, output) {
  
  output$custom_table <- renderDataTable({
    datatable(custom_table_data, editable = FALSE)
  })
  
  data1 <- data.frame(
    Weather_Type = data$weather_main,
    Traffic_Volume = data$traffic_volume,
    holiday = data$holiday
  )
  
  traffic1 <- reactive({
    filtered_data <- data1
    
    if (!is.null(input$holiday_selector) && input$holiday_selector != "") {
      filtered_data <- filtered_data %>% filter(holiday == input$holiday_selector)
    }
    
    filtered_data %>%
      group_by(Weather_Type) %>%
      summarise(Avg_Traffic_Volume = mean(Traffic_Volume))
  })
  
  output$plot1 <- renderPlot({
    ggplot(traffic1(), aes(x = Weather_Type, y = Avg_Traffic_Volume)) +
      geom_bar(stat = "identity", fill = "skyblue") +
      labs(x = "Weather Type", y = "Average Traffic Volume") +
      theme_minimal() +
      theme(panel.grid.major = element_blank(),
            panel.grid.minor = element_blank())
  })
  
  data2 <- data.frame(
    Weather_Description = data$weather_description,
    Traffic_Volume = data$traffic_volume,
    weather = data$weather_main
  )
  
  traffic2 <- reactive({
    filtered_data <- data2
    
    if (!is.null(input$weather_selector) && input$weather_selector != "") {
      filtered_data <- filtered_data %>% filter(weather == input$weather_selector)
    }
    
    filtered_data %>%
      group_by(Weather_Description) %>%
      summarise(Avg_Traffic_Volume = mean(Traffic_Volume))
  })
  
  output$plot3 <- renderPlot({
    ggplot(traffic2(), aes(x = Weather_Description, y = Avg_Traffic_Volume)) +
      geom_bar(stat = "identity", fill = "skyblue") +
      labs(x = "Weather Description", y = "Average Traffic Volume") +
      theme_minimal() +
      theme(panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            axis.text.x = element_text(angle = 25, vjust = 0.75, hjust = 0.5))
  })
  
  output$plot2 <- renderPlot({
    monthly_traffic <- data %>%
      mutate(year_month = format(date_time, "%Y-%m")) %>%
      group_by(year_month) %>%
      summarise(Avg_Traffic_Volume = mean(traffic_volume))
    
    monthly_traffic$year_month <- as.yearmon(monthly_traffic$year_month)
    
    filtered_traffic <- monthly_traffic[as.numeric(format(monthly_traffic$year_month, "%Y")) %in% input$year_slider[1]:input$year_slider[2],]
    
    ggplot(filtered_traffic, aes(x = year_month, y = Avg_Traffic_Volume)) +
      geom_line() +
      labs(x = "Year-Month", y = "Average Traffic Volume") +
      theme_minimal()
  })
  
  data3 <- data.frame(
    Temperature = data$temp,
    Rain = data$rain_1h,
    Snow = data$snow_1h,
    Traffic_Volume = data$traffic_volume,
    clouds = data$clouds_all
  )
  
  output$plot4 <- renderPlot({
    filtered_data <- data3 %>%
      filter(clouds >= input$cloud_slider[1] & clouds <= input$cloud_slider[2])
    
    ggplot(filtered_data, aes_string(x = input$x_var, y = "Traffic_Volume")) +
      geom_point() +
      labs(x = input$x_var, y = "Traffic Volume") +
      ggtitle(paste("Traffic Volume vs", input$x_var)) +
      theme_minimal()
  })
  
}

shinyApp(ui = ui, server = server)