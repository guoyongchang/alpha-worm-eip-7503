# 🚀 Auto Burn & Participate 脚本使用指南

## 📋 功能概述

`auto_burn_participate.sh` 是一个强大的批量处理脚本，可以自动为多个账户执行 burn 和 participate 操作。

### 核心功能

✅ **批量处理**: 从 `pk.txt` 读取多个私钥，依次处理每个账户  
✅ **智能燃烧**: 自动查询余额，保留 0.1 ETH，剩余全部燃烧  
✅ **精确计算**: 燃烧金额精确到 2 位小数  
✅ **文件管理**: 自动保存和重命名 `rapidsnark_output.json`  
✅ **自动参与**: 将 BETH 平分为 200 个 epoch 参与挖矿  
✅ **安全跳过**: 余额不足 0.1 ETH 的账户自动跳过  
✅ **详细统计**: 显示成功/跳过/失败的完整统计

---

## 🛠️ 前置准备

### 1. 确保已安装 worm-miner

```bash
worm-miner --help
```

如果未安装，请参考主 README 进行安装。

### 2. 安装依赖工具（可选，推荐）

#### Foundry (用于查询余额)

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

#### bc (高精度计算工具)

```bash
# Ubuntu/Debian
sudo apt install bc

# CentOS/RHEL
sudo yum install bc

# macOS
brew install bc
```

### 3. 准备私钥文件

创建 `pk.txt` 文件，每行一个私钥：

```bash
cp pk.txt.example pk.txt
# 然后编辑 pk.txt，填入真实私钥
```

**pk.txt 格式示例**:

```
0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
# 可以添加注释
```

---

## 🚀 使用方法

### 基本用法

```bash
./auto_burn_participate.sh --custom-rpc "https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY"
```

### 完整参数

```bash
./auto_burn_participate.sh \
  --pk-file "pk.txt" \
  --custom-rpc "https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY" \
  --network "sepolia" \
  --reserve-eth "0.1" \
  --num-epochs 200
```

### 使用环境变量

```bash
export CUSTOM_RPC="https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY"
export PK_FILE="pk.txt"
./auto_burn_participate.sh
```

---

## ⚙️ 参数说明

| 参数            | 说明                      | 默认值                    |
| --------------- | ------------------------- | ------------------------- |
| `--pk-file`     | 私钥文件路径              | `pk.txt`                  |
| `--custom-rpc`  | RPC 节点地址              | `https://1rpc.io/sepolia` |
| `--network`     | 网络名称                  | `sepolia`                 |
| `--reserve-eth` | 每个账户保留的 ETH 数量   | `0.1`                     |
| `--num-epochs`  | participate 的 epoch 数量 | `200`                     |

---

## 📊 执行流程

对于每个账户，脚本会按以下顺序执行：

```
1. 📖 读取私钥
   ↓
2. 🔍 查询 ETH 余额
   ↓
3. 💰 计算可燃烧金额 (余额 - 0.1 ETH, 保留2位小数)
   ↓
4. 🔥 执行 burn 操作
   ↓
5. 💾 保存 rapidsnark_output.json
   ↓
6. 🔍 查询 BETH 余额
   ↓
7. 📊 计算每个 epoch 金额 (BETH / 200)
   ↓
8. 💎 执行 participate (200 epochs)
   ↓
9. ✅ 完成，处理下一个账户
```

---

## 📂 输出文件

### rapidsnark 输出文件

脚本会自动保存每个账户的 rapidsnark 输出：

```
rapidsnark_outputs/
├── abcdef12.rapidsnark_output.json  # 私钥后8位作为文件名
├── 34567890.rapidsnark_output.json
└── ...
```

---

## 🎯 使用示例

### 示例 1: 使用 Alchemy RPC

```bash
./auto_burn_participate.sh \
  --custom-rpc "https://eth-sepolia.g.alchemy.com/v2/abc123def456"
```

### 示例 2: 自定义保留金额

```bash
./auto_burn_participate.sh \
  --custom-rpc "YOUR_RPC_URL" \
  --reserve-eth "0.2"  # 每个账户保留 0.2 ETH
```

### 示例 3: 使用不同的私钥文件

```bash
./auto_burn_participate.sh \
  --pk-file "my_wallets.txt" \
  --custom-rpc "YOUR_RPC_URL"
```

### 示例 4: 参与更多 epochs

```bash
./auto_burn_participate.sh \
  --custom-rpc "YOUR_RPC_URL" \
  --num-epochs 500  # 分成 500 个 epoch
```

