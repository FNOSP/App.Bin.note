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

# 复制二进制文件和启动脚本
COPY --chown=note:note ./app/server/note .
COPY --chown=note:note entrypoint.sh .

# 设置执行权限
RUN chmod +x note entrypoint.sh

# 设置所有者
RUN chown -R note:note /app

# 创建统一的数据根目录，并通过软链将 app 默认使用的 data/uploads/backup 指向 /mnt/note 下
# 这样用户只需映射 /mnt/note 一个目录即可持久化所有数据
RUN mkdir -p /mnt/note && \
    ln -s /mnt/note/data /app/data && \
    ln -s /mnt/note/uploads /app/uploads && \
    ln -s /mnt/note/backup /app/backup && \
    chown -R note:note /mnt/note

USER note

# 声明需要挂载的卷（仅需映射一个目录即可持久化所有数据）
VOLUME ["/mnt/note"]

EXPOSE 10029 10030

# 设置环境变量默认值
ENV DATA_SHARE_PATHS=""

# 使用启动脚本
ENTRYPOINT ["./entrypoint.sh"]
