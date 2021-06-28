## moebooru-crawler

GNU Bash script to download images from moebooru-based sites, like yande.re and konachan.com .

## Usage

```
Usage: moebooru-crawler URL [ -d | --dir DIR ]
                            [ -n | --num NUM ]
                            [ -u | --urls-only ]
                            [ -p | --max-procs PROCS ]
```

Feed the crawler a interesting URL, then it'll start downloading:

```sh
$ ./moebooru-crawler.sh "https://yande.re/post?tags=coffee-kizoku+order%3Ascore"
```

Or if you just want URLs of images instead of downloading them, use `-u`:

```sh
$ ./moebooru-crawler.sh "https://yande.re/post?tags=coffee-kizoku+order%3Ascore" -u >>downloads.txt
```

Then you can use aria2c or any tools you like to do downloads.

To get more images, use `-n` to limit the number (only when the URL has more than one page, note that the crawler will start from first page):

```sh
$ ./moebooru-crawler.sh "https://yande.re/post?page=2&tags=coffee-kizoku" -n 100  # "page=2" will be ignored
```

Or use a large number to get all pages:

```sh
$ ./moebooru-crawler.sh "https://yande.re/post?tags=coffee-kizoku" -n 10000
```

Use `-p` to specify max curl processes when downloading images (default: 8):

```sh
$ ./moebooru-crawler.sh "https://yande.re/post?tags=coffee-kizoku+order%3Ascore" -p 16
```
