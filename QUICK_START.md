# ⚡ 快速开始指南 - Auto Burn & Participate

## 🎯 5 分钟上手

### 第 1 步: 准备私钥文件

```bash
# 复制示例文件
cp pk.txt.example pk.txt

# 编辑文件，填入你的私钥（每行一个）
nano pk.txt
```

**pk.txt 内容示例**:

```
0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
```

### 第 2 步: 设置执行权限

```bash
chmod +x auto_burn_participate.sh
```

### 第 3 步: 运行脚本

```bash
./auto_burn_participate.sh \
  --custom-rpc "https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY"
```

✅ **完成！** 脚本会自动处理所有账户。

---

## 📋 脚本功能说明

| 步骤 | 操作       | 说明                                   |
| ---- | ---------- | -------------------------------------- |
| 1    | 查询余额   | 获取每个账户的 ETH 余额                |
| 2    | 计算燃烧量 | 余额 - 0.1 ETH（保留 2 位小数）        |
| 3    | 执行 burn  | 燃烧代币参与挖矿                       |
| 4    | 保存输出   | 保存 rapidsnark_output.json            |
| 5    | 查询 BETH  | 获取燃烧后的 BETH 余额                 |
| 6    | 自动参与   | 将 BETH 分成 200 份，参与 200 个 epoch |

---

## ⚙️ 常用参数

```bash
# 使用自定义 RPC
./auto_burn_participate.sh --custom-rpc "YOUR_RPC_URL"

# 修改保留金额（保留 0.2 ETH）
./auto_burn_participate.sh \
  --custom-rpc "YOUR_RPC_URL" \
  --reserve-eth "0.2"

# 使用不同的私钥文件
./auto_burn_participate.sh \
  --pk-file "my_keys.txt" \
  --custom-rpc "YOUR_RPC_URL"

# 参与更多 epochs（分成 500 份）
./auto_burn_participate.sh \
  --custom-rpc "YOUR_RPC_URL" \
  --num-epochs 500
```

---

## 🎛️ 使用 tmux 后台运行（推荐）

```bash
# 创建新会话
tmux new -s burn_participate

# 运行脚本
./auto_burn_participate.sh --custom-rpc "YOUR_RPC_URL"

# 按 Ctrl+B，然后按 D 分离会话（脚本继续运行）

# 稍后重新连接
tmux attach -t burn_participate

# 查看所有会话
tmux ls

# 结束会话
tmux kill-session -t burn_participate
```

---

## 📊 输出说明

### 正常输出

```bash
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
```

### 跳过账户

```bash
⏭️  Skipping: Balance (0.05 ETH) < Reserve (0.1 ETH)
```

### 最终统计

```bash
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        📊 Final Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total accounts processed: 5
✅ Successful: 4
⏭️  Skipped: 1
❌ Errors: 0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 All accounts processed successfully!
```

---

## 📂 输出文件位置

所有 rapidsnark 输出保存在：

```
rapidsnark_outputs/
├── abcdef12.rapidsnark_output.json
├── 34567890.rapidsnark_output.json
└── ...
```

文件名使用私钥的**后 8 位**作为标识。

---

## ⚠️ 重要提示

### 🔐 安全性

1. **保护私钥**: `pk.txt` 已自动加入 `.gitignore`，不会被 Git 追踪
2. **文件权限**: 建议设置 `chmod 600 pk.txt`
3. **不要分享**: 永远不要分享 `pk.txt` 或 rapidsnark 输出文件

### 💰 余额管理

1. **保留金额**: 默认每个账户保留 0.1 ETH 用于 gas
2. **自动跳过**: 余额不足 0.1 ETH 的账户会自动跳过
3. **精度控制**: 燃烧金额精确到 2 位小数

### 🌐 RPC 选择

1. **推荐使用**: Alchemy、Infura 等专业 RPC 服务
2. **避免使用**: 公共 RPC（可能有速率限制）
3. **延迟设置**: 脚本会在每个账户处理完后延迟 2 秒

---

## 🐛 常见问题

### Q: 如何停止脚本？

A: 按 `Ctrl+C` 停止脚本。如果在 tmux 中运行，先重新连接会话再按 `Ctrl+C`。

### Q: 可以只处理部分账户吗？

A: 可以！创建一个新的私钥文件，然后使用 `--pk-file` 参数。

```bash
# 只处理前 3 个账户
head -n 3 pk.txt > pk_test.txt
./auto_burn_participate.sh --pk-file "pk_test.txt" --custom-rpc "YOUR_RPC"
```

### Q: 脚本卡住了怎么办？

A:

1. 检查 RPC 是否正常
2. 按 `Ctrl+C` 停止
3. 更换 RPC 后重新运行

### Q: 如何查看详细日志？

A: 使用 `tee` 命令保存日志：

```bash
./auto_burn_participate.sh --custom-rpc "YOUR_RPC" 2>&1 | tee burn.log
```

---

## 📚 相关文档

- **详细文档**: [AUTO_BURN_PARTICIPATE_README.md](./AUTO_BURN_PARTICIPATE_README.md)
- **项目说明**: [README.md](./README.md)
- **项目记忆库**: [memory_bank.md](./memory_bank.md)

---

## 🎉 开始使用

现在你已经准备好了！运行以下命令开始：

```bash
./auto_burn_participate.sh --custom-rpc "https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY"
```

祝挖矿愉快！ 🚀