---

## 📈 输出示例

```
=========================================
   Auto Burn & Participate Script
=========================================
📄 Private Key File: pk.txt
🌐 RPC URL: https://eth-sepolia.g.alchemy.com/v2/...
🌐 Network: sepolia
💰 Reserve ETH: 0.1
📊 Epochs: 200
=========================================

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 Processing Account #1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔑 Private Key: 0x12345678...abcdef12

🔍 Step 1: Getting address...
✅ Address: 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb5

🔍 Step 2: Checking ETH balance...
✅ ETH Balance: 0.5 ETH
💰 Burn Amount (after reserve): 0.40 ETH

🔍 Step 3: Burning tokens...
✅ Burn successful!

🔍 Step 4: Saving rapidsnark output...
✅ Saved: rapidsnark_outputs/abcdef12.rapidsnark_output.json

🔍 Step 5: Checking BETH balance...
✅ BETH Balance: 0.400000000000000000 BETH
💎 Amount per epoch: 0.002000000000000000 BETH

🔍 Step 6: Participating in mining...
✅ Participate successful!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Account #1 completed successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        📊 Final Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total accounts processed: 5
✅ Successful: 4
⏭️  Skipped: 1
❌ Errors: 0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## ⚠️ 注意事项

### 安全性

1. **私钥保护**:

   - 不要将 `pk.txt` 提交到 Git 仓库
   - 建议将 `pk.txt` 添加到 `.gitignore`
   - 确保文件权限正确：`chmod 600 pk.txt`

2. **测试建议**:
   - 首次使用建议用测试私钥测试
   - 确认脚本正常运行后再使用真实私钥

### RPC 节点

1. **推荐使用私有 RPC**:

   - Alchemy, Infura 等服务的 API
   - 避免使用公共 RPC（可能有速率限制）

2. **速率限制**:
   - 脚本在每个账户处理完后会延迟 2 秒
   - 避免触发 RPC 限流

### 余额管理

1. **保留金额**: 默认保留 0.1 ETH 用于 gas 费用
2. **不足余额**: 余额 < 0.1 ETH 的账户会自动跳过
3. **精度处理**: 燃烧金额精确到 2 位小数

---

## 🐛 故障排除

### 问题 1: 无法查询余额

**症状**: 显示 "Failed to get ETH balance"

**解决方法**:

```bash
# 检查 RPC 是否可用
curl -X POST $CUSTOM_RPC \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

# 安装 cast 工具（推荐）
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 问题 2: burn 失败

**症状**: "Burn failed for account #X"

**可能原因**:

- Gas 不足
- RPC 连接问题
- 网络拥堵

**解决方法**:

- 检查账户余额是否充足
- 更换 RPC 节点
- 稍后重试

### 问题 3: rapidsnark_output.json 未找到

**症状**: "Warning: rapidsnark_output.json not found"

**可能原因**:

- burn 操作未完全完成
- worm-miner 版本问题

**解决方法**:

- 确认 worm-miner 版本是否最新
- 检查 burn 操作是否真正成功
- 查看当前目录是否有该文件

### 问题 4: BETH 余额为 0

**症状**: "Warning: BETH balance is 0"

**可能原因**:

- burn 操作失败
- 需要等待区块确认

**解决方法**:

- 等待几分钟后重新查询
- 使用 `worm-miner info` 手动检查

---

## 🔧 高级用法

### 在后台运行（推荐使用 tmux）

```bash
# 创建 tmux 会话
tmux new -s auto_burn_participate

# 运行脚本
./auto_burn_participate.sh --custom-rpc "YOUR_RPC_URL"

# 按 Ctrl+B, 然后按 D 分离会话

# 重新连接
tmux attach -t auto_burn_participate
```

### 记录日志

```bash
./auto_burn_participate.sh \
  --custom-rpc "YOUR_RPC_URL" \
  2>&1 | tee burn_participate.log
```

### 仅处理部分账户

```bash
# 创建临时私钥文件
head -n 3 pk.txt > pk_test.txt

# 使用临时文件
./auto_burn_participate.sh \
  --pk-file "pk_test.txt" \
  --custom-rpc "YOUR_RPC_URL"
```

---

## 📞 支持

如有问题，请查看：

- 主 README.md
- memory_bank.md（项目记忆库）
- worm-miner 官方文档

---

## ⚖️ 免责声明

使用此脚本需自担风险。请在充分理解脚本功能后使用，并确保：

- 已在测试环境验证
- 理解相关的 gas 成本
- 妥善保管私钥文件
