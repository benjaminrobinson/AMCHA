library(rvest)
library(dplyr)
library(tidyr)
library(janitor)
library(purrr)

# read_html("https://amchainitiative.org/search-by-incident#incident/display-by-date/") |>
#   html_table()

# htm2txt::gettxt('https://www.hillel.org/top-60-jewish-colleges/', 'ASCII') %>%
#   strsplit("\n") %>%
#   unlist %>%
#   str_squish %>%
#   .[. != ''] %>%
#   unique %>%
#   iconv("latin1", "ASCII", sub = "") %>%
#   sub("  ", ", ", .) %>%
#   str_squish %>%
#   .[grepl("Jewish ", .)] %>%
#   .[grepl("%", .)] %>%
#   gsub("[:]", ";", .) %>%
#   sub(" Jewish students", "", .) %>%
#   sub(" Jewish studetns", "", .) %>%

'https://www.hillel.org/top-60-jewish-colleges/' %>%
  read_html %>%
  html_nodes('a') %>%
  html_attr('href') %>%
  .[grepl('https://www.hillel.org/college/', .)] %>%
  unique -> hillel

map_dfr(hillel, function(x) {
  print(x)
  sch <- read_html(x)
  
  sch %>%
    html_nodes('.cs-hero__title') %>%
    html_text %>%
    str_squish -> sch_nm
  
  sch %>%
    html_nodes('.cs-content-block__details') %>%
    html_text %>%
    str_squish %>%
    sub(" Jewish Students ", "; ", .) %>%
    sub(" Students[*]Percent of population", "", .) %>%
    sub("[*])", "; ", .) %>%
    sub(" \\(", " ", .) %>%
    as.data.frame %>%
    setNames("apollo") %>%
    separate(
      col = 'apollo',
      sep = '; ',
      into = c(
        'jewish_students_n',
        'jewish_students_perc',
        'total_students_n'
      )
    ) %>%
    mutate(
      school = sch_nm,
      across(contains("students_n"), ~ as.numeric(sub("[,]", "", .))),
      across(contains("students_perc"), ~ as.numeric(sub("[%]", "", .)) /
               100),
      student_type = ifelse(row_number() == 1, 'Undergraduate', 'Graduate')
    ) %>%
    select(student_type, school, contains('jewish'), contains('total')) %>%
    adorn_totals %>%
    mutate(
      school = ifelse(school == '-', sch_nm, school),
      jewish_students_perc_real = jewish_students_n / total_students_n,
      jewish_students_perc = ifelse(
        student_type == 'Total',
        round(jewish_students_perc_real, 3),
        jewish_students_perc
      )
    )
}) -> jews

write.csv(jews,
          "C:/Users/benjr/Desktop/hillel_jewish_students.csv",
          row.names = FALSE)