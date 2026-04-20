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

.onLoad <- function(libname, pkgname){
  if(grepl('emscripten', R.version[['platform']])){
    set_default_wsproxy()
  }
}

# Set a default ws-proxy server for WebR
# Note socks proxies are secure as the https connections going over the socks5
# are still encrypted and verified.
set_default_wsproxy <- function(){
  proxy <- Sys.getenv('ALL_PROXY')

  # TODO: fix this unfortunate default envvar in webR
  if(proxy == "socks5h://localhost:8580"){
    Sys.unsetenv('ALL_PROXY')
    proxy <- ""
  }

  if(proxy == ''){
    try({
      # Note the websocket runs wss (port 443) but inside we use plain http:// for curl
      h <- new_handle(connecttimeout = 2)
      req <- curl_fetch_memory("http://get-ws-proxy.jeroenooms.workers.dev:443/", handle = h)
      if(req$status == 200){
        wsproxy <- rawToChar(req$content)
        if(grepl('^socks5h://', wsproxy)){
          Sys.setenv(ALL_PROXY = wsproxy)
        }
      }
    })
  }
}
