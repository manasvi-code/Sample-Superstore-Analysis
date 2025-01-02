# Load necessary libraries
library(shiny)
library(ggplot2)
library(dplyr)
library(randomForest)
library(readxl)
library(plotly)
library(shinythemes)
library(DT)
library(shinyjs)
library(httr)
library(fontawesome)

# Configure Google OAuth credentials
google_client_id <- "695491232934-2qj7ofvi87ggm6dmcst86q3ublnplmpj.apps.googleusercontent.com"
google_client_secret <- "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"
oauth_endpoints("google")

# Define scopes
scopes <- c(
  "https://www.googleapis.com/auth/userinfo.profile",
  "https://www.googleapis.com/auth/userinfo.email"
)

loginUI <- function() {
  div(
    style = "display: flex; justify-content: center; align-items: center; height: 100vh; 
             background-image: url('https://static.vecteezy.com/system/resources/previews/025/120/727/non_2x/a-modern-retail-store-with-abundant-merchandise-generated-by-ai-photo.jpg');
             background-size: cover; 
             background-position: center; 
             background-repeat: no-repeat; 
             color: white; 
             font-family: 'Arial', sans-serif;",
    div(
      style = "background: rgba(0, 0, 0, 0.7); 
               padding: 2rem; 
               border-radius: 15px; 
               box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2); 
               text-align: center; 
               max-width: 500px; 
               width: 90%;",
      h1("Sample Superstore Analytics", 
         style = "font-size: 2.5rem; margin-bottom: 0.5rem;"),
      p("Gain insights into sales, trends, and customer data.", 
        style = "font-size: 1.2rem; margin-bottom: 1.5rem; color: #ddd;"),
      hr(style = "border-top: 1px solid #555; margin-bottom: 1.5rem;"),
      actionButton("login_btn", "Login with Google", 
                   icon = icon("google"), 
                   style = "background-color: #4285F4; 
                            color: white; 
                            border: none; 
                            padding: 0.8rem 1.5rem; 
                            border-radius: 5px; 
                            font-size: 1rem; 
                            font-weight: bold; 
                            cursor: pointer;"),
      tags$script(HTML('
        document.getElementById("login_btn").addEventListener("mouseover", function() {
          this.style.backgroundColor = "#357ae8";
        });
        document.getElementById("login_btn").addEventListener("mouseout", function() {
          this.style.backgroundColor = "#4285F4";
        });
      '))
    )
  )
}

# Main UI function (same as before, keeping your existing UI)
mainUI <- function() {
  fluidPage(
    theme = shinytheme("flatly"),
    useShinyjs(),
    
    # Your existing CSS styles here...
    # Include custom CSS for styling
    tags$head(
      tags$style(HTML("
    :root {
      --primary-color: #4A90E2;
      --secondary-color: #FF6B6B;
      --background-gradient: linear-gradient(135deg, #e6f2ff, #ffffff);
    }

    body {
      font-family: 'Inter', 'Roboto', sans-serif;
      background: var(--background-gradient);
      color: #2c3e50;
      line-height: 1.6;
    }

    /* Glassmorphic Design Principles */
    .card {
      background: rgba(255, 255, 255, 0.85);
      backdrop-filter: blur(15px);
      border: 1px solid rgba(255, 255, 255, 0.2);
      border-radius: 16px;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
      transition: all 0.3s ease;
    }

    .card:hover {
      transform: translateY(-5px);
      box-shadow: 0 15px 40px rgba(0, 0, 0, 0.1);
    }

    /* Enhanced Navigation */
    .navbar {
      background: rgba(74, 144, 226, 0.9) !important;
      backdrop-filter: blur(10px);
      border: none;
      box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
    }

    .navbar-brand {
      font-weight: 700;
      color: white !important;
      letter-spacing: -0.5px;
    }

    /* Refined Typography */
    h1, h2, h3 {
      font-weight: 700;
      color: var(--primary-color);
      margin-bottom: 1.5rem;
      background: linear-gradient(45deg, var(--primary-color), var(--secondary-color));
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }

    /* Advanced Button Styles */
    .btn-primary {
      background: linear-gradient(45deg, var(--primary-color), var(--secondary-color));
      border: none;
      border-radius: 50px;
      padding: 10px 25px;
      font-weight: 600;
      letter-spacing: 0.5px;
      transition: all 0.3s ease;
      box-shadow: 0 5px 15px rgba(74, 144, 226, 0.3);
    }

    .btn-primary:hover {
      transform: translateY(-3px);
      box-shadow: 0 8px 25px rgba(74, 144, 226, 0.4);
    }

    /* Enhanced Data Table */
    .dataTables_wrapper {
      background: rgba(255, 255, 255, 0.9);
      border-radius: 16px;
      padding: 15px;
      box-shadow: 0 8px 30px rgba(0, 0, 0, 0.05);
    }

    /* Responsive Animations */
    @keyframes fadeInUp {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .animated-section {
      animation: fadeInUp 0.6s ease-out;
    }

    /* Enhanced Statistics Boxes */
    .stats-box {
      background: rgba(255, 255, 255, 0.8);
      border-radius: 16px;
      padding: 20px;
      text-align: center;
      transition: all 0.3s ease;
      box-shadow: 0 6px 20px rgba(0, 0, 0, 0.05);
    }

    .stats-box:hover {
      transform: scale(1.05);
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    }

    .stats-box h4 {
      color: var(--primary-color);
      margin-bottom: 10px;
    }

    .stats-box p {
      font-size: 2em;
      font-weight: 700;
      color: var(--secondary-color);
    }
  "))
    ),
    
    navbarPage(
      title = div(
        img(src = "/api/placeholder/50/50", height = "30px", style = "margin-right: 10px;"),
        "Sample Superstore Analytics"
      ),
      
      # Existing header with user info and logout
      header = div(
        style = "position: absolute; right: 1em; top: 0.5em; display: flex; align-items: center;",
        textOutput("user_welcome", inline = TRUE),
        actionButton("logout", "Logout", class = "btn btn-danger ml-2")
      ),
      
      # Home Tab
      tabPanel(
        "Home",
        icon = icon("home"),
        
        # Sample Superstore Information
        div(
          class = "info-section",
          h3("About Sample Superstore", style = "color: var(--primary-color)"),
          p("Sample Superstore is a fictional dataset that represents a company's sales performance across various regions, 
          product categories, and customer segments. It provides detailed information about sales, profit, discounts, and 
          other factors influencing business performance."),
          p("The dataset includes metrics such as:",
            tags$ul(
              tags$li("Sales: Total revenue generated from products."),
              tags$li("Profit: Net earnings after deducting expenses."),
              tags$li("Discount: Discounts offered to customers."),
              tags$li("Category & Sub-Category: Classification of products sold."),
              tags$li("State: Regional performance data.")
            )
          ),
          p("By uploading the dataset, users can visualize insights, analyze trends, and even predict performance metrics using machine learning.")
        ),
        
        # File Upload Section
        div(
          class = "upload-section",
          h3("Upload Your Data", style = "color: var(--primary-color)"),
          fileInput("file", label = "Choose an Excel File", accept = c(".xlsx", ".xls")),
          tags$small("Required columns: Sales, Profit, Discount, State, Category, Sub-Category"),
          uiOutput("uploadStatus"),
          actionButton("analyzeBtn", "Analyze", class = "btn-primary", disabled = "disabled")
        ),
        
        # Dataset Summary Section
        h2("Dataset Overview"),
        uiOutput("statsBoxes")
      ),
      
      tabPanel(
        "Analysis",
        icon = icon("chart-bar"),
        fluidRow(
          column(4,
                 wellPanel(
                   h4("Visualization Parameters"),
                   uiOutput("xVarSelect"),
                   uiOutput("yVarSelect"),
                   h4("Sales Filter"),
                   uiOutput("salesRangeInput"),
                   actionButton("run_model", "Predict Profit", class = "btn-primary")
                 )
          ),
          column(8,
                 tabsetPanel(
                   tabPanel("Dataset", DT::dataTableOutput("data_table")),
                   tabPanel("Interactive Plot", plotlyOutput("plot")),
                   tabPanel("Model Predictions", verbatimTextOutput("model_result")),
                   tabPanel("Download", 
                            downloadButton("downloadData", "Export Filtered Data", class = "btn-primary"))
                 )
          )
        )
      )
    )
  )
}

# Define UI
ui <- function(request) {
  tagList(
    useShinyjs(),
    uiOutput("page")
  )
}

# Define server
server <- function(input, output, session) {
  
  # Authentication status and user info
  auth_status <- reactiveVal(FALSE)
  user_info <- reactiveVal(NULL)
  
  # Handle Google login
  observeEvent(input$login_btn, {
    tryCatch({
      # Create OAuth app
      myapp <- oauth_app("google", key = google_client_id, secret = google_client_secret)
      
      # Get token
      goog_token <- oauth2.0_token(oauth_endpoints("google"), myapp, 
                                   scope = scopes, cache = FALSE)
      
      # Get user information
      user_info_response <- GET("https://www.googleapis.com/oauth2/v2/userinfo", 
                                config(token = goog_token))
      user_data <- content(user_info_response)
      
      # Update reactive values
      user_info(user_data)
      auth_status(TRUE)
      
    }, error = function(e) {
      showNotification(paste("Login failed:", e$message), type = "error")
    })
  })
  
  # Render appropriate page based on authentication
  output$page <- renderUI({
    if (!auth_status()) {
      loginUI()
    } else {
      mainUI()
    }
  })
  
  # Display user welcome message
  output$user_welcome <- renderText({
    req(user_info())
    paste("Welcome,", user_info()$given_name, "!")
  })
  
  # Handle logout
  observeEvent(input$logout, {
    auth_status(FALSE)
    user_info(NULL)
    session$reload()
  })
  
  # Your existing reactive data handling
  data <- reactiveVal()
  
  # Main application logic
  observe({
    req(auth_status())  # Only run when authenticated
    
    # File upload handling
    observeEvent(input$file, {
      tryCatch({
        df <- read_excel(input$file$datapath)
        required_cols <- c("Sales", "Profit", "Discount", "State", "Category", "Sub-Category")
        
        if (!all(required_cols %in% colnames(df))) {
          stop("Missing required columns.")
        }
        
        if (!is.numeric(df$Sales) || !is.numeric(df$Profit) || !is.numeric(df$Discount)) {
          stop("Sales, Profit, and Discount must be numeric.")
        }
        
        data(df)
        output$uploadStatus <- renderUI({
          div(style = "color: green;", "File uploaded successfully!")
        })
        shinyjs::enable("analyzeBtn")
        
      }, error = function(e) {
        output$uploadStatus <- renderUI({
          div(style = "color: red;", paste("Error:", e$message))
        })
        shinyjs::disable("analyzeBtn")
      })
    })
    
    # Your existing UI elements and reactive expressions...
    output$xVarSelect <- renderUI({
      req(data())
      selectInput("xvar", "X Variable:", choices = colnames(data()), selected = "Sales")
    })
    
    output$yVarSelect <- renderUI({
      req(data())
      selectInput("yvar", "Y Variable:", choices = colnames(data()), selected = "Profit")
    })
    
    output$salesRangeInput <- renderUI({
      req(data())
      sliderInput("salesRange", "Sales Range:",
                  min = min(data()$Sales, na.rm = TRUE),
                  max = max(data()$Sales, na.rm = TRUE),
                  value = c(min(data()$Sales, na.rm = TRUE), max(data()$Sales, na.rm = TRUE)))
    })
    
    # Stats Boxes
    output$statsBoxes <- renderUI({
      req(data())
      fluidRow(
        column(3, div(class = "stats-box", p(length(unique(data()$State)), "States"))),
        column(3, div(class = "stats-box", p(length(unique(data()$Category)), "Categories"))),
        column(3, div(class = "stats-box", p(length(unique(data()$`Sub-Category`)), "Sub-Categories"))),
        column(3, div(class = "stats-box", p(nrow(data()), "Total Records")))
      )
    })
    
    # Filtered Data
    filteredData <- reactive({
      req(data(), input$salesRange)
      data() %>% filter(Sales >= input$salesRange[1], Sales <= input$salesRange[2])
    })
    
    # DataTable
    output$data_table <- DT::renderDataTable({
      req(filteredData())
      DT::datatable(filteredData(), options = list(pageLength = 10, scrollX = TRUE))
    })
    
    # Plot
    output$plot <- renderPlotly({
      req(filteredData(), input$xvar, input$yvar)
      plot <- ggplot(filteredData(), aes_string(x = input$xvar, y = input$yvar)) +
        geom_point(aes(color = ..y..), size = 4, alpha = 0.8) +
        scale_color_gradient(low = "#4ECDC4", high = "#FF7F50") +
        theme_minimal()
      ggplotly(plot)
    })
    
    # Model
    observeEvent(input$run_model, {
      
      req(data())
      df_ml <- data() %>% select(Sales, Discount, Profit)
      model <- randomForest(Profit ~ Sales + Discount, data = df_ml, ntree = 100)
      predicted_profit <- predict(model, newdata = df_ml)
      
      output$model_result <- renderPrint({
        cat("First 10 Predicted Profit Values:\n")
        print(head(predicted_profit, 10))
      })
    })
    
    # Download Handler
    output$downloadData <- downloadHandler(
      filename = function() {
        paste("filtered-data-", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        write.csv(filteredData(), file, row.names = FALSE)
      }
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)