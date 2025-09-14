# ZOO800_Homework
Homework 2 
Frank, Jaden, Lucas 

Objective 1:

Search terms:
"methane streams" - 1/5 mentioned open source software, 2/5 placed data in a repository (github and figshare), 1/5 had code in public repository (github)
"submerged macrophytes methane" - 4/5 mentioned open source software, 0/5 data or code in public repository
"respirometry" - 2/5 mentioned open source software, 0/5 data or code in public repository
"sakhalin taimen" - 1/1 open source software, 0/1 data or code in public repository
"salmon metabolism" - 1/1 open source software, 0/1 data or code in public repository
"temperature performance" - 1/1 open source software, 0/1 data or code in public repository
"stomatal conductance and photosynthesis" - 9/11 directly mention open source software, 4/11 placed data in repository, 1/11 had code in public repository (github)

Objective 2:
Excessive leaf oil modulates the plant abiotic stress response via reduced stomatal aperture in tobacco (Nicotiana tabacum)
https://doi.org/10.1111/tpj.70067 
We were able to recreate figure 2 (second panel) in R. 
We did need to change paths to read in a .CSV file using version control:
line 42 
ORIGINALL: "single  <- read.csv(file = "02112023_combined.csv", header = TRUE)" 
WE USED: "single <- read.csv("R-scripts/stomata/02112023_combined.csv", header = TRUE)"
