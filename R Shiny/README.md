# Metro Interstate Traffic Volume Dashboard

It is a Shiny web application designed to allow users to interactively view data. This project processes a metro interstate traffic volume dataset and displays them a user-friendly web interface.

## Features

- **Data Processing**: The `data.R` script generates the processed data and saves the results for use in the Shiny app.
- **Interactive UI**: The `app.R` script creates a Shiny web application with a dynamic user interface that allows users to select a category and view the corresponding data.
- **Real-time Updates**: The app provides real-time updates of the data based on user input.

## File Descriptions

- **data.R**: This script generates the processed data from `Metro_Interstate_Traffic_Volumne.csv`and saves the processed data in `data.rds`.
- **app.R**: This script defines the Shiny application. It loads the processed data from `data.rds` from data folder and sets up the user interface and server logic to display the data based on the selected category.

<br>

![Dashboard](https://github.com/AmilaPoorna/Dashboards/assets/173019371/00e827c8-89e1-4420-9d10-4ebd5fd86528)
Dashboard - 1

<br>

![Dashboard](https://github.com/AmilaPoorna/Dashboards/assets/173019371/c02fc2fe-cbd8-4157-bd0f-e50c5603c555)
Dashboard - 2

<br>

![Dataset Description](https://github.com/AmilaPoorna/Dashboards/assets/173019371/296d5069-2780-4ea8-911f-875bf4554025)
Dataset Description

## How to Run

1. **Prerequisites**: Ensure you have R and the required packages installed.
    ```R
    install.packages(c("dplyr", "lubridate", "shiny", "shinydashboard", "ggplot2", "DT", "zoo"))
    ```

2. **Clone the Repository**:
    ```sh
    git clone https://github.com/AmilaPoorna/Dashboards.git
    cd "R Shiny"
    ```

3. **Generate the Processed Data**:
    Run the `data.R` script to generate the processed data.

4. **Run the Shiny App**:
    Start the Shiny app by running the `app.R` script.
