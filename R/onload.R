.onAttach <- function(libname, pkgname){
  version <- curl_version()
  ssl <- sub("\\(.*\\)\\W*", "", version$ssl_version)
  msg <- paste("Using libcurl", version$version, "with", ssl)
  packageStartupMessage(msg)
  if(grepl("redhat", R.version$platform) && !('smtp' %in% version$protocols)){
    packageStartupMessage(c("Your system runs libcurl-minimal which does not support all protocols: ",
                          "See also https://github.com/jeroen/curl/issues/350"))
  }
  try({
    proxy <- Sys.getenv('ALL_PROXY')
    if(nchar(proxy)){
      proxy_info <- curl::curl_parse_url(proxy)
      packageStartupMessage(sprintf("Using proxy server %s://%s:%s",
        proxy_info$scheme, proxy_info$host, proxy_info$port))
    }
  }, silent = TRUE)
}
