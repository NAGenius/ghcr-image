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
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# 安装 Jupyter Lab (最小安装)
RUN pip3 install --no-cache-dir jupyterlab

# 创建 python 软链接
RUN ln -s /usr/bin/python3 /usr/bin/python

# 配置SSH
RUN mkdir /var/run/sshd && \
    echo 'root:1234' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 创建初始化脚本(Pod需要)
RUN echo '#!/bin/bash\necho "Container started"' > /init.sh && chmod +x /init.sh

# 暴露SSH端口和Jupyter端口
EXPOSE 22 3000

# 启动SSH服务
CMD ["/usr/sbin/sshd", "-D"]