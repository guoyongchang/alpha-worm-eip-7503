# 🔧 Burn 命令修正说明

**更新时间**: 2025-11-14 10:53:46 +08:00

## 📋 修正内容

### 问题描述

之前脚本中使用的 `worm-miner burn` 命令参数不正确：

❌ **错误的用法**:

```bash
worm-miner burn \
  --network sepolia \
  --private-key 0x... \
  --amount 1 \
  --spend 0.999 \
  --fee 0.001 \
  --custom-rpc https://...
```

### 正确用法

根据实际代码和用户反馈，正确的用法应该是：

✅ **正确的用法**:

```bash
worm-miner burn \
  --network sepolia \
  --private-key 0x... \
  --amount 10 \
  --spend 10 \
  --custom-rpc https://...
```

### 关键变更

1. **`--amount` 和 `--spend` 必须一致**

   - 之前错误地将它们设置为不同的值
   - 现在它们使用相同的燃烧金额

2. **移除 `--fee` 参数**
   - `worm-miner burn` 命令不需要单独指定 fee
   - Fee 会自动处理

## 🔄 已更新的文件

### 1. `auto_burn_participate.sh`

**修改前**:

```bash
worm-miner burn \
    --network "$NETWORK" \
    --private-key "$private_key" \
    --amount 1 \
    --spend "$amount" \
    --fee 0.001 \
    --custom-rpc "$CUSTOM_RPC"
```

**修改后**:

```bash
worm-miner burn \
    --network "$NETWORK" \
    --private-key "$private_key" \
    --amount "$amount" \
    --spend "$amount" \
    --custom-rpc "$CUSTOM_RPC"
```

### 2. `autoburn.sh`

**修改前**:

```bash
worm-miner burn \
    --network sepolia \
    --private-key "$PRIVATE_KEY" \
    --amount 1 \
    --spend 0.999 \
    --fee 0.001 \
    --custom-rpc "$CUSTOM_RPC"
```

**修改后**:

```bash
worm-miner burn \
    --network sepolia \
    --private-key "$PRIVATE_KEY" \
    --amount 1 \
    --spend 1 \
    --custom-rpc "$CUSTOM_RPC"
```

### 3. `memory_bank.md`

更新了以下内容：

- `autoburn.sh` 的核心参数说明
- `worm-miner burn` 命令参数列表
- 添加了修正更新日志

## ✅ 验证

所有脚本已通过语法检查：

```bash
✅ auto_burn_participate.sh - Syntax OK
✅ autoburn.sh - Syntax OK
```

## 📝 使用示例

### 单次 burn（固定金额）

```bash
worm-miner burn \
  --network sepolia \
  --private-key 0xYOUR_PRIVATE_KEY \
  --amount 1 \
  --spend 1 \
  --custom-rpc https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
```

### 批量 burn（动态计算金额）

使用 `auto_burn_participate.sh` 脚本：

```bash
./auto_burn_participate.sh \
  --custom-rpc "https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY"
```

脚本会自动：

1. 查询每个账户的 ETH 余额
2. 计算可燃烧金额 = 余额 - 0.1 ETH（精确到 2 位小数）
3. 使用相同的值设置 `--amount` 和 `--spend`

例如：

- 余额 = 0.5 ETH
- 燃烧金额 = 0.5 - 0.1 = 0.40 ETH
- 命令: `--amount 0.40 --spend 0.40`

## ⚠️ 重要提示

1. **`--amount` 和 `--spend` 必须相同**

   - 这是 worm-miner 的正确用法
   - 设置不同的值可能导致错误

2. **不要手动添加 `--fee`**

   - worm-miner 会自动处理 fee
   - 手动添加可能导致参数冲突

3. **金额精度**
   - 建议保留到小数点后 2 位
   - 避免使用过多小数位

## 🔗 相关文档

- [QUICK_START.md](./QUICK_START.md) - 快速开始指南
- [AUTO_BURN_PARTICIPATE_README.md](./AUTO_BURN_PARTICIPATE_README.md) - 详细使用文档
- [memory_bank.md](./memory_bank.md) - 项目记忆库

---

**感谢用户反馈，帮助我们修正了这个重要的命令参数问题！** 🙏
