//go:build admindist

package v1

import (
	"embed"
	"io/fs"
	"log"
)

//go:embed all:admin_dist
var adminDistEmbed embed.FS

func init() {
	sub, err := fs.Sub(adminDistEmbed, "admin_dist")
	if err != nil {
		log.Fatal(err)
	}
	adminDistFS = sub
}
