//go:build !admindist

package v1

import (
	"embed"
	"io/fs"
	"log"
)

//go:embed all:admin_stub
var adminStubEmbed embed.FS

func init() {
	sub, err := fs.Sub(adminStubEmbed, "admin_stub")
	if err != nil {
		log.Fatal(err)
	}
	adminDistFS = sub
}
