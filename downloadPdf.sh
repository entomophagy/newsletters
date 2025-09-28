wget --recursive --accept .pdf https://www.entomophagy.or.jp/newsletter

rm ./*.pdf
mv www.entomophagy.or.jp/_files/ugd/*.pdf ./

rm -rf www.entomophagy.or.jp

git add .
git commit -m "Update PDFs"
git push origin main
