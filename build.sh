rm -rf dist
mkdir dist
elm-make main.elm --output dist/main.js
cp index.html dist/
cp -r graphics dist/graphics
echo '*' > dist/CORS
# sed -i.bak 's/>Main</>SKYCOINS 🚁💰</' index.html
