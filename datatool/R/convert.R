#' Convert package data to various formats
#'
#' Wrapper for r-universe data export tool. The data import functions are copied
#' from utils::data(), reading supoprted types and also lazydata databases.
#'
#' @export
#' @rdname datatool
#' @param input filename of input data. Can be lazyload datbase.
#' @param name data name to import
#' @param format what format to export to
#' @param output filename to write output to
convert <- function(input, name, format, output){
  env <- load_data_env(input, name)
  save_data(name, env, format, output)
  rm(env)
}

load_data_env <- function(filename, name){
  env <- new.env(parent = emptyenv())
  ext <- tolower(fileExt(filename))
  switch(ext,
         rdb =, rdx =
           lazyLoad(sub('\\.rd.', '', filename), envir=env, filter=function(x) x==name),
         rdata = , rda =
           load(filename, envir = env),
         txt = , tab = , tab.gz = , tab.bz2 = , tab.xz = , txt.gz = , txt.bz2 = , txt.xz =
           assign(name, my_read_table(filename, header = TRUE, as.is = FALSE), envir = env),
         csv = , csv.gz = , csv.bz2 = , csv.xz =
           assign(name, my_read_table(filename, header = TRUE, sep = ";", as.is = FALSE), envir = env),
         stop("Unsupported data type: ", filename))
  env
}


save_data <- function(name, env, format, output){
  df <- get(name, env)
  format <- match.arg(tolower(format), c('csv', 'csv.gz', 'xlsx', 'json', 'ndjson', 'rda', 'rds'))
  switch(format,
         csv = data.table::fwrite(df, output),
         csv.gz = data.table::fwrite(df, output, compress='gzip'),
         xlsx = writexl::write_xlsx(df, output),
         json = jsonlite::write_json(df, output, force = TRUE),
         ndjson = jsonlite::stream_out(df, file(output), force = TRUE, verbose = FALSE),
         rds = saveRDS(df, output),
         rda = save(list=name, envir = env, file = output),
         stop("Wrong format: ", format)
  )
}


# Functions copied from utils::data
my_read_table <- function(...) {
  # Jeroen: This seems always 'C' for webr
  #lcc <- Sys.getlocale("LC_COLLATE")
  #on.exit(Sys.setlocale("LC_COLLATE", lcc))
  #Sys.setlocale("LC_COLLATE", "C")
  utils::read.table(...)
}

fileExt <- function(x) {
  db <- grepl("\\.[^.]+\\.(gz|bz2|xz)$", x)
  ans <- sub(".*\\.", "", x)
  ans[db] <- sub(".*\\.([^.]+\\.)(gz|bz2|xz)$", "\\1\\2",
                 x[db])
  ans
}
