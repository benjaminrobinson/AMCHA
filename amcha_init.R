#### SCRAPE AMCHA INITIATIVE ANTISEMITISM DATASET ####
library(httr)
library(jsonlite)
library(stringr)
library(dplyr)
library(tidyr)
library(purrr)

# 'https://amchainitiative.org/search-by-incident/'
# GO TO CURLCONVERTER.COM AND FOLLOW INSTRUCTIONS TO GET R CODE BELOW



res <- purrr::map_dfr(1:6, function(x) {
  Sys.sleep(5)
  httr::GET(
    url = "https://us-east-1-renderer-read.knack.com/v1/scenes/scene_164/views/view_279/records",
    httr::add_headers(
      .headers = c(
        `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0",
        `Accept` = "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01",
        `Accept-Language` = "en-US,en;q=0.5",
        `Accept-Encoding` = "gzip, deflate, br",
        `X-Knack-Application-Id` = "5b39a57db48a6b2ec0cc0ded",
        `X-Knack-REST-API-Key` = "renderer",
        `x-knack-new-builder` = "true",
        `X-Requested-With` = "XMLHttpRequest",
        `DNT` = "1",
        `Connection` = "keep-alive",
        `Referer` = "https://us-east-1-renderer-read.knack.com/api/xdc.html?xdm_e=https^%^3A^%^2F^%^2Famchainitiative.org&xdm_c=default4146&xdm_p=1",
        `Cookie` = "connect.sid=s^%^3AQxNZUckuvlubnF3FVLfKMg7awbLYQ8fN.rErU8JXvDzDRHEwpvKqF9A309^%^2Bk^%^2FU06sJQgwpfe^%^2BpEM",
        `Sec-Fetch-Dest` = "empty",
        `Sec-Fetch-Mode` = "cors",
        `Sec-Fetch-Site` = "same-origin"
      )
    ),
    query = list(
      `callback` = "jQuery172049763621919657164_1690648220793",
      `format` = "both",
      `page` = x,
      `rows_per_page` = "1000",
      `sort_field` = "field_7",
      `sort_order` = "desc",
      `_` = "1690649158085"
    )
  ) %>%
    httr::content() %>%
    stringr::str_extract("\\{.*\\}") %>%
    jsonlite::fromJSON() %>%
    purrr::pluck("records") %>%
    dplyr::as_tibble() %>%
    dplyr::select(-c(field_36, field_7, field_178)) %>%
    tidyr::unnest(cols = c(field_36_raw, field_7_raw),
                  names_repair = 'unique') %>%
    setNames(
      c(
        'incident_id',
        'university_id',
        'university',
        'date',
        'date_formatted',
        'hours',
        'minutes',
        'am_pm',
        'unix',
        'iso',
        'timestamp',
        'time',
        'report_text'
      )
    )
})

#### INDIVIDUAL PAGE HERE ####
# https://amchainitiative.org/search-by-incident/#incident/display-by-date/details/64bfebb568b64600283d2efa/
# GO TO CURLCONVERTER.COM AND FOLLOW INSTRUCTIONS TO GET R CODE BELOW

res2 <- purrr::pmap_dfr(list(res$incident_id), function(x) {
  # Sys.sleep(5)
  httr::GET(
    url = paste0(
      "https://us-east-1-renderer-read.knack.com/v1/scenes/scene_165/views/view_280/records/",
      x,
      "?callback=jQuery172029654661694338635_1690650925368&scene_structure^%^5B^%^5D=scene_119&scene_structure^%^5B^%^5D=scene_164&_=1690650925420"
    ),
    httr::add_headers(
      .headers = c(
        `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0",
        `Accept` = "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01",
        `Accept-Language` = "en-US,en;q=0.5",
        `Accept-Encoding` = "gzip, deflate, br",
        `X-Knack-Application-Id` = "5b39a57db48a6b2ec0cc0ded",
        `X-Knack-REST-API-Key` = "renderer",
        `x-knack-new-builder` = "true",
        `X-Requested-With` = "XMLHttpRequest",
        `DNT` = "1",
        `Connection` = "keep-alive",
        `Referer` = "https://us-east-1-renderer-read.knack.com/api/xdc.html?xdm_e=https^%^3A^%^2F^%^2Famchainitiative.org&xdm_c=default5958&xdm_p=1",
        `Cookie` = "connect.sid=s^%^3AIeyyy6GfHDZpJVkv6g0pOsRkMQ5muxVW.eMz6KApejsJ0U9lAx^%^2Fc1mJAHrjCoqYWrnr3FmBMruQU",
        `Sec-Fetch-Dest` = "empty",
        `Sec-Fetch-Mode` = "cors",
        `Sec-Fetch-Site` = "same-origin",
        `TE` = "trailers"
      )
    )
  ) %>%
    httr::content() %>%
    stringr::str_extract("\\{.*\\}") %>%
    jsonlite::fromJSON() %>%
    {
      purrr::map(c(1, 5, 6), function(x) {
        purrr::pluck(., x)
      }) %>%
        unlist %>%
        data.frame(
          "incident_id" = .[1],
          "incident_category" = .[2],
          "incident_classification" = .[3]
        ) %>%
        dplyr::select(-1) %>%
        dplyr::distinct()
    }
})

res %>%
  dplyr::left_join(res2, by = 'incident_id') %>%
  write.csv("C:/Users/benjr/Desktop/Projects/AMCHA/amcha_init.csv",
            row.names = FALSE)
