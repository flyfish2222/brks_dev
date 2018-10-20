## brks_dev 介绍


### 1. 工程介绍
　　该工程用于构建`brks` 项目集成环境（即：Docker 镜像）


### 2. 安装Docker
　　参考地址：[http://www.runoob.com/docker/docker-tutorial.html)](http://www.runoob.com/docker/docker-tutorial.html)


### 3. 镜像使用
**第一步：下载镜像**
```
docker pull flyfish2222/brks_dev
```

**第二步：运行容器**
```
docker run -it --name brks_dev --privileged -p3306:3306 -p9090:9090 flyfish2222/brks_dev
```


### 4. brks 测试
**第一步：启动 mysql 服务**
```
service mysql start
```

**第二步：启动brks 服务**
```
./src/brks ./conf/log.conf &
```

**第三步：修改测试脚本test.lua**
- 修改brks 服务地址为`127.0.0.1`
```
local opt = {
	host      = '127.0.0.1',
	port      = '9090',
	protocol  = TCompactProtocol,
	transport = TFramedTransport
}
```

- 修改手机号
```
local r = client:brk_get_mobile_code('你的手机号')
```

**第四步：运行测试脚本**
```
cd test/
lua ./test.lua

200
success
```


### 5. brks 镜像地址
  brks 镜像地址：[https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page=1&pullCount=0&q=flyfish2222&starCount=0](https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page=1&pullCount=0&q=flyfish2222&starCount=0)
