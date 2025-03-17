find . -type f -name "*.html" -exec sed -i "s|<script[^>]*polyfill[.]min[.]js[?]features=es6\"></script>||g; s|<script[^>]*tex-mml-chtml[.]js\"></script>||g" {} +
