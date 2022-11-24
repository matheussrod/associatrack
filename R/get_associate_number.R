

# Functions ---------------------------------------------------------------

get_associate_number <- function(club, url, xpath) {
  html <- rvest::read_html(x = url)
  datetime <- format(Sys.time(), tz = 'America/Fortaleza')
  html_node <- rvest::html_node(html, xpath = xpath)
  html_text <- rvest::html_text(html_node)
  format_number <- as.integer(sub('\\.', '', html_text))
  df <- data.frame('data' = datetime, 'club' = club, 'associate' = format_number)
  return(df)
}

bigquery_authentication <- function() {
  key <- create_key(x = Sys.getenv('ASSOCIATRACK_PASSWORD'))
  nonce <- create_nonce()
  input <- here::here('inst/secret/associatrack.json')
  bin_json <- readBin(input, 'raw', file.size(input))
  token <- decrypt(bin_json, key, nonce)
  bigrquery::bq_auth(path = token)
}


# Code --------------------------------------------------------------------

bigquery_authentication()

club_associate_number <- bigrquery::bq_table(
  project = 'associatrack', 
  dataset = 'club_associate', 
  table = 'club_associate_number'
)

configs <- yaml::read_yaml(here::here('configs.yaml'))
lapply(
  X = configs, 
  FUN = function(x) {
    df <- get_associate_number(x$name, x$url, x$xpath)
    bigrquery::bq_table_upload(club_associate_number, df, write_disposition = 'WRITE_APPEND')
  }
)
