#!/bin/sh
rsync -avu --delete ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/xuan/Blog/ ~/VSCodeProjects/zhaohongxuan.github.io/source/_posts/
cd ~/VSCodeProjects/zhaohongxuan.github.io/
git checkout src --force
git add . 
git commit -m "Commit from Obsidian" 
git push
