tab_visualizations = tabItem(
  tabName = "tab_visualizations",
  
  fluidRow(
    box(
      width = 4,
      plotOutput("plot_status_seniority", height = "200px")
    ),
    box(
      width = 4,
      plotOutput("plot_job_status", height = "200px")
    ),
    box(
      width = 4,
      plotOutput("plot_home", height = "200px")
    )
  ),
  
  
  fluidRow(
    box(
      width = 6,
      plotOutput("plot_finrat", height = "300px")
    ),
    box(
      width = 6,
      plotOutput("plot_age", height = "300px")
    )
  )
  
)