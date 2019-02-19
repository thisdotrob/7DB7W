gem install -N libxml-ruby couchrest

zcat dbdump_artistalbumtrack.xml.gz | ruby import_from_jamendo.rb
