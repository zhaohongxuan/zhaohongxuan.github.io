---
title: 上海马拉松自动签到工具
date: 2023-11-05 09:22
tags: 跑步
category: 工具效率
---

![254017014-2ea91157-452f-4113-887b-a6de8e14cf08-2](https://github.com/zhaohongxuan/shangma_auto_sign/assets/8613196/702b57e1-eb15-4acb-b0ab-8cab448c6003)

前端时间写的[上海马拉松自动签到工具](https://github.com/zhaohongxuan/shangma_auto_sign)已经完成很久了，有不少跑友都反映上马抽中了，而我也在经历了8年没中之后，今年很“幸运”的抽中了上海马拉松了，开心之情溢于言表，于是便想写一些内容来记录一下这个过程。

![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/202311152303984.png)



上海马拉松在中国应该算是顶级的马拉松赛事了，对于每一位跑者都意义非凡，对我来说，我一直想要跑一次上马，然而从15年开始抽签，一直抽到2022年，一直都没中，于是在小红书上看一些攻略，发现有人说上马积分对于抽签比重占的很大，尤其是当年度的积分，由于积分只能通过跑步、签到、以及赛事获取，我打算从签到和跑步来实现我攒积分的目标，其中跑步我已经在前面的文章中写过了，可以将Apple Watch同步到Strava再同步到Garmin，然后同步到数字心动，再到上马来获取积分。

<!-- more-->

那么签到呢？在我签过几次到之后我想能否实现一个自动化的签到程序，从而避免自己天天手动签到呢？虽然积分很少，但是日积月累也是相当可观的，一年也有365积分，相当于参加两次线下比赛了。

于是开始着手开始做，首先要研究上马的API，最简单的想法就是，获取Cookie，然后调用签到接口直接签到即可，或者使用OAuth认证拿到Token即可。嗯，想法确实不错，事实上也的确如此，只不过上马所有的API都有加密，然后后端验签，因此我使用Python写的脚本根本不能用，因为没有找到加密的方法以及密钥。所以我打算转而使用Javascript来实现，因为所有的Client加密应该都能拿到加密方法以及密钥，所以我在混淆过后的js代码debug，找到了sign的方法，直接将几个参数拼接，然后调用sign方法即可。
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/202311152244882.png)
当然，这样必须依赖Cookie，然而第一个版本是可以正常work的。

接下来要进行优化的就是使用用户名和密码进行登录签到，这样就涉及到了加密，于是我又仔细的debug了Login时的js代码，发现加密过程中的的nonstr是不变的，nonstr就是用来生成加密时的Key和初始向量（IV），有了它们，加解密也就可以轻松完成了。
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/202311152250830.png)，

加解密代码：

```js
export function encrypt(word) {
  var srcs = CryptoJS.enc.Utf8.parse(word)
  var encrypted = CryptoJS.AES.encrypt(srcs, key, {
    iv: iv,
    mode: CryptoJS.mode.CBC,
    padding: CryptoJS.pad.Pkcs7
  })
  const encryptTxt = encrypted.ciphertext.toString()
  const hexString = CryptoJS.enc.Hex.parse(encryptTxt)
  return CryptoJS.enc.Base64.stringify(hexString)
}
export function decrypt(encryptWord) {
  var wordArray = CryptoJS.enc.Base64.parse(encryptWord)
  const encryptedCiphertext = CryptoJS.enc.Hex.stringify(wordArray)

  const encrypted = CryptoJS.lib.CipherParams.create({
    ciphertext: CryptoJS.enc.Hex.parse(encryptedCiphertext)
  })

  var decrypt = CryptoJS.AES.decrypt(encrypted, key, {
    iv: iv,
    mode: CryptoJS.mode.CBC,
    padding: CryptoJS.pad.Pkcs7
  })
  var decryptedStr = decrypt.toString(CryptoJS.enc.Utf8)
  return decryptedStr.toString()
}
```
