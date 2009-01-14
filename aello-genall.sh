CODE=/home/blambeau/revision-zero/code/ruby/web_duck_typing
SOURCE=/home/blambeau/revision-zero/articles
SRC_PUBLIC=/home/blambeau/revision-zero/public
TARGET=/home/revision-zero/public_html/statics
TRG_PUBLIC=/home/revision-zero/public_html
BASE=http://www.revision-zero.org/

cp $SRC_PUBLIC/.htaccess $TRG_PUBLIC
$CODE/genrevzero.rb --verbose --from $SOURCE --to $TARGET --single $SOURCE/404.r0 $TARGET/404.html --template $SOURCE/404.wtpl -Sbase=$BASE
$CODE/genrevzero.rb --verbose --from $SOURCE --to $TARGET --template $SOURCE/template.wtpl -Sbase=$BASE
