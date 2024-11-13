# Generate coauthor list for NSF proposals

Use this script to convert a list of articles exported from the Web of Science into a list of coauthors & their institutions in the format required for an NSF COA template. The script requires:

1. a list of articles exported from the Web of Science in either `.txt` or `.ciw` (Endnote) format.

2. the following packages:

- [`refsplitr`](https://docs.ropensci.org/refsplitr/)[^1]  
- [`tidyr`](https://tidyr.tidyverse.org/)  
- [`dplyr`](https://dplyr.tidyverse.org/)  
- [`stringr`](https://stringr.tidyverse.org/)  

All but [`refsplitr`](https://docs.ropensci.org/refsplitr/) are available on CRAN; instructions on downloading `refspliter` can be found on the [rOpenSci](https://docs.ropensci.org/refsplitr/) website.


## Step-by-Step

1. Search the Web of Science for your articles; if searching by name be sure to search for and include any with group authorship (e.g., like [this one](https://www.science.org/doi/10.1126/science.adh8830)). You can save the records as a marked list to add to the list over time or export the search results without saving to a list. e

2. Click the "Export" box and select 'Plain text file' from the dropdown menu. 

3. On the Export Records window, click the circle for "Records from" and fill in the "to" box with the total number of records you found. Under Record Content, choose "full record" (the additional fields are useful for disambiguating author names). You can see more on these steps [here](https://docs.ropensci.org/refsplitr/articles/refsplitr.html#appendix-1-guide-to-downloading-reference-records-from-the-web-of-science-).

2. Save the downloaded records in the root directory as `savedrecs.txt` or `savedrecs.ciw`. (you can save them with another name, but then you have to change the file name in the script).

3. open and run the `coauthors_nsf.R` script.

4. your records will be saved as `nsf_coauthors.csv` in the output folder. In addition to the columns required by NSF, it includes columns with optional data they suggest you may include. 

## Advantages

1. You curate your own list of articles from the Web of Science. (Pulling records from databases by author name can miss articles (e.g., if they search by author name but you are part of an author group). 

## Limitations

1. Articles are recorded and selected by publication year (not month & year), so some coauthors might be included even if the articles were slightly outside the 48 month window (i.e.,  list for grant submitted in August 2024 would include articles published in Jan-July 2024).

2. Requires WOS access. A `refsplitr` update for processing SCOPUS output, as well as `.bib` and other  formats is in progress but not yet available. 

[^1]: `refsplitr` (v1.0) is an rOpenSci R package to parse and organize reference records downloaded from the Web of Science citation database, disambiguate the names of authors, geocode their locations, and generate/visualize coauthorship networks. (you can read more [here](https://docs.ropensci.org/refsplitr/). To install `refsplitr`, uncomment the 2 lines of code in the `coauthors_nsf.R` script.


