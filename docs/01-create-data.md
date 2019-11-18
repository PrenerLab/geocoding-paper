Create Data
================
Christopher Prener, Ph.D.
(November 18, 2019)

## Introduction

This notebook creates the crime data sets needed for the geocoder
analyses.

## Dependencies

This notebook requires a number of packages to working with data and
wrangling it.

``` r
# tidystl packages
library(compstatr)
library(gateway)
library(postmastr)

# tidyverse packages
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(stringr)
library(readr)

# other packages
library(here)
```

    ## here() starts at /Users/prenercg/GitHub/PrenerLab/geocoding-paper

``` r
library(testthat)
```

    ## 
    ## Attaching package: 'testthat'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     matches

## Prepare Data

### Download Crime Data

The initial step is to create an index of data available from the
St. Louis Metropolitan Police Department’s website:

``` r
i <- cs_create_index()
```

With the index created, we can create separate raw crime objects by
year:

``` r
data2018_raw <- cs_get_data(year = 2018, index = i)
data2017_raw <- cs_get_data(year = 2017, index = i)
data2016_raw <- cs_get_data(year = 2016, index = i)
data2015_raw <- cs_get_data(year = 2015, index = i)
data2014_raw <- cs_get_data(year = 2014, index = i)
data2013_raw <- cs_get_data(year = 2013, index = i)
data2012_raw <- cs_get_data(year = 2012, index = i)
data2011_raw <- cs_get_data(year = 2011, index = i)
data2010_raw <- cs_get_data(year = 2010, index = i)
data2009_raw <- cs_get_data(year = 2009, index = i)
data2008_raw <- cs_get_data(year = 2008, index = i)
```

### 2018

We validate the data to make sure it can be collapsed using
`cs_validate()`:

``` r
expect_equal(cs_validate(data2018_raw, year = "2018"), TRUE)
```

Since the validation result is a value of `TRUE`, we can proceed to
collapsing the year-list object into a single tibble with
`cs_collapse()` and then stripping out crimes reported in 2018 for
earlier years using `cs_combine()`. We also strip out unfounded crimes
that remain using `cs_filter_count()`:

``` r
# collapse into single object
data2018_raw <- cs_collapse(data2018_raw)

# combine and filter
cs_combine(type = "year", date = 2018, data2018_raw) %>%
  cs_filter_count(var = count) -> crime2018
```

The `data2018` object now contains only crimes reported in 2018.

### 2017

We’ll repeat the validation process with the 2017 data:

