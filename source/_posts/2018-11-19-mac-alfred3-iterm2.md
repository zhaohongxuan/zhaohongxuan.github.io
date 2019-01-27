---
title: 让Alfred3支持iterm2
date: 2018-11-19 21:41:42
tags: Mac Alfred iterm2
category: Mac
---

alfred设置中选择`Terminal/Shell`，Application选择custom
![image.png](https://upload-images.jianshu.io/upload_images/170138-bd4f2a0ffd10fc3a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

<!-- more-->
然后在下面的框中填入下面代码：

```applescript
-- This is v0.7 of the custom script for AlfredApp for iTerm 3.1.1+
-- created by Sinan Eldem www.sinaneldem.com.tr

on alfred_script(q)
	if application "iTerm2" is running or application "iTerm" is running then
		run script "
			on run {q}
				tell application \"iTerm\"
					activate
					try
						select first window
						set onlywindow to true
					on error
						create window with default profile
						select first window
						set onlywindow to true
					end try
					tell the first window
						if onlywindow is false then
							create tab with default profile
						end if
						tell current session to write text q
					end tell
				end tell
			end run
		" with parameters {q}
	else
		run script "
			on run {q}
				tell application \"iTerm\"
					activate
					try
						select first window
					on error
						create window with default profile
						select first window
					end try
					tell the first window
						tell current session to write text q
					end tell
				end tell
			end run
		" with parameters {q}
	end if
end alfred_script

```