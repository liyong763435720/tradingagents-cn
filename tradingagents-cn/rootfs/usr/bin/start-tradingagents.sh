#!/bin/bash

# 设置环境变量
export PYTHONPATH="/opt/tradingagents:$PYTHONPATH"

# 进入应用目录
cd /opt/tradingagents

# 等待一段时间确保所有服务就绪
sleep 5

# 启动Streamlit应用
exec python -m streamlit run web/app.py \
    --server.address 0.0.0.0 \
    --server.port 8501 \
    --server.headless true \
    --server.enableCORS false \
    --server.enableXsrfProtection false \
    --server.fileWatcherType none
