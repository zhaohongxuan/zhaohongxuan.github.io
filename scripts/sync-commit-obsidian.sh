#!/bin/sh
rsync -avu --delete ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/xuan/Blog/ ~/VSCodeProjects/zhaohongxuan.github.io/source/_posts/
cd ~/VSCodeProjects/zhaohongxuan.github.io
git checkout src --force
hexo server
open 'http://localhost:4000'
