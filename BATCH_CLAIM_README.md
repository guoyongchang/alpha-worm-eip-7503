# 🎁 批量 Claim 脚本使用指南

自动批量领取多个 epoch 的 WORM 奖励。

---

## 📋 功能概述

`batch_claim.sh` 是一个强大的批量 claim 脚本，可以：

✅ **批量领取**: 自动从起始 epoch 领取到结束 epoch  
✅ **分批处理**: 每次领取指定数量的 epoch（默认 100 个）  
✅ **多账户支持**: 从 pk.txt 读取多个私钥，依次处理  
✅ **智能延迟**: 每次 claim 之间自动延迟，避免 RPC 限流  
✅ **详细统计**: 显示每个账户和总体的成功/失败统计  
✅ **安全确认**: 执行前显示计划并要求确认

---

## 🚀 快速开始

### 基本用法

```bash
# 使用默认配置（epoch 558-1058，每次 100 个）
./batch_claim.sh

# 使用自定义 RPC
./batch_claim.sh --custom-rpc "https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY"
```

### 自定义参数

```bash
./batch_claim.sh \
  --start-epoch 558 \
  --end-epoch 1058 \
  --epochs-per-claim 100 \
  --delay 5 \
  --custom-rpc "YOUR_RPC_URL"
```

---

## ⚙️ 参数说明

| 参数                 | 说明                        | 默认值                                        |
| -------------------- | --------------------------- | --------------------------------------------- |
| `--pk-file`          | 私钥文件路径                | `pk.txt`                                      |
| `--custom-rpc`       | RPC 节点地址                | `https://ethereum-sepolia-rpc.publicnode.com` |
| `--network`          | 网络名称                    | `sepolia`                                     |
| `--start-epoch`      | 起始 epoch                  | `558`                                         |
| `--end-epoch`        | 结束 epoch                  | `1058`                                        |
| `--epochs-per-claim` | 每次领取的 epoch 数量       | `100`                                         |
| `--delay`            | 每次 claim 之间的延迟（秒） | `5`                                           |

---

## 📊 执行流程

### 1. 计算 Claim 计划

脚本会自动计算需要多少次 claim：

```
Total epochs to claim: 501 (558-1058)
Total claim operations: 6 (per account)

Batch #1: Epochs 558 - 657 (100 epochs)
Batch #2: Epochs 658 - 757 (100 epochs)
Batch #3: Epochs 758 - 857 (100 epochs)
Batch #4: Epochs 858 - 957 (100 epochs)
Batch #5: Epochs 958 - 1057 (100 epochs)
Batch #6: Epochs 1058 - 1058 (1 epoch)
```

### 2. 确认执行

```bash
Continue with batch claim? (y/N) y
```

### 3. 批量领取

对于每个账户：

1. 从 epoch 558 开始
2. 每次领取 100 个 epoch
3. 延迟 5 秒
4. 继续下一批，直到 epoch 1058

---

## 📈 输出示例

```bash
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        🎁 Batch Claim Script
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 Private Key File: pk.txt
🌐 RPC URL: https://ethereum-sepolia-rpc.publicnode.com
🌐 Network: sepolia
📊 Start Epoch: 558
📊 End Epoch: 1058
📦 Epochs per Claim: 100
⏱️  Delay between Claims: 5s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Claim Plan:
   Total epochs to claim: 501
   Total claim operations: 6 (per account)

   Batch #1: Epochs 558 - 657 (100 epochs)
   Batch #2: Epochs 658 - 757 (100 epochs)
   Batch #3: Epochs 758 - 857 (100 epochs)
   Batch #4: Epochs 858 - 957 (100 epochs)
   Batch #5: Epochs 958 - 1057 (100 epochs)
   Batch #6: Epochs 1058 - 1058 (1 epoch)

Continue with batch claim? (y/N) y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 Processing Account #1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔑 Private Key: 0x1234567...abcdef12

🔄 Batch #1/6
💰 Account #1: Claiming epochs 558 to 657...
✅ Claim successful! (epochs 558-657)
⏳ Waiting 5s before next claim...

🔄 Batch #2/6
💰 Account #1: Claiming epochs 658 to 757...
✅ Claim successful! (epochs 658-757)
⏳ Waiting 5s before next claim...

...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Account #1 Summary:
   Successful claims: 6/6
   Failed claims: 0/6
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        📊 Final Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total accounts processed: 3
Total claim operations: 18
✅ Successful: 18
❌ Failed: 0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 All claims completed successfully!
```

---

## 🎯 使用场景

### 场景 1: 默认配置（558-1058）

```bash
./batch_claim.sh
```

### 场景 2: 自定义范围

```bash
# 只领取 epoch 600-800
./batch_claim.sh --start-epoch 600 --end-epoch 800
```

### 场景 3: 调整每次领取数量

