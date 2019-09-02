#### Automated and Reproducible http://bioruby.surge.sh/ update with [rubydown](https://github.com/sciruby-jp/rubydown) + Travis
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/bioruby/documents/master)
[![Build Status](https://travis-ci.org/bioruby/documents.svg?branch=master)](https://travis-ci.org/bioruby/documents)

# rubydown installation
```
git clone git://github.com/sciruby-jp/rubydown
cd rubydown
rake build
rake install
```

# Converting (and executing) rbmd to html
```
/usr/local/bundle/bin/rubydown -i INPUTRBMD -e YOURERB -o OUTPUT
```
