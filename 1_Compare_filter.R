#UTF-8 with chinese
#以下中文内容应用UTF8编码，如无法正常显示可以open with encoding UTF8
#本部分为数据预处理，将进行数据载入及缺失数据的可视化

##文件夹请用英文命名
##读入的文件请转换为csv结尾的文件

#清空环境变量
rm(list = ls()) 
options(stringsAsFactors = F)

##载入需要的R包
library(tidyverse)
library(lubridate)

#设定工作目录
setwd("D:/pipeline")

#以下读入文件并进行预览
image_raw<- read.csv(file="image_raw.csv",#文件目录名
                    header = T,#第一行为列名
                    row.names = )#第一列为病案号
intervention_raw<- read.csv(file="intervention_raw.csv",#文件目录名
                 header = T,#第一行为列名
                 row.names = )#第一列为病案号

str(image_raw)#注意变量类型
str(intervention_raw)

#以下筛选需要纳入的变量重新构建数据集
names(image_raw)
image_raw%>%
          rename(.,id=patientid,
                 image_date=jianchariqi,
                 name=xingming,
                 location=jianchabuwei)->image_raw
selectnames <- c("id","name","shebei",
                 "location","image_date",
                 "baogao_jielun","baogao_miaoshu")
image_raw%>%select(.,id,selectnames)->image

intervention_raw%>%rename(.,sur_date=sur_data)->intervention
  
#转换数据格式

image$image_date <- as.Date(image$image_date) 
intervention$sur_date <- as.Date(intervention$sur_date) 

image$id <- as.integer(image$id)
intervention$id <- as.integer(intervention$id)


#以下确定每个患者每次影像学检查最早日期
new_image<- image%>%
  group_by(id) %>%       # group the rows by 'unique personal ID'
  slice_min(image_date, # keep row per group with minimum date value 
            n = 1,         # keep only the single highest row 
            with_ties = F) # if there's a tie, take the first row

#以下确定每次介入最早日期
new_intervention<- intervention%>%
  group_by(id) %>%       # group the rows by 'unique personal ID'
  slice_min(sur_date, # keep row per group with minimum date value 
            n = 1,         # keep only the single highest row 
            with_ties = F)

#以下合并两组数据
all_data <- inner_join(new_image,new_intervention,by="id")
str(all_data)

#筛选location里面有腹部的检查及检查距离治疗60日内
names(all_data)

all_data[str_detect(all_data$location,"腹"),]->newdata

newdata%>%subset(.,image_date>=sur_date-60)->newdata

#一线
save(newdata,file = "newdata.RData")


