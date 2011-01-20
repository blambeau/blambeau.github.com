# Revision-zero.org

This is the sources of my blog, www.revision-zero.org. Feel free to fork this project, under the licencing terms described below.

# Generating the blog

This blog is a static website generated using the powerful [wlang](https://github.com/blambeau/wlang) templating engine, which allows me to generate different versions of the website for different purposes. I explained the approach on the blog itself, see [http://revision-zero.org/book](http://revision-zero.org/book). You generate the different versions using the following commands:

    # will generate output/revision-zero.html
    ruby handlers/allinone.rb
    
    # will generate a clean static version of the website
    ruby handlers/static.rb

    # will generate a clean dynamic version of the website running on 
    # http://127.0.0.1:4567. This is the the one I use to write my posts 
    # easily
    ruby handlers/sinatra.rb

## Licence

Unless stated explicitely, all ideas written here are the intellectual property of Bernard Lambeau. All text material is under a [Creative Commons Licence 2.0](http://creativecommons.org/licenses/by/2.0/be/contract). Unless stated explicitely, short code excerpts appearing here may be used freely, but are given without ABSOLUTELY NO WARRANTY. Source code (clearly indicated as being) extracted from a given implementation project of the present author remains under the same licence as the project it is extracted from (often [GPL](http://www.gnu.org/licenses/gpl.html), [LGPL](http://www.gnu.org/licenses/lgpl.html) or [MIT](http://www.opensource.org/licenses/mit-license.php)). 