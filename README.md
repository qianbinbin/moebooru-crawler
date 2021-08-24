## moebooru-crawler

Retrieve links of images from moebooru-based sites, like yande.re and konachan.com .

## Usage

```
Usage: moebooru-crawler URL [ -n NUM, --num=NUM ]

  -n NUM, --num=NUM         print NUM links of images,
                            or print all if NUM is '0'
```

Feed the crawler a URL to retrieve links:

```sh
$ moebooru-crawler.sh "https://yande.re/post?tags=coffee-kizoku+order%3Ascore"
```

All the links will be printed to stdout. Or you can redirect to a file:

```sh
$ moebooru-crawler.sh "https://yande.re/post?tags=coffee-kizoku+order%3Ascore" >>links.txt
```

Then use aria2c or any tools you like to do downloads.

Use `-n NUM` to print NUM links (only when the URL has more than one page, note that the crawler will start from first page):

```sh
$ moebooru-crawler.sh "https://yande.re/post?page=2&tags=coffee-kizoku" -n 100  # "page=2" will be ignored
```

Use `-n 0` to get all links:

```sh
$ moebooru-crawler.sh "https://yande.re/post?tags=coffee-kizoku" -n 0
```
