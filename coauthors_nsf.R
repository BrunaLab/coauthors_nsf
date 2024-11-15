
# Prepare list of coauthors / affiliations required by NSF COA spreadsheet
# using a file of article records downloaded from the Web of Science/

# load an install libraries -----------------------------------------------

# refsplitr (https://docs.ropensci.org/refsplitr/) not on cran
# to install uncomment the the following lines of code: 

# install.packages("devtools")
# devtools::install_github("ropensci/refsplitr")

require(refsplitr)
require(tidyr)
require(dplyr)
require(stringr)


# load and process WoS file -----------------------------------------------

# load the Web of Science records into a dataframe
# include_all=TRUE keeps the WOS column with email address
dat1 <- references_read("savedrecs.txt", 
                        dir = FALSE,
                        include_all=FALSE)  %>% 
  relocate(refID=.before=1)

# disambiguate author names and parse author address
dat2 <- authors_clean(dat1)

# you can check the preliminary results of the disambiguation algorithm here
# dat2$review
# dat2$prelim

# this line is required, even if you don't manually review and correct the 
# author disambiguation. Correction of disambiguation unlikely 
# with smaller author lists, e.g., single author and collaborators. 

dat2 <- authors_refine(dat2$review, dat2$prelim)


# exclude specific articles -----------------------------------------------

# for group papers with many authors you may wish to only report the 1st or
# primary authors as C or A. You can exclude those articles here to avoid 
# all the other coauthors being added to the list. 

# dat2<-dat2 %>% 
#   filter(refID!="7") %>% 
#   filter(refID!="4")


  ## Table 4: List names as last name, first name, middle initial, and 
  ## provide organizational affiliations, if known, for the following:
  ## A: Co-authors on any book, article, report, abstract or paper with 
  ## collaboration in the last 48 months (publication date may be later); and 

# calculate the year 48 months ago
# The month/year
today_yr <- as.numeric(format(Sys.time(), "%Y"))
# Subtract 48 months (4 years) using the `seq` function
yr_48_ago <- today_yr-4
# Print the result
# print(yr_48_ago)


# reduce list to prior 4 years  -------------------------------------------

# create a copy of the data to trim down to 48 months ago
# dat2 <- dat3 

# convert publication yr to a number and 
# filter dataframe to only the papers within last 4 years 
# and then to the distinct coauthors 
# (distinct(group_id) works because if same author 
# coauthor on multiple papers in last 4 years it will only keep
# the first one, which will be the most recent (sort desc(PY))

dat2 <- dat2 %>% 
  mutate(PY = as.numeric(PY)) %>% 
  filter(PY >= yr_48_ago) %>% 
  arrange(desc(PY)) %>% 
  distinct(groupID,.keep_all = TRUE)



dat2 <- dat2 %>% select(author_name,
                        university,
                        city,
                        state,
                        country,
                        department,
                        OI,
                        PY)

# convert refsplitr output to NSF COA format ------------------------------
dat2 <- dat2 %>% 
  separate_wider_delim(author_name,
                       delim = ",", names = c("last_name", "first_name"),
                       too_many = "merge"
                       ) %>% 
  mutate_all(trimws) %>% 
  mutate(first_name=gsub(" -","-",first_name)) %>% 
  mutate(first_name=gsub(",",".",first_name)) %>% 
  separate_wider_delim(first_name,
                       delim = " ", names = c("first_name","middle_name"),
                       too_few = c("align_start"),
                       too_many = "merge") 

# made these with base r to make it easier for users to 
# decide what to include in output

# Capitalize organization name
dat2$university <- str_to_title(dat2$university)

# Capitalize city name
dat2$city <- str_to_title(dat2$city)

# Capitalize country name (except USA as all caps)
dat2$country <- str_to_title(dat2$country)
dat2 <- dat2 %>% mutate(country=
                          case_when(
                            country == "Usa" ~ "USA",
                            .default = as.character(country))
                        )
# Capitalize organizations's department if one given
dat2$department <- str_to_title(dat2$department)

# Some in "state" are full name of state or province
dat2$state <- ifelse(nchar(dat2$state) == 2, 
                     str_to_upper(dat2$state),  # Uppercase for 2-character states
                     str_to_title(dat2$state))  # Title case for others


# "last active" is year of paper

dat2$last_active <- dat2$PY

# rename "university" -> "org_affil"

dat2 <- dat2 %>% rename("org_affil"="university")

# arrange and save as csv 

dat2 <- dat2 %>% 
  arrange(last_name, first_name) %>% 
  mutate(name=paste(last_name, first_name, sep=", ")) %>% 
  mutate(org_affil_2=(paste(org_affil, " (",country,") ",sep=""))) %>% 
  arrange(desc(PY)) %>% 
  relocate(c(name,org_affil_2,department,last_active),.before=1) %>% 
  replace_na(list(org_affil_2="-",department="-"))



# save the csv

write.csv(dat2,"nsf_coauthors.csv")

