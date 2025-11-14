#!/bin/bash

# Foundry 一键安装脚本 (Ubuntu 24)
# 用途：在 Ubuntu 系统上自动安装 Foundry 工具链

set -e  # 遇到错误立即退出

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔧 Foundry 安装脚本 (Ubuntu 24)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查是否为 Ubuntu
if [ ! -f /etc/os-release ]; then
    echo "❌ 无法检测操作系统"
    exit 1
fi

source /etc/os-release
echo "📋 检测到系统: $NAME $VERSION"
echo ""

# 检查是否已安装
if command -v cast &> /dev/null; then
    echo "✅ Foundry 已经安装！"
    echo "当前版本:"
    cast --version
    echo ""
    read -p "是否要更新到最新版本？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "跳过安装。"
        exit 0
    fi
fi

echo "🔍 步骤 1/4: 检查依赖..."

# 检查必需的依赖
if ! command -v curl &> /dev/null; then
    echo "📦 安装 curl..."
    sudo apt update
    sudo apt install -y curl
fi

if ! command -v git &> /dev/null; then
    echo "📦 安装 git..."
    sudo apt install -y git
fi

echo "✅ 依赖检查完成"
echo ""

echo "🔍 步骤 2/4: 下载 foundryup..."

# 下载并安装 foundryup
curl -L https://foundry.paradigm.xyz | bash

echo "✅ foundryup 下载完成"
echo ""

echo "🔍 步骤 3/4: 设置环境变量..."

# 检测 shell 类型
if [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.profile"
fi

# 添加 Foundry 到 PATH（如果还没有）
if ! grep -q '.foundry/bin' "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> "$SHELL_RC"
    echo "✅ 已添加 Foundry 到 PATH ($SHELL_RC)"
else
    echo "✅ PATH 已经配置"
fi

# 立即加载环境变量
export PATH="$HOME/.foundry/bin:$PATH"

# 重新加载配置
source "$SHELL_RC" 2>/dev/null || true

echo ""

echo "🔍 步骤 4/4: 安装 Foundry 工具..."

# 运行 foundryup 安装 Foundry
if [ -f "$HOME/.foundry/bin/foundryup" ]; then
    "$HOME/.foundry/bin/foundryup"
else
    echo "⚠️  foundryup 未找到，尝试从 PATH 运行..."
    foundryup
fi

echo "✅ Foundry 安装完成"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ 安装成功！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 验证安装
echo "📊 已安装的工具版本:"
echo ""

if command -v cast &> /dev/null; then
    echo "✅ cast:"
    cast --version
else
    echo "❌ cast 未找到"
fi

echo ""

if command -v forge &> /dev/null; then
    echo "✅ forge:"
    forge --version
else
    echo "⚠️  forge 未找到（这是正常的，如果您只需要 cast）"
fi

echo ""

if command -v anvil &> /dev/null; then
    echo "✅ anvil:"
    anvil --version
else
    echo "⚠️  anvil 未找到（这是正常的，如果您只需要 cast）"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎯 下一步操作:"
echo ""
echo "1. 重新加载 shell 配置:"
echo "   source $SHELL_RC"
echo ""
echo "2. 测试 cast 命令:"
echo "   cast --version"
echo ""
echo "3. 查询余额测试:"
echo "   cast balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb5 --rpc-url https://1rpc.io/sepolia"
echo ""
echo "4. 运行批量脚本:"
echo "   ./auto_burn_participate.sh --custom-rpc \"YOUR_RPC_URL\""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 更多信息请查看: INSTALL_FOUNDRY.md"
echo ""

