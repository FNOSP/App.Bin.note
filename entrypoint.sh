#!/bin/sh
set -e

# 打印启动信息
echo "================================"
echo "🚀 Starting Note Service"
echo "================================"
echo "📋 Configuration:"
echo "  DATA_SHARE_PATHS: ${DATA_SHARE_PATHS:-未设置}"
echo "================================"

# 根据环境变量决定启动命令
if [ -n "${DATA_SHARE_PATHS}" ]; then
    echo "✅ 使用授权目录: ${DATA_SHARE_PATHS}"
    exec ./note -data-share-paths ${DATA_SHARE_PATHS}
else
    echo "ℹ️  使用默认配置"
    exec ./note
fi
