tab_train = tabItem(tabName = "tab_train",
  fluidRow(
    # insert code
    box(
      width = 8,
      h3("Сегментация"),
      p("Датафрейм df - база клиентов, которые ждут одобрения кредита."), 
      p("Сделайте так, чтобы в df остались только те клиенты, которым Вы готовы одобрить кредит."),
      aceEditor(
        "code", 
        mode="r", 
        value="df = df %>% ...",
        height = "150px"
      ),
      actionButton("eval", "Evaluate")
    ),
    
    box(
      width = 4,
      height = "300px",
      h3("Матрица несоответствий (в процентах)"),
      p("Строчки - Ваше предсказание"),
      p("Колонки - вернул ли клиент кредит"),
      tableOutput("print_accu_prop")
    )
  ),
  
  fluidRow(
    valueBoxOutput("balance_box", width = 3),
    valueBoxOutput("lost_profit_box", width = 3),
    box(
      width = 6,
      h3("Метрики качества модели"),
      p("Баланс = Проценты с выплаченных кредитов - Сумма невыплаченых кредитов"),
      p("Упущенная прибыль = Проценты с тех кредитов, которые бы вернули, но Вы их не одобрили.")
    )
  )
  
)