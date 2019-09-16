# https://www.youtube.com/watch?v=kCOQSEeiFeA&feature=youtu.be

# sudo adduser fdrennan
# sudo passwd fdrennan
# then add pw

# sudo -u hdfs hadoop fs -mkdir /user/fdrennan
# sudo -u hdfs hadoop fs -chown fdrennan /user/fdrennan

## https://www.rstudio.com/products/rstudio/download-server/
# wget https://download2.rstudio.org/server/centos6/x86_64/rstudio-server-rhel-1.2.1335-x86_64.rpm
# sudo yum install rstudio-server-rhel-1.2.1335-x86_64.rpm

# sudo yum install libcurl-devel

# sudo usermod -aG wheel fdrennan

# load the sparklyr, dplyr, ggplot2, and DBI packages

install.packages(c('sparklyr', 'dplyr'))

library(sparklyr)
library(dplyr)

sc <- spark_connect(master = "yarn-client", 
                    version = "2.8.5",
                    spark_home = '/usr/lib/spark')

movies_tbl <- spark_read_csv(sc, 'ratings', 's3://drenrdatasets/ratings.csv')

movies <- movies_tbl %>% 
  arrange(movieId) %>% 
  transmute(user   = userId,
            rating    = rating,
            item = dense_rank(movieId))

model <- ml_als(movies, rating ~ user + item)

predictions <- ml_predict(model, movies) 

data <- 
  ml_recommend(model, type = c("items", "users"), n = 2) %>% 
  select(-recommendations) %>%  
  collect

# When I start doing this in the video, it's not going to work. 
# It simply took too much time for me. 
# If you would really like to see how this works, I can make a smaller example and share it with you. 
item_factors = collect(model$model$item_factors)
user_factors = collect(model$model$user_factors)



