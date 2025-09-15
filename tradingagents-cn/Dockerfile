FROM python:3.11-slim

# 设置环境变量
ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# 安装系统依赖 + pandoc
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    jq \
    pandoc \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /opt/tradingagents

# 克隆项目
RUN git clone https://github.com/hsliuping/TradingAgents-CN.git . && \
    git checkout main

# 安装Python依赖
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir pytdx && \
    (pip install --no-cache-dir -r requirements_db.txt || echo "Database requirements optional")

# 禁用pypandoc的自动下载功能
ENV PYPANDOC_PANDOC=/usr/bin/pandoc

# 创建启动脚本（包含 TUSHARE_TOKEN 支持）
RUN echo '#!/bin/bash\n\
echo "Starting TradingAgents-CN..."\n\
\n\
# 解析配置\n\
OPTIONS_FILE="/data/options.json"\n\
if [[ -f "$OPTIONS_FILE" ]]; then\n\
    echo "Loading configuration from $OPTIONS_FILE"\n\
    DASHSCOPE_API_KEY=$(cat "$OPTIONS_FILE" | jq -r ".dashscope_api_key // \"\"")\n\
    TUSHARE_TOKEN=$(cat "$OPTIONS_FILE" | jq -r ".tushare_token // \"\"")\n\
    FINNHUB_API_KEY=$(cat "$OPTIONS_FILE" | jq -r ".finnhub_api_key // \"\"")\n\
    GOOGLE_API_KEY=$(cat "$OPTIONS_FILE" | jq -r ".google_api_key // \"\"")\n\
    OPENAI_API_KEY=$(cat "$OPTIONS_FILE" | jq -r ".openai_api_key // \"\"")\n\
    ANTHROPIC_API_KEY=$(cat "$OPTIONS_FILE" | jq -r ".anthropic_api_key // \"\"")\n\
    MONGODB_ENABLED=$(cat "$OPTIONS_FILE" | jq -r ".mongodb_enabled // false")\n\
    REDIS_ENABLED=$(cat "$OPTIONS_FILE" | jq -r ".redis_enabled // false")\n\
    MONGODB_HOST=$(cat "$OPTIONS_FILE" | jq -r ".mongodb_host // \"localhost\"")\n\
    MONGODB_PORT=$(cat "$OPTIONS_FILE" | jq -r ".mongodb_port // 27017")\n\
    REDIS_HOST=$(cat "$OPTIONS_FILE" | jq -r ".redis_host // \"localhost\"")\n\
    REDIS_PORT=$(cat "$OPTIONS_FILE" | jq -r ".redis_port // 6379")\n\
    LOG_LEVEL=$(cat "$OPTIONS_FILE" | jq -r ".log_level // \"info\"")\n\
else\n\
    echo "No configuration file found, using defaults"\n\
    DASHSCOPE_API_KEY=""\n\
    TUSHARE_TOKEN=""\n\
    FINNHUB_API_KEY=""\n\
    GOOGLE_API_KEY=""\n\
    OPENAI_API_KEY=""\n\
    ANTHROPIC_API_KEY=""\n\
    MONGODB_ENABLED="false"\n\
    REDIS_ENABLED="false"\n\
    MONGODB_HOST="localhost"\n\
    MONGODB_PORT="27017"\n\
    REDIS_HOST="localhost"\n\
    REDIS_PORT="6379"\n\
    LOG_LEVEL="info"\n\
fi\n\
\n\
# 创建.env文件\n\
ENV_FILE="/opt/tradingagents/.env"\n\
echo "Creating environment file at $ENV_FILE"\n\
cat > "$ENV_FILE" <<EOF\n\
DASHSCOPE_API_KEY=${DASHSCOPE_API_KEY}\n\
TUSHARE_TOKEN=${TUSHARE_TOKEN}\n\
FINNHUB_API_KEY=${FINNHUB_API_KEY}\n\
GOOGLE_API_KEY=${GOOGLE_API_KEY}\n\
OPENAI_API_KEY=${OPENAI_API_KEY}\n\
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}\n\
MONGODB_ENABLED=${MONGODB_ENABLED}\n\
REDIS_ENABLED=${REDIS_ENABLED}\n\
MONGODB_HOST=${MONGODB_HOST}\n\
MONGODB_PORT=${MONGODB_PORT}\n\
REDIS_HOST=${REDIS_HOST}\n\
REDIS_PORT=${REDIS_PORT}\n\
TRADING_AGENTS_DATA_DIR=/data/tradingagents\n\
LOG_LEVEL=${LOG_LEVEL}\n\
MONGODB_DATABASE=trading_agents\n\
MONGODB_USERNAME=\n\
MONGODB_PASSWORD=\n\
REDIS_PASSWORD=\n\
REDIS_DB=0\n\
DOCKER_CONTAINER=true\n\
EOF\n\
\n\
# 显示配置信息\n\
echo "=== TradingAgents-CN Configuration ===="n\
echo "🤖 AI Models:"\n\
[[ -n "$DASHSCOPE_API_KEY" ]] && echo "  ✅ 阿里百炼 (Dashscope) - 已配置" || echo "  ❌ 阿里百炼 (Dashscope) - 未配置 [必需]"\n\
[[ -n "$GOOGLE_API_KEY" ]] && echo "  ✅ Google AI - 已配置" || echo "  ⚪ Google AI - 未配置 [可选]"\n\
[[ -n "$OPENAI_API_KEY" ]] && echo "  ✅ OpenAI - 已配置" || echo "  ⚪ OpenAI - 未配置 [可选]"\n\
[[ -n "$ANTHROPIC_API_KEY" ]] && echo "  ✅ Anthropic - 已配置" || echo "  ⚪ Anthropic - 未配置 [可选]"\n\
echo ""\n\
echo "📊 Data Sources:"\n\
[[ -n "$TUSHARE_TOKEN" ]] && echo "  ✅ Tushare - 已配置 (支持A股、港股等中国市场)" || echo "  ⚪ Tushare - 未配置 (A股数据源)"\n\
[[ -n "$FINNHUB_API_KEY" ]] && echo "  ✅ FinnHub - 已配置 (支持美股等全球市场)" || echo "  ⚪ FinnHub - 未配置 (美股数据源)"\n\
echo ""\n\
# 检查数据源配置状态\n\
if [[ -n "$TUSHARE_TOKEN" && -n "$FINNHUB_API_KEY" ]]; then\n\
    echo "🌍 支持全球股票分析 (A股 + 美股)"\n\
elif [[ -n "$TUSHARE_TOKEN" ]]; then\n\
    echo "🇨🇳 支持中国市场分析 (A股、港股等)"\n\
elif [[ -n "$FINNHUB_API_KEY" ]]; then\n\
    echo "🇺🇸 支持美股等全球市场分析"\n\
else\n\
    echo "⚠️  警告: 未配置任何数据源API，股票数据获取可能受限"\n\
    echo "💡 建议: 配置 tushare_token (A股) 或 finnhub_api_key (美股)"\n\
fi\n\
echo ""\n\
echo "⚙️  Other Settings:"\n\
echo "  - LOG_LEVEL: $LOG_LEVEL"\n\
echo "  - MONGODB_ENABLED: $MONGODB_ENABLED"\n\
echo "  - REDIS_ENABLED: $REDIS_ENABLED"\n\
echo "======================================"\n\
\n\
# 确保数据目录存在\n\
mkdir -p /data/tradingagents\n\
echo "Data directory ready: /data/tradingagents"\n\
\n\
# 启动应用\n\
cd /opt/tradingagents\n\
echo "Starting Streamlit application on port 8501..."\n\
exec python -m streamlit run web/app.py \\\n\
    --server.address 0.0.0.0 \\\n\
    --server.port 8501 \\\n\
    --server.headless true \\\n\
    --server.enableCORS false \\\n\
    --server.enableXsrfProtection false \\\n\
    --server.fileWatcherType none\n\
' > /usr/local/bin/start.sh && chmod +x /usr/local/bin/start.sh

# 创建数据目录
RUN mkdir -p /data/tradingagents && \
    mkdir -p /config/tradingagents

# 暴露端口
EXPOSE 8501

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# 设置标签
LABEL \
    io.hass.name="TradingAgents-CN" \
    io.hass.description="基于多智能体LLM的中文金融交易框架" \
    io.hass.arch="${TARGETARCH}" \
    io.hass.type="addon" \
    io.hass.version="1.0.1" \
    maintainer="liyong763435720"

# 直接启动应用
CMD ["/usr/local/bin/start.sh"]