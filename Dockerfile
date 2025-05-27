FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 更新包管理器并安装服务器必要软件
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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
    systemd \
    systemd-sysv \
    sudo \
    ca-certificates \
    git \
    locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# 安装中文字体支持
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ttf-wqy-microhei \
    ttf-wqy-zenhei \
    xfonts-wqy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 配置中文语言环境
RUN locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8

# 设置中文环境变量
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:en

# 安装 Jupyter Lab (最小安装)
RUN pip3 install --no-cache-dir jupyterlab

# 创建 python 软链接
RUN ln -s /usr/bin/python3 /usr/bin/python

# 配置SSH
RUN mkdir /var/run/sshd && \
    echo 'root:1234' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 启用SSH服务开机自启动
RUN systemctl enable ssh

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 配置systemd以在容器中运行
RUN cd /lib/systemd/system/sysinit.target.wants/; \
    ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1; \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# 暴露SSH端口和Jupyter端口
EXPOSE 22 3000

# 使用systemd作为初始化进程
CMD ["/lib/systemd/systemd"]