```bash
# 每次领取 50 个 epoch
./batch_claim.sh --epochs-per-claim 50
```

### 场景 4: 调整延迟

```bash
# 每次 claim 之间延迟 10 秒
./batch_claim.sh --delay 10
```

### 场景 5: 使用不同的私钥文件

```bash
./batch_claim.sh --pk-file "my_keys.txt"
```

---

## 🎛️ 使用 tmux 后台运行（推荐）

对于大量 epoch 的领取，建议使用 tmux 后台运行：

```bash
# 创建新会话
tmux new -s batch_claim

# 运行脚本
./batch_claim.sh

# 按 Ctrl+B, D 分离会话（脚本继续运行）

# 稍后重新连接查看进度
tmux attach -t batch_claim
```

---

## ⏱️ 时间估算

假设每次 claim 需要 10 秒（包括延迟）：

| Epochs         | Claims | Time per Account | For 3 Accounts |
| -------------- | ------ | ---------------- | -------------- |
| 501 (558-1058) | 6      | ~1 分钟          | ~3 分钟        |
| 1000           | 10     | ~1.5 分钟        | ~4.5 分钟      |
| 2000           | 20     | ~3 分钟          | ~9 分钟        |

---

## ⚠️ 注意事项

### 1. Gas 费用

每次 claim 都需要消耗 gas，请确保：

- 账户有足够的 ETH 支付 gas
- 在 Sepolia 测试网，可以从水龙头获取测试 ETH

### 2. RPC 限流

- 使用私有 RPC（Alchemy, Infura）可以避免限流
- 默认的 5 秒延迟通常足够
- 如果遇到限流，可以增加 `--delay` 参数

### 3. 已领取的 Epoch

- worm-miner 会自动跳过已经领取过的 epoch
- 重复运行脚本是安全的

### 4. 中断恢复

如果脚本中断：

- 记录最后成功的 epoch
- 使用 `--start-epoch` 从中断的地方继续

```bash
# 从 epoch 758 继续
./batch_claim.sh --start-epoch 758
```

---

## 🐛 故障排除

### 问题 1: Claim 失败

**可能原因**:

- Gas 不足
- RPC 连接问题
- Epoch 已经被领取

**解决方法**:

```bash
# 检查账户余额
cast balance YOUR_ADDRESS --rpc-url YOUR_RPC

# 使用 worm-miner info 检查
worm-miner info \
  --network sepolia \
  --private-key YOUR_KEY \
  --custom-rpc YOUR_RPC
```

### 问题 2: RPC 超时

**解决方法**:

- 更换更快的 RPC
- 增加延迟时间

```bash
./batch_claim.sh --delay 10 --custom-rpc "YOUR_BETTER_RPC"
```

### 问题 3: 脚本卡住

**解决方法**:

- 按 Ctrl+C 停止
- 检查 RPC 连接
- 从最后成功的 epoch 重新开始

---

## 📚 相关文档

- [QUICK_START.md](./QUICK_START.md) - 快速开始指南
- [AUTO_BURN_PARTICIPATE_README.md](./AUTO_BURN_PARTICIPATE_README.md) - 批量 burn & participate 文档
- [README.md](./README.md) - 项目主文档

---

## 🧮 计算示例

### 示例 1: 默认配置

```
Start: 558
End: 1058
Per claim: 100

Total epochs: 1058 - 558 + 1 = 501
Total claims: 501 / 100 = 6 (5次100个 + 1次1个)
```

### 示例 2: 自定义配置

```
Start: 100
End: 500
Per claim: 50

Total epochs: 500 - 100 + 1 = 401
Total claims: 401 / 50 = 9 (8次50个 + 1次1个)
```

---

## 🎓 高级用法

### 并行处理多个账户（不推荐）

虽然脚本设计为串行处理，但如果你想并行处理：

```bash
# 为每个账户创建单独的私钥文件
head -n 1 pk.txt > pk1.txt
tail -n +2 pk.txt | head -n 1 > pk2.txt

# 在不同的 tmux 会话中运行
tmux new -s claim1 './batch_claim.sh --pk-file pk1.txt'
tmux new -s claim2 './batch_claim.sh --pk-file pk2.txt'
```

### 只领取特定范围

```bash
# 只领取中间的 epoch
./batch_claim.sh --start-epoch 700 --end-epoch 900
```

### 细粒度控制

```bash
# 每次只领取 10 个 epoch，延迟 2 秒
./batch_claim.sh --epochs-per-claim 10 --delay 2
```

---

## ✅ 检查清单

运行前确认：

- [ ] `pk.txt` 文件已创建并包含私钥
- [ ] 账户有足够的 ETH 支付 gas
- [ ] RPC 节点可用且稳定
- [ ] 已了解要领取的 epoch 范围
- [ ] 如长时间运行，建议使用 tmux

---

**准备好了？开始批量 claim 吧！** 🎁
