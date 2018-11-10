library(shiny)
library(tidyverse)
library(shinydashboard)
library(shinyAce)

# tabs ui
source("./tabs/tab_data_info.R")
source("./tabs/tab_visualizations.R")
source("./tabs/tab_train.R")

# functions
source("./compute_metrics.R")

# table with description of dataset
vars = data.frame(
  Variable = c("status", "seniority", "home", "time", "age", "marital", "records", "job", "expenses", "income", "assets", "debt", "amount", "price", "savings", "finrat"),
  Description = c("credit status", "job seniority (years)", "type of home ownership", "time of requested loan", "client's age", "marital status", "existance of records", "type of job", "amount of expenses", "amount of income", "amount of assets", "amount of debt" , "amount requested of loan", "price of good", "savings capacity (Income - Expenses - (Debt/100)) / (Amount / Time))", "financing ratio (Amount / Price)"),
  stringsAsFactors = FALSE
)

df = read.csv("./data/credit_data_train.csv")

# Define UI
ui = dashboardPage(
  dashboardHeader(),
  
  # side menu
  dashboardSidebar(
    sidebarMenu(
      menuItem("Описание данных", icon = icon("table"), tabName = "tab_data_info"),
      menuItem("Визуализация", icon = icon("bar-chart"), tabName = "tab_visualizations"),
      menuItem("Модель", tabName = "tab_train")
    )
  ),
  
  # content ui of app
  dashboardBody(
    # add css
    includeCSS("./styles.css"),
    
    tabItems(
      tab_data_info,
      tab_visualizations,
      tab_train
    )
  )
)

# Define server
server = function(input, output, session) {
  
  # создаем переменную на серверной стороне, 
  # в которой всегда будет храниться чистая версия данных
  recval = reactiveValues(data = df)
  
  # выводим таблицу с названиями и описанием переменных
  output$variables = renderDataTable(
    datatable(
      vars, 
      rownames = FALSE,
      extensions = 'Scroller',
      options = list(
        dom = 't',
        scrollY = 325,
        scroller = TRUE
      )
    )
  )
  
  
  ### pictures for vis tab - START
  output$plot_status_seniority = renderPlot({
    ggplot(recval$data) +
      geom_boxplot(aes(status, y = seniority)) + 
      theme_bw()+ 
      ggtitle("Стаж и кредитный статус")
  })
  
  output$plot_job_status = renderPlot({  
    recval$data %>%
      group_by(job, status) %>% 
      ggplot() +
      geom_bar(aes(x = job, fill = status), position = "fill") +
      theme_bw() +
      ggtitle("Тип занятости")
  })
  
  output$plot_finrat = renderPlot({  
    ggplot(df) +
      geom_boxplot(aes(x = status, y = finrat)) +
      theme_bw()
  })
  
  output$plot_age = renderPlot({  
    ggplot(recval$data) + 
      geom_histogram(aes(x = age, fill = job), binwidth = 1) + 
      theme_bw()
  })
  
  output$plot_home = renderPlot({  
    recval$data %>%
      group_by(home, status) %>% 
      ggplot() +
      geom_bar(aes(x = home, fill = status), position = "fill") +
      theme_bw() +
      ggtitle("Владение недвижимостью")
  })
  ### pictures for vis tab - END
  
  # прописываем что происходит если нажать на кнопку evaluate во вкладке model
  observeEvent(input$eval, {
    df = recval$data
    
    tryCatch(
      isolate(eval(parse(text=input$code))),
      error = function(e){
        showNotification(ui = h4(e$message), type = "error", session = session)
      }
    )
    
    df = df %>%
      mutate(prediction = "grant") %>%
      select(id, prediction) %>% 
      right_join(recval$data, by = "id") %>% 
      mutate(
        prediction = factor(ifelse(is.na(prediction), "forbid", prediction), levels = c("forbid", "grant"))
        )
    
    result_metrics = compute_metrics(df = df, pred = "prediction", ref = "status")
    
      # prediction table in counts
      output$print_accu_prop = renderTable({
        result_metrics$accu_prop
      }, hover = TRUE, bordered = TRUE, digits = 0)
      
      balance_color = ifelse((result_metrics$gain - result_metrics$lost) > 0, "green", "red")
      output$balance_box = renderValueBox({
          valueBox(
            paste0(result_metrics$gain - result_metrics$lost, "$"),
            subtitle = "Balance",
            icon = icon("list"),
            color = balance_color
          )
        })

      output$lost_profit_box = renderValueBox({
        valueBox(
          paste0(result_metrics$lost_gain, "$"),
          subtitle = "Lost gain",
          icon = icon("list"),
          color = "orange"
        )
      })
    
  })  
}

# Run the application 
shinyApp(ui = ui, server = server)

