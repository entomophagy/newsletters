#!/usr/bin/env bash

set -euo pipefail

wget --recursive --accept .pdf https://www.entomophagy.or.jp/newsletter
rm -f ./*.pdf
mv www.entomophagy.or.jp/_files/ugd/*.pdf ./
rm -rf www.entomophagy.or.jp
./renamePdfs.swift

git add .
git commit -m "Update PDFs"
git push origin main
