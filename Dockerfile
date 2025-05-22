FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 更新包管理器并安装服务器必要软件
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    vim \
    nano \
    htop \
    net-tools \
    iputils-ping \
    telnet \
    openssh-server \
    supervisor \
    tzdata \
    rsyslog \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# 配置SSH
RUN mkdir /var/run/sshd && \
    echo 'root:password' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 暴露SSH端口
EXPOSE 22

# 启动SSH服务
CMD ["/usr/sbin/sshd", "-D"]