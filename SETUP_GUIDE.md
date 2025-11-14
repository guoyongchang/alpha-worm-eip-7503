# 🚀 完整环境配置指南

本指南帮助您在 Ubuntu 24 系统上完整配置 WORM 挖矿自动化环境。

---

## 📋 环境要求

- **操作系统**: Ubuntu 24.04 LTS（推荐）或其他 Linux 发行版
- **内存**: 至少 2GB RAM
- **磁盘空间**: 至少 5GB 可用空间
- **网络**: 稳定的网络连接

---

## 🔧 完整安装流程

### 第 1 步: 安装系统依赖

```bash
# 更新包管理器
sudo apt update && sudo apt upgrade -y

# 安装基础工具
sudo apt install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    unzip \
    pkg-config \
    libssl-dev \
    libclang-dev \
    bc

# 安装数学计算工具（用于余额计算）
sudo apt install -y bc
```

### 第 2 步: 安装 Rust

```bash
# 安装 Rust 工具链
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 选择默认安装（输入 1）

# 重新加载环境
source ~/.bashrc
# 或
source ~/.cargo/env

# 验证安装
rustc --version
cargo --version
```

### 第 3 步: 安装 worm-miner

```bash
# 克隆 worm-miner 仓库
git clone https://github.com/worm-privacy/miner && cd miner

# 下载必要的参数文件
make download_params

# 编译并安装
cargo install --path .

# 返回主目录
cd
source ~/.bashrc

# 验证安装
worm-miner --help
```

### 第 4 步: 安装 Foundry (包含 cast)

#### 方法 A: 使用一键安装脚本（推荐）

```bash
# 克隆本项目
cd ~
git clone https://github.com/guoyongchang/alpha-worm-eip-7503.git
cd alpha-worm-eip-7503

# 运行一键安装脚本
./install_foundry_ubuntu.sh

# 重新加载环境
source ~/.bashrc
```

#### 方法 B: 手动安装

```bash
# 下载并安装 foundryup
curl -L https://foundry.paradigm.xyz | bash

# 重新加载环境
source ~/.bashrc

# 安装 Foundry 工具
foundryup

# 验证安装
cast --version
```

### 第 5 步: 配置私钥文件

```bash
# 进入项目目录
cd ~/alpha-worm-eip-7503

# 创建私钥文件
cp pk.txt.example pk.txt

# 编辑私钥文件（使用您喜欢的编辑器）
nano pk.txt
# 或
vim pk.txt

# 设置文件权限（重要！）
chmod 600 pk.txt
```

**pk.txt 格式**:

```
0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
# 每行一个私钥
```

### 第 6 步: 配置 RPC 节点

#### 选项 A: 使用公共 RPC（测试用）

```bash
export CUSTOM_RPC="https://1rpc.io/sepolia"
```

#### 选项 B: 使用 Alchemy（推荐）

1. 访问 https://www.alchemy.com/
2. 注册账户
3. 创建 Sepolia 测试网应用
4. 获取 API Key

```bash
export CUSTOM_RPC="https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY"
```

---

## ✅ 验证安装

运行以下命令验证所有工具都已正确安装：

```bash
# 验证脚本
cat > ~/check_installation.sh << 'EOF'
#!/bin/bash

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔍 环境检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查 worm-miner
if command -v worm-miner &> /dev/null; then
    echo "✅ worm-miner: $(worm-miner --version 2>&1 | head -1)"
else
    echo "❌ worm-miner: 未安装"
fi

# 检查 cast
if command -v cast &> /dev/null; then
    echo "✅ cast: $(cast --version)"
else
    echo "❌ cast: 未安装"
fi

# 检查 bc
if command -v bc &> /dev/null; then
    echo "✅ bc: $(bc --version | head -1)"
else
    echo "❌ bc: 未安装"
fi

# 检查 curl
if command -v curl &> /dev/null; then
    echo "✅ curl: $(curl --version | head -1)"
else
    echo "❌ curl: 未安装"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
EOF

chmod +x ~/check_installation.sh
~/check_installation.sh
```

---

## 🎯 开始使用

### 测试单个账户

```bash
# 查看账户信息
worm-miner info \
  --network sepolia \
  --private-key 0xYOUR_PRIVATE_KEY \
  --custom-rpc $CUSTOM_RPC
```

### 运行批量脚本

```bash
cd ~/alpha-worm-eip-7503

# 基本用法
./auto_burn_participate.sh --custom-rpc "$CUSTOM_RPC"

# 使用 tmux 后台运行（推荐）
tmux new -s worm_mining
./auto_burn_participate.sh --custom-rpc "$CUSTOM_RPC"
# 按 Ctrl+B, D 分离会话
```

---

## 🐛 常见问题

### Q1: worm-miner 命令未找到

**解决方法**:

```bash
# 重新加载环境
source ~/.bashrc
source ~/.cargo/env

# 检查安装路径
which worm-miner
ls ~/.cargo/bin/worm-miner

# 如果需要，手动添加到 PATH
export PATH="$HOME/.cargo/bin:$PATH"
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
```

### Q2: cast 命令未找到

**解决方法**:

```bash
# 重新运行 foundryup
foundryup

# 重新加载环境
source ~/.bashrc

# 检查安装路径
which cast
ls ~/.foundry/bin/cast

# 手动添加到 PATH
export PATH="$HOME/.foundry/bin:$PATH"
echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> ~/.bashrc
```

### Q3: 权限错误

**解决方法**:

```bash
# 给脚本添加执行权限
chmod +x auto_burn_participate.sh
chmod +x install_foundry_ubuntu.sh

# 保护私钥文件
chmod 600 pk.txt
```

### Q4: RPC 连接失败

**解决方法**:

- 检查网络连接
- 验证 RPC URL 是否正确
- 尝试使用不同的 RPC 提供商
- 确认 API Key 是否有效

---

## 📚 相关文档

- [QUICK_START.md](./QUICK_START.md) - 快速开始指南
- [AUTO_BURN_PARTICIPATE_README.md](./AUTO_BURN_PARTICIPATE_README.md) - 详细使用文档
- [INSTALL_FOUNDRY.md](./INSTALL_FOUNDRY.md) - Foundry 安装详细说明
- [README.md](./README.md) - 项目主文档

---

## 🎓 学习资源

### worm-miner

- GitHub: https://github.com/worm-privacy/miner

### Foundry

- 官方文档: https://book.getfoundry.sh/
- Cast 参考: https://book.getfoundry.sh/reference/cast/

### 以太坊开发

- Ethereum 文档: https://ethereum.org/developers
- Sepolia 测试网: https://sepolia.etherscan.io/

---

## ⏱️ 预计安装时间

| 步骤       | 时间              |
| ---------- | ----------------- |
| 系统依赖   | 2-5 分钟          |
| Rust       | 5-10 分钟         |
| worm-miner | 10-20 分钟        |
| Foundry    | 2-5 分钟          |
| **总计**   | **约 20-40 分钟** |

---

## ✅ 安装完成检查清单

- [ ] Ubuntu 系统已更新
- [ ] 基础工具已安装 (git, curl, bc)
- [ ] Rust 已安装并配置
- [ ] worm-miner 已安装并可用
- [ ] Foundry (cast) 已安装并可用
- [ ] 私钥文件已配置 (pk.txt)
- [ ] RPC 节点已配置
- [ ] 脚本权限已设置
- [ ] 测试命令运行正常

---

**准备好了？开始挖矿吧！** 🚀
