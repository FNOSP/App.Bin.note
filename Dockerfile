FROM alpine:3.19

# 安装调试工具
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    curl \
    vim \
    htop \
    net-tools \
    libc6-compat \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 创建用户
RUN addgroup -g 1000 -S note && \
    adduser -u 1000 -S note -G note

WORKDIR /app

# 创建目录
RUN mkdir -p /app/data /app/uploads /app/backup

# 复制二进制文件和启动脚本
COPY --chown=note:note ./app/server/note .
COPY --chown=note:note entrypoint.sh .

# 设置执行权限
RUN chmod +x note entrypoint.sh

# 设置所有者
RUN chown -R note:note /app

USER note

# 声明需要挂载的卷
VOLUME ["/app/data", "/app/uploads", "/app/backup"]

EXPOSE 10029

# 设置环境变量默认值
ENV DATA_SHARE_PATHS=""

# 使用启动脚本
ENTRYPOINT ["./entrypoint.sh"]