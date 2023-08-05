library(dplyr)
library(fastLink)
library(tibble)

read.csv("C:/Users/benjr/Desktop/Projects/AMCHA/amcha_init.csv") -> amcha

read.csv("C:/Users/benjr/Desktop/Projects/AMCHA/hillel_jewish_students.csv") -> hillel

# USE THE fastLink R PACKAGE TO PERFORM THE RECORD LINKAGE WORK
matches.out <- fastLink(
  dfA = distinct(amcha, school = university,
                 id = university_id),
  dfB = distinct(hillel, school, id = url),
  varnames = c("school"),
  stringdist.match = c("school"),
  partial.match = c("school")
)

map_dfr(1:nrow(matches.out$matches), function(x) {
  school_amcha = distinct(amcha, school_amcha = university) %>%
    slice(matches.out$matches[x, ]$inds.a)
  
  school_hillel = distinct(hillel, school_hillel = school) %>%
    slice(matches.out$matches[x, ]$inds.b)
  
  return(data.frame(school_amcha,
                    school_hillel))
}) -> match_tbl

write.csv(
  match_tbl,
  "C:/Users/benjr/Desktop/Projects/AMCHA/fastLink_schools.csv",
  row.names = FALSE
)
