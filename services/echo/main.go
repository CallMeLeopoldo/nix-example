package main

import (
	"fmt"
	"os"
)

func main() {
	ok := os.Getenv("PWD")
	fmt.Println("Testing the value from PWD inside nix")
	if ok != "" {
		fmt.Println(ok)
	}

	fmt.Println("no env variable detected")
}
