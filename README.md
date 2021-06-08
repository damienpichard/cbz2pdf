<div align="center">

# cbz2pdf

[Introduction](#introduction) • [Installation](#installation) • [Contribute](#contribute)

[![BSD-3-Clause License](https://img.shields.io/badge/LICENSE-BSD--3--Clause-red?style=for-the-badge)](./LICENSE)

</div>



## Introduction
[cbz2pdf] is a ruby script that converts `cbz` (and `cbr` with [unrar]) files to `pdf`.



## Prerequisite
If you want to use this script for `cbr` files, please make sure you have `unrar` installed:

``` sh
$ brew install unrar # On macOS
$ apt-get install unrar # On Ubuntu
```


In order to convert images into `pdf` this script also requires [img2pdf].



## Installation
``` sh
$ git clone --depth 1 https://github.com/lebidouilleur/cbz2pdf.git
$ cd cbz2pdf
$ bundle install # install dependencies
```



## Contribute




[cbz2pdf]: https://github.com/lebidouilleur/cbz2pdf
[unrar]:   https://www.rarlab.com/
[img2pdf]: https://github.com/myollie/img2pdf
