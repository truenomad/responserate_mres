

library(sqldf)

RR_data <-readxl::read_xlsx("data/RR_data_3.xlsx")


## number of studies with random assignment

sqldf("

SELECT COUNT(study)
FROM RR_data
WHERE rand_assign = 'Yes';


      ") # 12 Stuides use the random assignent, therefore 6 studies must not use random assignment


## number of studies with incentives
sqldf("
      SELECT COUNT(study)
      FROM RR_data
      WHERE incentives = 'Yes';
      ") # 7 Stuides use the incentives, therefore 11 studies must not use incentives



## number of studies with remindera
sqldf("
      SELECT COUNT(study)
      FROM RR_data
      WHERE reminder = 'Yes';
      ") # 13 Stuides use the reminder, therefore 5 studies must not use reminders
