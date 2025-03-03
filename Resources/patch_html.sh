sed -i "s|<script[^>]*polyfill[.]min[.]js[?]features=es6\"></script>||g" "$1"
sed -i "s|<script[^>]*tex-mml-chtml[.]js\"></script>||g" "$1"
