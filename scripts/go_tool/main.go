package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
)

func organizeFiles(src string, dry bool) {
	filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() {
			ext := filepath.Ext(path)
			folder := ""

			switch ext {
			case ".jpg", ".png":
				folder = "Images"
			case ".txt", ".pdf":
				folder = "Docs"
			case ".mp4", ".mov":
				folder = "Videos"
			default:
				folder = "Others"
			}

			dest := filepath.Join(src, folder, info.Name())
			if dry {
				fmt.Println("Would move:", path, "->", dest)
			} else {
				os.MkdirAll(filepath.Join(src, folder), os.ModePerm)
				os.Rename(path, dest)
			}
		}
		return nil
	})
}

func main() {
	srcDir := flag.String("src", ".", "Source directory to organize")
	dryRun := flag.Bool("dry", false, "Run without making changes")
	flag.Parse()

	fmt.Println("Source dir:", *srcDir)
	fmt.Println("Dry run:", *dryRun)

	organizeFiles(*srcDir, *dryRun)
}
