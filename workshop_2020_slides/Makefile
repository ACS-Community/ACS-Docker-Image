all:
	pandoc -t slidy -s slides.md -o slides.htm
	sed 's@http://@https://@g' slides.htm > index.html


