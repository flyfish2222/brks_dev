FROM flyfish2222/brks_dev:base


# 1. 将资源复制到镜像
COPY ./package/ /root/package
COPY ./package/brks-master.zip /root/
COPY ./config/vimrc /root/.vimrc
COPY ./config/bashrc /root/.bashrc
COPY ./config/sources.list /etc/apt/sources.list
COPY ./config/mysql.sql /root/mysql.sql


# 2. 安装构建过程中需要的必要工具
RUN apt-get update
RUN apt-get install -y gcc g++
RUN apt-get install -y tar make cmake automake zip python


# 3. 设置构建工作目录
WORKDIR /root


# 4. 安装log4cpp
RUN cd package/ && tar -zxvf log4cpp-1.1.2.tar.gz && cd log4cpp && ./configure && make && make install


# 5.1 安装jsoncpp 需要的环境scons
RUN cd package/ && tar -zxvf scons-2.1.0.tar.gz && cd scons-2.1.0 && python setup.py install

# 5.2 安装jsoncpp
RUN cd package/ && tar -zxvf jsoncpp-src-0.5.0.tar.gz && cd jsoncpp-src-0.5.0 && scons platform=linux-gcc && cp libs/linux-gcc-7/libjson_linux-gcc-7_libmt.* /usr/local/lib/ && cp ./include/json/ /usr/local/include/ -rf


# 6.1 安装lua 需要的环境readline
RUN cd package/ && tar -zxvf readline-6.2.tar.gz && cd readline-6.2 && ./configure && make && make install

# 6.2 安装lua 需要的环境ncurses
RUN cd package/ && tar -zxvf ncurses-4.2.tar.gz && cd ncurses-4.2 && ./configure && make && make install

# 6.3 安装lua
RUN cd package/ && tar -zxvf lua-5.2.0.tar.gz && cd lua-5.2.0 && make linux && make install

# 6.4 编译lua 共享库
RUN cd package/lua-5.2.0/src && rm luac.c && gcc *.c -fPIC -shared -o liblua.so && mv liblua.so /usr/local/lib/


# 7.1 安装thrift 需要的环境
RUN cd package/ && apt-get install -y libtinyxml-dev libboost-dev libboost-test-dev libevent-dev python-dev libltdl-dev libssh-dev

# 7.2 拷贝资源到指定目录
RUN cp /usr/lib/x86_64-linux-gnu/libboost_unit_test_framework.a /usr/local/lib/libboost_unit_test_framework.a

# 7.3 安装thrift
RUN cd package/ && tar -zxvf thrift-0.11.0.tar.gz && cd thrift-0.11.0 && ./configure --with-boost=/usr/local && make
RUN cp /root/package/thrift-0.11.0/lib/lua/.libs/liblualongnumber.so /usr/local/lib/
RUN cd package/thrift-0.11.0 && make install


# 8. 安装curl
RUN cd package/ && tar -zxvf curl-7.61.1.tar.gz && cd curl-7.61.1 && ./configure --with-ssl && make && make install


# 9.1 编译brks 需要的环境 mysqlclient
RUN apt-get install -y libmysqlclient-dev

# 9.2 编译brks 需要的环境
RUN sed 's/typedef THRIFT_SOCKET/\/\/ typedef THRIFT_SOCKET/g' /usr/local/include/thrift/server/TNonblockingServer.h -i
RUN ln -s /usr/lib/x86_64-linux-gnu/libjsoncpp.so.1 /usr/local/lib/libjsoncpp.so
RUN unzip brks-master.zip && mv brks-master brks
RUN rm brks/third/lib/log4cpp/liblog4cpp.* -rf
RUN cp /usr/local/lib/liblog4cpp.* /root/brks/third/lib/log4cpp/

# 9.3 编译brks 项目
RUN cd brks/src && cmake . && make


# 10.1 安装mysql-server
RUN apt-get install -y mysql-server

# 10.2 配置mysql 运行条件
RUN mkdir /run/mysqld
RUN chown mysql:mysql /run/mysqld/

# 10.3 初始化mysql
RUN service mysql start && mysql < mysql.sql
RUN sed 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf -i


# 11. 安装辅助工具
RUN apt-get install -y vim lsof git locate tree gdb valgrind inetutils-ping libnet-ifconfig-wrapper-perl


# 12. 执行清理工作
RUN rm -rf brks-master.zip mysql.sql package


# 13. 设置容器工作目录
WORKDIR /root/brks


# 14. 容器默认执行的first 命令
CMD ["/bin/bash"]