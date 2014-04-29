// Via http://hecticjeff.net/2013/07/17/golang-static-http-file-server/
package main

import (
    "flag"
    "fmt"
    "net/http"
)

var port = flag.String("port", "9292", "Define what TCP port to bind to")
var root = flag.String("root", ".", "Define the root filesystem path")

func main() {
    flag.Parse()
    fmt.Printf("Serving %v on port %v\n",*root,*port)
    panic(http.ListenAndServe(":"+*port, http.FileServer(http.Dir(*root))))
}