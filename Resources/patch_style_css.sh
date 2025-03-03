sed -i "s|^[@]import url[(]'https.*lato-font[.]min[.]css'[)];\$|@import url('lato-font/css/lato-font.min.css');|g" "$1"
sed -i "s|^[@]import url[(]'https.*juliamono[.]css'[)];\$|@import url('juliamono/webfonts/juliamono.css');|g" "$1"
