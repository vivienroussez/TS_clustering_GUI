n_id <- 400
n_t <- 48

beg <- as_date("2014-01-01")
end <- beg+(n_t-1)*months(1)

ex_long <- expand.grid(time=seq(beg,end,"month"),ID=paste0("ID",1:n_id)) %>% 
  mutate(KPI1=rnorm(n_id*n_t),KPI2=rnorm(n_id*n_t,10,20),KPI3=rnorm(n_id*n_t,100,200))
write.csv(ex_long,file = "TS_clust_GUI/dummy_ex_dates.csv",row.names = F)

ex_long <- expand.grid(time=1:n_t,ID=paste0("ID",1:n_id)) %>% 
  mutate(KPI1=rnorm(n_id*n_t),KPI2=rnorm(n_id*n_t,10,20),KPI3=rnorm(n_id*n_t,100,200))
write.csv(ex_long,file = "TS_clust_GUI/dummy_ex_num.csv",row.names = F)
