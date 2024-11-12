
# install and load Refsplitr

# https://docs.ropensci.org/refsplitr/
# install.packages("devtools")
# devtools::install_github("ropensci/refsplitr")

require(refsplitr)
require(tidyr)
require(dplyr)
require(stringr)

# load the Web of Science records into a dataframe
# include_all=TRUE keeps the WOS column with email address
dat1 <- references_read("savedrecs.txt", 
                        dir = FALSE,
                        include_all=FALSE)  

# disambiguate author names and parse author address
dat2 <- authors_clean(dat1)

# you can check the preliminary results of the disambiguation algorithm here
dat2$review
dat2$prelim

# after reviewing disambiguation, merge any necessary corrections
dat3 <- authors_refine(dat2$review, dat2$prelim)

# NSF COA FORMAT

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
print(yr_48_ago)


# create a copy of the data to trim down to 48 months ago
dat4 <- dat3 
names(dat4)
# convert publication yr to a number and 
# filter dataframe to only the papers 48 months ago
dat4 <- dat4 %>% 
  mutate(PY = as.numeric(PY)) %>% 
  filter(PY >= yr_48_ago)

dat4 <- dat4 %>% select(author_name,
                        university,
                        city,
                        state,
                        country,
                        department,
                        OI,
                        PY)


dat4 <- dat4 %>% 
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

# made these in stringr with base r to make it easier 
# for users to decide what to include 
dat4$university <- str_to_title(dat4$university)

dat4$city <- str_to_title(dat4$city)

dat4$country <- str_to_title(dat4$country)
dat4 <- dat4 %>% mutate(country=
                          case_when(
                            country == "Usa" ~ "USA",
                            .default = as.character(country))
                        )

dat4$department <- str_to_title(dat4$department)

# Some in state are full name of state or province

dat4$state <- ifelse(nchar(dat4$state) == 2, 
                     str_to_upper(dat4$state),  # Uppercase for 2-character states
                     str_to_title(dat4$state))  # Title case for others


# last active is year

dat4$last_active <- dat4$PY


# rename "university" -> "org_affil"

dat4 <- dat4 %>% rename("org_affil"="university")

# filter to most recent

dat5 <- dat4 %>% 
  group_by(last_name,first_name) %>% 
  arrange(desc(PY)) %>% 
  slice_head(n=1)
  


# save the csv

write.csv(dat5,"./output/nsf_coauthors")

