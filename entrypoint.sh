#!/bin/sh
set -e

# 打印启动信息
echo "================================"
echo "🚀 Starting Note Service"
echo "================================"
echo "📋 Configuration:"
echo "  DATA_SHARE_PATHS: ${DATA_SHARE_PATHS:-未设置}"
echo "================================"

# 确保软链目标目录存在（/app/data、/app/uploads、/app/backup 均软链到 /mnt/note 下）
# 必须先创建目标目录，否则 app 的 os.MkdirAll 遇到软链会报 "file exists"
mkdir -p /mnt/note/data /mnt/note/uploads /mnt/note/backup

# 根据环境变量决定启动命令
if [ -n "${DATA_SHARE_PATHS}" ]; then
    echo "✅ 使用授权目录: ${DATA_SHARE_PATHS}"
    exec ./note -data-share-paths ${DATA_SHARE_PATHS}
else
    echo "ℹ️  使用默认配置"
    exec ./note
fi
