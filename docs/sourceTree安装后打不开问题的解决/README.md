# sourceTree安装后打不开问题的解决

## **快速寻找的方法**

你可以在 软件快捷方式 **右键打开文件所在位置**，然后回退一下到 `Local`文件夹然后进入`Atlassian`文件夹

或者直接在**文件夹地址栏**输入：

```txt
%localappdata%\Atlassian\
```

然后进入类似`SourceTree.exe_Url_nf12znmaeznytulsuzeaz22lpprrbpo3`

的文件夹

## 第一种方案

`%localappdata%\Atlassian\SourceTree.exe_Url_nf12znmaeznytulsuzeaz22lpprrbpo3\版本号`路径下的`Composition.cache` 文件删除然后重新启动就好了

## 第二种方案

删除

`%localappdata%\Atlassian\SourceTree.exe_Url_nf12znmaeznytulsuzeaz22lpprrbpo3`

对应的`SourceTree.exe_Url_nf12znmaeznytulsuzeaz22lpprrbpo3`文件然后重新启动就可以了

## 第三种方案

`%localappdata%\Atlassian\SourceTree.exe_Url_nf12znmaeznytulsuzeaz22lpprrbpo3\版本号`下有一个`user.config` 配置文件，然后把下方代码添加进入，然后重启就可以了

```xml
<setting name="AutomaticallyCleanUpDictionaryFiles" serializeAs="String">
      <value>True</value>
</setting>
```

## 第四种方案

**在目录里面去启动程序**
`%localappdata%\SourceTree\app-XXX`下找到SourceTree.exe点击启动了sourceTree,开始了熟悉的登录流程，回到了熟悉的代码管理界面。

## 第五种方案

**下载以前版本的SourceTree**

链接：https://pan.baidu.com/s/1n2nCixI5vWwa-ZbvAut36A?pwd=52kd 
提取码：52kd 
