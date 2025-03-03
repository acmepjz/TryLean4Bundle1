cd "$1"
find . -type f -name "*.lean" -exec sed -i "s/^import $1/import LeanPlayground.$1/g" {} +
cd ..
