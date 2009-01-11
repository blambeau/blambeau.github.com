export $CODE=/home/blambeau/revision-zero/code/ruby/web_duck_typing
export $SOURCE=/home/blambeau/revision-zero/articles
export $TARGET=/home/revision-zero/public_html/statics
export $BASE=http://www.revision-zero.org/

$CODE/genrevzero.rb --verbose --single $SOURCE/404.r0 $TARGET/404.html --template $SOURCE/404.wtpl -Sbase=$BASE
$CODE/genrevzero.rb --verbose --from $SOURCE --to $TARGET --template $SOURCE/template.wtpl -Sbase=$BASE
