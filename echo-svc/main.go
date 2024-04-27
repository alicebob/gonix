package main

import (
	"fmt"
	_ "net/http"

	_ "cloud.google.com/go/pubsub"
	_ "github.com/gorilla/sessions"
)

func main() {
	fmt.Printf("hi!\n")
}