``` r
expect_equal(cs_validate(data2017_raw, year = "2017"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occurring.

``` r
cs_validate(data2017_raw, year = "2017", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2017 TRUE    TRUE     TRUE    
    ##  2 February   February   TRUE          2017 TRUE    TRUE     TRUE    
    ##  3 March      March      TRUE          2017 TRUE    TRUE     TRUE    
    ##  4 April      April      TRUE          2017 TRUE    TRUE     TRUE    
    ##  5 May        May        TRUE          2017 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2017 TRUE    TRUE     TRUE    
    ##  7 July       July       TRUE          2017 TRUE    TRUE     TRUE    
    ##  8 August     August     TRUE          2017 TRUE    TRUE     TRUE    
    ##  9 September  September  TRUE          2017 TRUE    TRUE     TRUE    
    ## 10 October    October    TRUE          2017 TRUE    TRUE     TRUE    
    ## 11 November   November   TRUE          2017 TRUE    TRUE     TRUE    
    ## 12 December   December   TRUE          2017 TRUE    TRUE     TRUE    
    ## # … with 1 more variable: valVars <lgl>

The data for May 2017 do not pass the validation checks. We can extract
this month and confirm that there are too many columns in the May 2017
release. Once we have that confirmed, we can standardize that month and
re-run our validation.

``` r
# extract data and unit test column numbers
expect_equal(ncol(cs_extract_month(data2017_raw, month = "May")), 26)

# standardize months
data2017_raw <- cs_standardize(data2017_raw, month = "May", config = 26)

# validate data
expect_equal(cs_validate(data2017_raw, year = "2017"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing the 2017 and 2018 raw data objects to create a new object,
`crime2017`, that contains all known 2017 crimes including those that
were reported or upgraded in 2018.

``` r
# collapse into single object
data2017_raw <- cs_collapse(data2017_raw)
# combine and filter
cs_combine(type = "year", date = 2017, data2018_raw, data2017_raw) %>%
  cs_filter_count(var = count) -> crime2017
```

### 2016

We’ll repeat the validation process with the 2016 data:

``` r
expect_equal(cs_validate(data2016_raw, year = "2016"), TRUE)
```

Since the validation process passes, we can immediately move on to
creating our 2016 data object:

``` r
# collapse into single object
data2016_raw <- cs_collapse(data2016_raw)

# combine and filter
cs_combine(type = "year", date = 2016, data2018_raw, data2017_raw, data2016_raw) %>%
  cs_filter_count(var = count) -> crime2016
```

### 2015

We’ll repeat the validation process with the 2015 data:

``` r
expect_equal(cs_validate(data2015_raw, year = "2015"), TRUE)
```

Since the validation process passes, we can immediately move on to
creating our 2015 data object:

``` r
# collapse into single object
data2015_raw <- cs_collapse(data2015_raw)

# combine and filter
cs_combine(type = "year", date = 2015, data2018_raw, data2017_raw, data2016_raw, data2015_raw) %>%
  cs_filter_count(var = count) -> crime2015
```

### 2014

We’ll repeat the validation process with the 2014 data:

``` r
expect_equal(cs_validate(data2014_raw, year = "2014"), TRUE)
```

Since the validation process passes, we can immediately move on to
creating our 2014 data object:

``` r
# collapse into single object
data2014_raw <- cs_collapse(data2014_raw)

# combine and filter
cs_combine(type = "year", date = 2014, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw) %>%
  cs_filter_count(var = count) -> crime2014
```

### 2013

We’ll repeat the validation process with the 2013 data:

``` r
expect_equal(cs_validate(data2013_raw, year = "2013"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2013_raw, year = "2013", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2013 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2013 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2013 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2013 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2013 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2013 TRUE    TRUE     TRUE    
    ##  7 July       July       TRUE          2013 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2013 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2013 TRUE    TRUE     TRUE    
    ## 10 October    October    TRUE          2013 TRUE    TRUE     TRUE    
    ## 11 November   November   TRUE          2013 TRUE    TRUE     TRUE    
    ## 12 December   December   TRUE          2013 TRUE    TRUE     TRUE    
    ## # … with 1 more variable: valVars <lgl>

The data for January through May, July, and August do not pass the
validation checks. We can extract these and confirm that there are not
enough columns in each of these releases Once we have that confirmed, we
can standardize that month and re-run our validation.

``` r
# January - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "January")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "January", config = 18)

# February - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "February")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "February", config = 18)

# March - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "March")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "March", config = 18)

# April - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "April")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "April", config = 18)

# May - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "May")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "May", config = 18)

# July - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "July")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "July", config = 18)

# August - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "August")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "August", config = 18)

# validate data
expect_equal(cs_validate(data2013_raw, year = "2013"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `crime2013`,
that contains all known 2013 crimes including those that were reported
or upgraded in subsequent years:

``` r
# collapse into single object
data2013_raw <- cs_collapse(data2013_raw)

# combine and filter
cs_combine(type = "year", date = 2013, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw) %>%
  cs_filter_count(var = count) -> crime2013
```

### 2012

We’ll repeat the validation process with the 2012 data:

``` r
expect_equal(cs_validate(data2012_raw, year = "2012"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2012_raw, year = "2012", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2012 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2012 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2012 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2012 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2012 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2012 TRUE    TRUE     FALSE   
    ##  7 July       July       TRUE          2012 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2012 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2012 TRUE    TRUE     FALSE   
    ## 10 October    October    TRUE          2012 TRUE    TRUE     FALSE   
    ## 11 November   November   TRUE          2012 TRUE    TRUE     FALSE   
    ## 12 December   December   TRUE          2012 TRUE    TRUE     FALSE   
    ## # … with 1 more variable: valVars <lgl>

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test
expect_equal(ncol(cs_extract_month(data2012_raw, month = "January")), 18)

# standardize
data2012_raw <- cs_standardize(data2012_raw, month = "all", config = 18)

# validate data
expect_equal(cs_validate(data2012_raw, year = "2012"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `crime2012`,
that contains all known 2012 crimes including those that were reported
or upgraded in subsequent years:

``` r
# collapse into single object
data2012_raw <- cs_collapse(data2012_raw)

# combine and filter
cs_combine(type = "year", date = 2012, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw, data2012_raw) %>%
  cs_filter_count(var = count) -> crime2012
```

### 2011

We’ll repeat the validation process with the 2011 data:

``` r
expect_equal(cs_validate(data2011_raw, year = "2011"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2011_raw, year = "2011", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2011 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2011 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2011 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2011 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2011 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2011 TRUE    TRUE     FALSE   
    ##  7 July       July       TRUE          2011 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2011 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2011 TRUE    TRUE     FALSE   
    ## 10 October    October    TRUE          2011 TRUE    TRUE     FALSE   
    ## 11 November   November   TRUE          2011 TRUE    TRUE     FALSE   
    ## 12 December   December   TRUE          2011 TRUE    TRUE     FALSE   
    ## # … with 1 more variable: valVars <lgl>

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test
expect_equal(ncol(cs_extract_month(data2011_raw, month = "January")), 18)

# standardize
data2011_raw <- cs_standardize(data2011_raw, month = "all", config = 18)

# validate data
expect_equal(cs_validate(data2011_raw, year = "2011"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `crime2011`,
that contains all known 2011 crimes including those that were reported
or upgraded in subsequent years:

``` r
# collapse into single object
data2011_raw <- cs_collapse(data2011_raw)

# combine and filter
cs_combine(type = "year", date = 2011, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw, data2012_raw, data2011_raw) %>%
  cs_filter_count(var = count) -> crime2011
```

### 2010

We’ll repeat the validation process with the 2010 data:

``` r
expect_equal(cs_validate(data2010_raw, year = "2010"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2010_raw, year = "2010", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2010 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2010 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2010 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2010 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2010 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2010 TRUE    TRUE     FALSE   
    ##  7 July       July       TRUE          2010 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2010 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2010 TRUE    TRUE     FALSE   
    ## 10 October    October    TRUE          2010 TRUE    TRUE     FALSE   
    ## 11 November   November   TRUE          2010 TRUE    TRUE     FALSE   
    ## 12 December   December   TRUE          2010 TRUE    TRUE     FALSE   
    ## # … with 1 more variable: valVars <lgl>

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test
expect_equal(ncol(cs_extract_month(data2010_raw, month = "January")), 18)

# standardize all months
data2010_raw <- cs_standardize(data2010_raw, month = "all", config = 18)

# validate data
expect_equal(cs_validate(data2010_raw, year = "2010"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `crime2010`,
that contains all known 2010 crimes including those that were reported
or upgraded in subsequent years:

``` r
# collapse into single object
data2010_raw <- cs_collapse(data2010_raw)

# combine and filter
cs_combine(type = "year", date = 2010, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw, data2012_raw, data2011_raw, data2010_raw) %>%
  cs_filter_count(var = count) -> crime2010
```

### 2009

We’ll repeat the validation process with the 2009 data:

``` r
expect_equal(cs_validate(data2009_raw, year = "2009"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2009_raw, year = "2009", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2009 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2009 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2009 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2009 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2009 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2009 TRUE    TRUE     FALSE   
    ##  7 July       July       TRUE          2009 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2009 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2009 TRUE    TRUE     FALSE   
    ## 10 October    October    TRUE          2009 TRUE    TRUE     FALSE   
    ## 11 November   November   TRUE          2009 TRUE    TRUE     FALSE   
    ## 12 December   December   TRUE          2009 TRUE    TRUE     FALSE   
    ## # … with 1 more variable: valVars <lgl>

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test
expect_equal(ncol(cs_extract_month(data2009_raw, month = "January")), 18)

# standardize all months
data2009_raw <- cs_standardize(data2009_raw, month = "all", config = 18)

# validate data
expect_equal(cs_validate(data2009_raw, year = "2009"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `crime2009`,
that contains all known 2009 crimes including those that were reported
or upgraded in subsequent years:

``` r
# collapse into single object
data2009_raw <- cs_collapse(data2009_raw)

# combine and filter
cs_combine(type = "year", date = 2009, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw, data2012_raw, data2011_raw, data2010_raw, data2009_raw) %>%
  cs_filter_count(var = count) -> crime2009
```

### 2008

We’ll repeat the validation process with the 2008 data:

``` r
expect_equal(cs_validate(data2008_raw, year = "2008"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2008_raw, year = "2008", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2008 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2008 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2008 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2008 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2008 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2008 TRUE    TRUE     FALSE   
    ##  7 July       July       TRUE          2008 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2008 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2008 TRUE    TRUE     FALSE   
    ## 10 October    October    TRUE          2008 TRUE    TRUE     FALSE   
    ## 11 November   November   TRUE          2008 TRUE    TRUE     FALSE   
    ## 12 December   December   TRUE          2008 TRUE    TRUE     FALSE   
    ## # … with 1 more variable: valVars <lgl>

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test,
expect_equal(ncol(cs_extract_month(data2008_raw, month = "January")), 18)

# standardize all months
data2008_raw <- cs_standardize(data2008_raw, month = "all", config = 18)

# validate data
expect_equal(cs_validate(data2008_raw, year = "2008"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `crime2008`,
that contains all known 2008 crimes including those that were reported
or upgraded in subsequent years:

``` r
# collapse into single object
data2008_raw <- cs_collapse(data2008_raw)

# combine and filter
cs_combine(type = "year", date = 2008, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw, data2012_raw, data2011_raw, data2010_raw, data2009_raw, data2008_raw) %>%
  cs_filter_count(var = count) -> crime2008
```

## Clean-up Enviornment

We can remove the `_raw` objects at this
point:

``` r
rm(data2008_raw, data2009_raw, data2010_raw, data2011_raw, data2012_raw, data2013_raw, data2014_raw, data2015_raw, data2016_raw, data2017_raw, data2018_raw)
```

## Create Single Table

Next, we’ll create a single table before we remove individual years. We
also subset columns to reduce the footprint of the
table.

``` r
bind_rows(crime2008, crime2009, crime2010, crime2011, crime2012, crime2013, crime2014, crime2015, crime2016, crime2017, crime2018) %>%
  select(cs_year, date_occur, crime, description, ileads_address, ileads_street) -> allCrimes
```

### Clean-up Enviornment

We’ll remove excess objects
again:

``` r
rm(crime2008, crime2009, crime2010, crime2011, crime2012, crime2013, crime2014, crime2015, crime2016, crime2017, crime2018)
```

## Subset Homicides

Now that we have a slimmed down data set, we’ll subset it by identifying
only homicidies that occured between 2008 and
2018:

``` r
allHomicides <- cs_filter_crime(allCrimes, var = crime, crime = "murder")

# unit set
expect_equal(nrow(allHomicides), 1822)
```

### Normalize Address Data

We’ll therefore remove the coordinate data and start from scratch,
showcasing the `tidystl` approach to open source geocoding. Then, we
need to create a single address string. Some intersections are preceded
by a 0 for the house number, and we’ll want to remove that as well:

``` r
allHomicides %>%
  mutate(address = str_c(ileads_address, ileads_street, sep = " ")) %>%
  mutate(address = ifelse(str_detect(string = address, pattern = "^[0\\b]") == TRUE,
                          str_replace(string = address, pattern = "^[0\\b]", replacement = ""),
                          address)) %>%
  mutate(address = str_trim(address)) -> allHomicides
```

Once we have a single address string with the 0’s removed, we can move
on to normalizing them. First, we’ll check out the types of addresses
that the `postmastr` package finds on its initial pass with
`pm_identify()`:

``` r
allHomicides <- pm_identify(allHomicides, var = address)
pm_evaluate(allHomicides)
```

    ## # A tibble: 4 x 3
    ##   pm.type      count   pct
    ##   <chr>        <int> <dbl>
    ## 1 short         1788 98.1 
    ## 2 intersection    26  1.43
    ## 3 unknown          7  0.38
    ## 4 full             1  0.05

We’re all over the map here (pun intended) - we have mostly short
addresses, some intersections, and then a mix of poorly formatted
addresses that can’t be adequately matched. We’ll clean up the unknown,
partial, and full intersections so that they are more consistenty
formatted:

``` r
# clean-up addresses manually
allHomicides %>%
  mutate(address = ifelse(pm.id == 226, "KENNEDY FOREST", address)) %>%
  mutate(address = ifelse(pm.id == 354, "NORTH 1ST ST AT MULLANPHY ST", address)) %>%
  mutate(address = ifelse(pm.id == 355, "NORTH 1ST ST AT MULLANPHY ST", address)) %>%
  mutate(address = ifelse(pm.id == 568, "O'FALLON PARK", address)) %>%
  mutate(address = ifelse(pm.id == 803, NA, address)) %>%
  mutate(address = ifelse(pm.id == 929, NA, address)) %>%
  mutate(address = ifelse(pm.id == 961, "O'FALLON PARK", address)) %>%
  mutate(address = ifelse(pm.id == 962, "O'FALLON PARK", address)) %>%
  mutate(address = ifelse(pm.id == 1268, NA, address)) -> allHomicides

# re-identify
allHomicides <- pm_identify(allHomicides, var = address)

# evaluate again
pm_evaluate(allHomicides)
```

    ## # A tibble: 3 x 3
    ##   pm.type      count   pct
    ##   <chr>        <int> <dbl>
    ## 1 short         1788 98.1 
    ## 2 intersection    26  1.43
    ## 3 unknown          8  0.44

With our data prepped, we can normalize them. The `gateway` package has
dictionaries for the key short address components in St. Louis - these
can be used out of the box to improve the parser’s
behavior.

``` r
allHomicides <- pm_parse(allHomicides, input = "short", address = address, 
                         output = "short", new_address = address_norm, 
                         houseSuf_dict = stl_std_houseSuffix,
                         dir_dict = stl_std_directions,
                         street_dict = stl_std_streets,
                         suffix_dict = stl_std_suffix)
```

    ## Warning: `cols` is now required.
    ## Please use `cols = c(pm.address)`

    ## Warning: `cols` is now required.
    ## Please use `cols = c(data, y)`

## Write Data

Finally, we’ll write our initial data set of homicides to the `data/`
folder:

``` r
write_csv(allHomicides, here("data", "STL_CRIME_Homicides.csv"))
```
