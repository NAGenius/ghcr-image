FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 预先配置时区，避免后续冲突
RUN echo "Asia/Shanghai" > /etc/timezone

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
    sudo \
    ca-certificates \
    git \
    locales \
    nodejs \
    npm \
    zip \
    unzip \
    tar \
    xz-utils \
    gzip \
    bzip2 \
    p7zip-full \
    rar \
    unrar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# 使用npm安装pnpm（更稳定的方式）
RUN npm install -g pnpm

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

# 设置默认shell为bash
ENV SHELL=/bin/bash

# 设置PS1环境变量，确保Jupyter终端显示正确提示符
ENV PS1="😊  \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\\$ "

# 安装 Jupyter Lab (最新版本)
RUN pip3 install --no-cache-dir jupyterlab

# 创建 python 软链接
RUN ln -s /usr/bin/python3 /usr/bin/python

# 配置终端提示符和别名
RUN echo 'export PS1="😊  \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\\$ "' >> /root/.bashrc && \
    echo 'export PS1="😊  \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\\$ "' >> /etc/bash.bashrc && \
    echo "alias ll='ls -alF'" >> /root/.bashrc && \
    echo "alias la='ls -A'" >> /root/.bashrc && \
    echo "alias l='ls -CF'" >> /root/.bashrc && \
    echo "alias vi='vim'" >> /root/.bashrc

# 配置SSH
RUN mkdir /var/run/sshd && \
    echo 'root:1234' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 配置时区（在 tzdata 安装后使用 dpkg-reconfigure）
RUN dpkg-reconfigure -f noninteractive tzdata

# 创建更新的Jupyter配置文件
RUN mkdir -p /root/.jupyter && \
    echo "c.ServerApp.token = ''" > /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.password = ''" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.disable_check_xsrf = True" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin = '*'" >> /root/.jupyter/jupyter_lab_config.py

# 创建init脚本，包含SSH端口配置
RUN echo '#!/bin/bash\n\
echo "Container initialization started"\n\
\n\
# 配置SSH端口（如果SSH_PORT环境变量存在）\n\
if [ ! -z "$SSH_PORT" ]; then\n\
    echo "Port ${SSH_PORT}" >> /etc/ssh/sshd_config\n\
    echo "SSH port configured to: ${SSH_PORT}"\n\
else\n\
    echo "SSH_PORT not set, using default port 22"\n\
fi\n\
\n\
# 启动SSH服务\n\
service ssh start\n\
echo "SSH service started"\n\
\n\
# 检查SSH状态\n\
if pgrep -x "sshd" > /dev/null; then\n\
    echo "SSH service is running"\n\
else\n\
    echo "SSH service failed to start"\n\
fi\n\
\n\
echo "Initialization completed"' > /init.sh && chmod +x /init.sh

# 默认启动SSH服务
CMD ["/usr/sbin/sshd", "-D"]