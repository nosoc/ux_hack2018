compute_metrics = function(df, pred, ref){
  # add scores
  accu = table(df[,pred], df[,ref]) %>% 
    as.data.frame() %>% 
    spread(Var2, Freq) %>% 
    rename(` ` = Var1)
  
  accu_prop = table(df[,pred], df[,ref]) %>% 
    as.data.frame() %>% 
    mutate(Freq = round((Freq/sum(Freq))*100, 0)) %>% 
    # mutate(Freq = stringr::str_c(Freq, "%")) %>% 
    spread(Var2, Freq) %>% 
    rename(` ` = Var1)
  
  # error rates
  raw_tbl = table(df[,pred], df[,ref])
  accu_rate = round(sum(diag(raw_tbl))/sum(raw_tbl)*100)
  err_rate = 100 - accu_rate
  false_positive = round(raw_tbl["grant","bad"]/sum(raw_tbl)*100)
  false_negative = round(raw_tbl["forbid","good"]/sum(raw_tbl)*100)
  
  # in profit
  df = df %>% 
    mutate(gain = round(amount*0.13))
  
  lost = sum(df$amount[df$status=="bad" & df$prediction == "grant"])
  gain = sum(df$gain[df$status=="good" & df$prediction == "grant"])
  lost_gain = sum(df$gain[df$status=="good" & df$prediction == "forbid"])
  
  balance = gain - lost - lost_gain
  
  result = list(
    "accu" = accu,
    "accu_prop" = accu_prop,
    "accu_rate" = accu_rate,
    "err_rate" = err_rate,
    "false_positive" = false_positive,
    "false_negative" = false_negative,
    "lost" = lost,
    "gain" = gain,
    "lost_gain" = lost_gain,
    "balance" = balance
  )
  
  return(result)  
}


