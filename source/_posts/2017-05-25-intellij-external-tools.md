
java工程师平时工作中用到的工具挺多的，比如javap,jstack等，intellij idea 作为宇宙最强java ide idea一样可以帮我们实现这个功能，方法如下：

`ctrl+alt+s`打开设置界面,找到`Tool-> External Tools` 点击 `+`来增加一个新的外部工具。

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/170138-78fbc6c74f8bc0fc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

<!-- more -->
在tool setting 的Program输入工具的路径，这中间可以插入宏，比如`$JDK_PATH$`，不需要自己再手动输入jdk的路径了，
在Parameters中输入`-c $FileClass$` ，`$FileClass$`代表要解析的 class文件,`-c`代表输出分解后的代码
在Workding Directory中输入`$OutputPath$`,代表项目的输出路径

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/170138-9baca2b1bacea044.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在java文件上右键，选择`External Tools -> javap`就可以输入分解后的代码了，也可以自定义快捷键，比如设置`alt+p`就可以很方便的使用javap这个工具了，其他的工具和这个类似，都可以很方便的添加到External Tool里
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/170138-e8d459f2de49deee.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
