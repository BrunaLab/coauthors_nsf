# Generate coauthor list for NSF proposals

Use this script to convert generate your list of coauthors in the format required for NSF COA template. The script requires the following packages:

[`refsplitr`](https://docs.ropensci.org/refsplitr/)
[`tidyr`](https://tidyr.tidyverse.org/)
[`dplyr`](https://dplyr.tidyverse.org/)
[`stringr`](https://stringr.tidyverse.org/)

All but `refsplitr` are available on CRAN. 

`refsplitr` (v1.0) is an rOpenSci R package to parse and organize reference records downloaded from the Web of Science citation database, disambiguate the names of authors, geocode their locations, and generate/visualize coauthorship networks. (you can read more [here](https://docs.ropensci.org/refsplitr/). To install `refsplitr`, use the following commands; they are in the `coauthors_nsf.R` script but commented out:

```
install.packages("devtools")
devtools::install_github("ropensci/refsplitr")
```
 


1. Search the Web of Science for your articles, then download the "complete records" as a text file (more information on how is [here](https://docs.ropensci.org/refsplitr/articles/refsplitr.html#appendix-1-guide-to-downloading-reference-records-from-the-web-of-science-).

2. Save the downloaded records in the root directory as `savedrecs.text`.

3. open and run the `coauthors_nsf.R` script.

4. your records will be saved as `nsf_coauthors.csv` in the output folder. In addition to the columns required by NSF, it includes columns with optional data they suggest you may include. 



