##BencharkThrift

**BenchmarkThrift**是一款测试Thrift应用程序性能的工具，提供开箱即用的压测功能。
> [README in English](README_EN.md)

##特点

 *简洁的使用方式：用户仅仅需要使用简单的命令，就可以实现发压。不需要用户有任何代码开发能力  

 *Thrift版本兼容：工具支持Thrift从0.9.0到0.12.0的所有版本，可以通过修改配置文件完成版本的指定  

 *两种类型的压力：工具不仅支持以并发度的方式进行发压，还可以以固定吞吐量的形式进行测试  

##环境要求

如果想工具运行起来，您需要满足以下条件：

 * ##JAVA环境：

需要一个完全兼容的Java 8运行环境来执行工具。

 * ##idl生成的jar包：

用户需要跟据idl生成相应的jar包，然后将jar路径在配置文件中配置好
```bash
    thrift -r --gen java xxx.thrift #通过命令生成相应的java文件
    sh JG.sh version java_path jar_path  #version: 指定thrift版本，java_path:指定执行完上条命令所生成的java文件夹路径，jar_path:指定最终的jar包的位置和名称
```        
##安装说明

注意目录名中的空格可能会导致问题。


##如何运行

确保已正确配置java运行环境，然后：

```bash
    echo $JAVA_HOME             # 应该打印您的Java home目录。如果命令失败，则需要安装Java环境。Java下载 https://www.oracle.com/technetwork/java/javase/downloads/index.html
    cd benchmark-thrift
    chmod 755 *.sh              # 修改权限，确保命令是可执行的
    sh BT.sh -c 10 -D 100s -p ./demo.properties -d ./demo.txt 127.0.0.1:8090/Test/test # 如果持续时间和压力类型没有指定，会默认按照1个并发的强度进行1分钟测试
```

####最简单的用法
```bash
    sh BT.sh -p <thriftConf.properties> -d <data.conf> [ -c concurrency ] [ -n requests ] [options] url
```

####参数选项

 * -p xx.properties  

与thrift相关的配置，包括TTransport、TProtocol、thrift版本和生成的jar包的位置。文件格式限制为.properties文件

* ######示例

version=0.12.0  

classpath=/users/didi/test.jar  

transport=TFramedTransport（transport=tSocket）  

protocol=TCompactProtocol必需，选项：TBinaryProtocol，TJSONProtocol

*-d data.conf文件

方法中使用的参数。在文件中，每一行表示方法的一个参数

*######示例

#如果方法测试有4个参数，则类型为i64、list、struct和string。数据文件内容应如下：

一百二十三

〔2〕、“3”〕

{“name”：“value”，“utype”：“uvalue”}

一串

*-C并发

一次要发出的多个请求的数目

*-Q吞吐量

1秒内发出的请求数

*-D持续时间

压力会持续多少秒。默认值为60。您可以通过以下方式指定持续时间：

-d 10-d 10s-d10s秒

*-V

打印版本号

*-H

显示使用信息




##贡献

欢迎通过创建问题或发送拉取请求作出贡献。有关指南，请参阅贡献指南。



许可证

Thrift Mock是根据ApacheLicense2.0授权的。请参阅许可证文件。



第二音符

这不是一个正式的didi产品（实验性的或其他的），它只是代码碰巧属于didi。



感谢您使用基准节俭