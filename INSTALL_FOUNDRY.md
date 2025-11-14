# 🔧 Foundry 安装指南 (Ubuntu 24)

Foundry 是一个强大的以太坊开发工具链，包含 `cast` 命令用于与区块链交互。

---

## 📋 快速安装

### 方法 1: 使用 foundryup (推荐)

这是最简单、最推荐的安装方式：

```bash
# 1. 下载并安装 foundryup
curl -L https://foundry.paradigm.xyz | bash

# 2. 重新加载 shell 环境变量
source ~/.bashrc
# 或者如果使用 zsh
source ~/.zshrc

# 3. 安装 Foundry (forge, cast, anvil, chisel)
foundryup
```

### 方法 2: 从源代码编译

如果方法 1 不工作，可以从源代码编译：

```bash
# 1. 安装依赖
sudo apt update
sudo apt install -y build-essential git curl

# 2. 安装 Rust (如果还没安装)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# 3. 克隆 Foundry 仓库
git clone https://github.com/foundry-rs/foundry
cd foundry

# 4. 编译安装
cargo install --path ./crates/forge --bins --locked
cargo install --path ./crates/cast --bins --locked
cargo install --path ./crates/anvil --bins --locked
cargo install --path ./crates/chisel --bins --locked

# 5. 返回并清理
cd ..
rm -rf foundry
```

---

## ✅ 验证安装

安装完成后，验证工具是否可用：

```bash
# 检查 cast 版本
cast --version

# 检查 forge 版本
forge --version

# 检查 anvil 版本
anvil --version
```

预期输出类似：

```
cast 0.2.0 (abc1234 2024-01-01T00:00:00.000000000Z)
forge 0.2.0 (abc1234 2024-01-01T00:00:00.000000000Z)
anvil 0.2.0 (abc1234 2024-01-01T00:00:00.000000000Z)
```

---

## 🧪 测试 cast 功能

### 1. 查询账户余额

```bash
# 查询地址余额
cast balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb5 \
  --rpc-url https://1rpc.io/sepolia

# 或者使用 Alchemy
cast balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb5 \
  --rpc-url https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
```

### 2. 从私钥推导地址

```bash
# 从私钥获取地址
cast wallet address 0xYOUR_PRIVATE_KEY
```

### 3. 查询区块信息

```bash
# 获取最新区块号
cast block-number --rpc-url https://1rpc.io/sepolia

# 查询特定区块信息
cast block latest --rpc-url https://1rpc.io/sepolia
```

---

## 🔄 更新 Foundry

保持 Foundry 更新到最新版本：

```bash
foundryup
```

---

## 📦 Foundry 包含的工具

安装 Foundry 后，您将获得以下工具：

| 工具       | 功能                    | 常用场景                     |
| ---------- | ----------------------- | ---------------------------- |
| **cast**   | 与以太坊交互的 CLI 工具 | 查询余额、发送交易、调用合约 |
| **forge**  | 智能合约开发框架        | 编译、测试、部署合约         |
| **anvil**  | 本地以太坊节点          | 本地开发和测试               |
| **chisel** | Solidity REPL           | 交互式测试 Solidity 代码     |

---

## 🐛 故障排除

### 问题 1: command not found: foundryup

**原因**: 环境变量未生效

**解决方法**:

```bash
# 重新加载配置
source ~/.bashrc

# 或者手动添加到 PATH
export PATH="$HOME/.foundry/bin:$PATH"

# 永久添加（添加到 ~/.bashrc）
echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 问题 2: cast 命令不工作

**解决方法**:

```bash
# 检查 cast 是否在 PATH 中
which cast

# 如果找不到，检查安装位置
ls ~/.foundry/bin/

# 手动添加到 PATH
export PATH="$HOME/.foundry/bin:$PATH"
```

### 问题 3: RPC 连接错误

**原因**: 网络问题或 RPC 限流

**解决方法**:

- 使用私有 RPC (Alchemy, Infura)
- 检查网络连接
- 尝试不同的公共 RPC

---

## 📚 常用 cast 命令速查

### 账户操作

```bash
# 查询余额
cast balance <ADDRESS> --rpc-url <RPC_URL>

# 从私钥生成地址
cast wallet address <PRIVATE_KEY>

# 查询 nonce
cast nonce <ADDRESS> --rpc-url <RPC_URL>
```

### 区块链查询

```bash
# 当前区块号
cast block-number --rpc-url <RPC_URL>

# Gas 价格
cast gas-price --rpc-url <RPC_URL>

# 链 ID
cast chain-id --rpc-url <RPC_URL>
```

### 交易操作

```bash
# 发送 ETH
cast send <TO_ADDRESS> \
  --value <AMOUNT_IN_WEI> \
  --private-key <PRIVATE_KEY> \
  --rpc-url <RPC_URL>

# 调用合约（只读）
cast call <CONTRACT_ADDRESS> "function()" --rpc-url <RPC_URL>

# 调用合约（写入）
cast send <CONTRACT_ADDRESS> "function()" \
  --private-key <PRIVATE_KEY> \
  --rpc-url <RPC_URL>
```

### 单位转换

```bash
# Wei 转 ETH
cast from-wei <WEI_AMOUNT>

# ETH 转 Wei
cast to-wei <ETH_AMOUNT>

# 十六进制转十进制
cast to-dec <HEX_NUMBER>

# 十进制转十六进制
cast to-hex <DECIMAL_NUMBER>
```

---

## 🔗 相关资源

- **Foundry 官方文档**: https://book.getfoundry.sh/
- **Cast 文档**: https://book.getfoundry.sh/reference/cast/
- **GitHub 仓库**: https://github.com/foundry-rs/foundry
- **Discord 社区**: https://discord.gg/foundry

---

## ✅ 安装后测试脚本

安装完成后，您可以运行我们的脚本进行测试：

```bash
# 确认 cast 已安装
cast --version

# 运行批量处理脚本
./auto_burn_participate.sh \
  --custom-rpc "https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY"
```

脚本现在应该能够：

- ✅ 正确推导地址
- ✅ 快速查询 ETH 余额
- ✅ 更可靠地执行操作

---

## 🎯 为什么需要 Foundry？

对于我们的 `auto_burn_participate.sh` 脚本：

1. **地址推导**: `cast wallet address` 可以从私钥快速推导地址
2. **余额查询**: `cast balance` 提供可靠的余额查询
3. **性能**: 比 curl 调用 RPC 更快更稳定
4. **易用性**: 简单的命令行界面
5. **可靠性**: 经过充分测试的工具

---

**安装时间**: 约 2-5 分钟  
**磁盘空间**: 约 100-200 MB  
**推荐度**: ⭐⭐⭐⭐⭐
