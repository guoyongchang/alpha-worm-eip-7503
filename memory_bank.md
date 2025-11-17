# Memory Bank - alpha-worm-eip-7503

> **最后更新**: 2025-11-14 09:46:40 +08:00
> **项目版本**: 初始版本

---

## 📋 项目概述

### 核心功能

本项目是一个 **WORM 挖矿自动化脚本工具集**，用于在以太坊 Sepolia 测试网上自动执行 WORM 代币的挖矿操作。项目包含两个核心自动化脚本：

- **autoburn.sh**: 持续不断地执行 burn 操作以参与挖矿
- **autoclaim.sh**: 定期检查并自动领取 WORM 奖励

### 目标用户

- WORM 挖矿参与者
- 需要自动化执行区块链操作的开发者
- 测试网代币挖矿爱好者

### 技术栈

- **脚本语言**: Bash Shell
- **核心工具**: worm-miner (Rust 编写的 CLI 工具)
- **区块链网络**: Ethereum Sepolia Testnet
- **会话管理**: tmux (推荐用于后台运行)

---

## 🗂️ 项目结构

```
alpha-worm-eip-7503/
├── autoburn.sh                  # 自动 burn 脚本（持续执行）
├── autoclaim.sh                 # 自动 claim 脚本（每10分钟检测）
├── auto_burn_participate.sh     # 批量 burn & participate 脚本
├── batch_claim.sh               # 批量 claim 脚本（新增）⭐
├── pk.txt                       # 私钥列表文件（需自行创建）
├── pk.txt.example               # 私钥文件示例
├── rapidsnark_outputs/          # rapidsnark 输出文件存储目录
├── README.md                    # 完整的项目说明文档
├── BATCH_CLAIM_README.md        # 批量 claim 使用文档（新增）⭐
├── img.png                      # 合约查询示例图片
└── memory_bank.md               # 项目记忆库（本文件）
```

### 文件功能说明

#### `autoburn.sh`

- **功能**: 无限循环执行 `worm-miner burn` 命令
- **核心参数**:
  - `--amount 1`: 每次 burn 的数量
  - `--spend 1`: 消耗金额（与 amount 保持一致）
- **运行方式**: 无延迟持续执行
- **可配置项**:
  - `PRIVATE_KEY`: 钱包私钥（默认: "0x65"）
  - `CUSTOM_RPC`: RPC 节点地址（默认: "https://ethereum-sepolia-rpc.publicnode.com"）

#### `autoclaim.sh`

- **功能**: 定期检查并自动领取 WORM 奖励
- **检查频率**: 每 10 分钟（600 秒）
- **核心逻辑**:
  1. 调用 `worm-miner info` 获取账户状态
  2. 解析 `Claimable WORM (10 last epochs)` 字段
  3. 如果可领取金额 > 0，从 `Current epoch - 1` 开始执行 claim
  4. 执行 `worm-miner claim` 命令领取奖励
- **可配置项**:
  - `PRIVATE_KEY`: 钱包私钥
  - `CUSTOM_RPC`: RPC 节点地址（默认: "https://ethereum-sepolia-rpc.publicnode.com"）
  - `NETWORK`: 网络名称（默认: "sepolia"）
  - `NUM_EPOCHS`: 每次 claim 的 epoch 数量（默认: 1）

#### `batch_claim.sh` ⭐ 新增

- **功能**: 批量领取指定范围的 epoch 奖励
- **核心特点**:
  - 自定义 epoch 范围（默认: 558-1058）
  - 分批领取（默认: 每次 100 个 epoch）
  - 多账户支持（从 pk.txt 读取）
  - 智能延迟避免 RPC 限流（默认: 5 秒）
  - 执行前显示计划并要求确认
- **典型用法**:
  ```bash
  ./batch_claim.sh --start-epoch 558 --end-epoch 1058 --epochs-per-claim 100
  ```
- **可配置项**:
  - `PK_FILE`: 私钥文件路径（默认: "pk.txt"）
  - `CUSTOM_RPC`: RPC 节点地址（默认: PublicNode）
  - `START_EPOCH`: 起始 epoch（默认: 558）
  - `END_EPOCH`: 结束 epoch（默认: 1058）
  - `EPOCHS_PER_CLAIM`: 每次领取数量（默认: 100）
  - `DELAY_BETWEEN_CLAIMS`: claim 之间延迟（默认: 5 秒）

#### `auto_burn_participate.sh`

- **功能**: 批量处理多个账户的 burn 和 participate 操作
- **处理流程**（每个账户依次完成）:
  1. 从 `pk.txt` 读取私钥列表
  2. 查询 ETH 余额（通过 RPC 或 cast 命令）
  3. 计算可燃烧金额（余额 - 0.1 ETH，精确到 2 位小数）
  4. 执行 burn 操作（不足 0.1 ETH 的账户自动跳过）
  5. 保存 `rapidsnark_output.json` 为 `{pk后8位}.rapidsnark_output.json`
  6. 查询该账户的 BETH 余额
  7. 将 BETH 平分为 200 份
  8. 执行 participate（200 个 epoch）
- **核心特点**:
  - 串行处理：确保一个账户完全处理完再处理下一个
  - 智能跳过：余额不足的账户自动跳过
  - 文件管理：自动保存和重命名 rapidsnark 输出
  - 统计报告：执行完毕后显示成功/跳过/失败统计
- **可配置项**:
  - `PK_FILE`: 私钥文件路径（默认: "pk.txt"）
  - `CUSTOM_RPC`: RPC 节点地址（默认: "https://ethereum-sepolia-rpc.publicnode.com"）
  - `NETWORK`: 网络名称（默认: "sepolia"）
  - `RESERVE_ETH`: 保留的 ETH 数量（默认: "0.1"）
  - `NUM_EPOCHS`: participate 的 epoch 数量（默认: 200）
  - `MAX_BURN_PER_CALL`: 单次 burn 最大金额（固定: 10 ETH）
- **依赖工具** (可选):
  - `cast`: Foundry 工具，用于查询余额和推导地址（如未安装，脚本会使用 RPC 调用）
  - `bc`: 用于高精度数学计算
  - `curl`: 用于 RPC 调用

---

## 💻 代码特点与规范

### Bash 脚本规范

1. **参数解析**: 使用 `while` 循环和 `case` 语句处理命令行参数
2. **默认值设置**: 使用 `${VAR:-default}` 语法设置默认值
3. **错误处理**: 检查命令退出码（`$?`）并输出状态信息
4. **日志输出**: 使用 emoji 前缀增强可读性
   - 🔥: burn 操作
   - ✅: 成功
   - ❌: 失败
   - 💰: 发现可领取奖励
   - 💤: 无奖励
   - ⏰: 定时提醒
   - 🕐: 开始检查

### 核心设计原则

- **简单直接**: 遵循 KISS 原则，使用简单的 bash 脚本而非复杂框架
- **容错性**: 即使 RPC 出现问题，脚本也能继续运行或易于恢复
- **可配置性**: 支持命令行参数和环境变量两种配置方式
- **可观测性**: 实时输出执行状态和结果

---

## 🔧 重要依赖与配置

### 系统依赖

```bash
# 编译工具和库
build-essential, cmake, libgmp-dev, libsodium-dev, nasm, curl, m4, git, wget, unzip
nlohmann-json3-dev, pkg-config, libssl-dev, libclang-dev

# Rust 工具链
rustc, cargo (通过 rustup 安装)
```

### 核心工具

**worm-miner** (必需)

- **仓库**: https://github.com/worm-privacy/miner
- **安装方式**: `cargo install --path .`
- **关键命令**:
  - `worm-miner info`: 查看账户信息
  - `worm-miner burn`: 执行 burn 操作
  - `worm-miner claim`: 领取奖励
  - `worm-miner participate`: 质押 $bETH 参与挖矿

### 运行环境

- **操作系统**: Linux (Ubuntu/Debian 推荐)
- **推荐工具**: tmux (用于后台运行和会话管理)

### 关键配置

1. **私钥**: 需要有效的以太坊钱包私钥（以 `0x` 开头）
2. **RPC 节点**:
   - 默认: `https://ethereum-sepolia-rpc.publicnode.com` (PublicNode - 快速、免费、隐私优先)
   - 备选: Alchemy API (`https://eth-sepolia.g.alchemy.com/v2/API_KEY`)
   - 备选: `https://1rpc.io/sepolia`
3. **网络**: Sepolia 测试网

### 合约信息

- **合约地址**: `0x78efe1d19d5f5e9aed2c1219401b00f74166a1d9`
- **区块链浏览器**: https://sepolia.etherscan.io
- **关键方法**: `calculateMintAmount` (查询未领取奖励)

---

## ⚠️ 已知问题与注意事项

### RPC 连接问题

- 脚本可能偶尔因 RPC 节点问题而卡住
- 解决方法: 使用 `Ctrl+C` 停止后重新运行

### Epoch 机制

- 合约按 epoch 进行 claim
- 每个 epoch 都需要单独发送交易领取
- 建议及时 claim 避免错过奖励

### 安全性

- ⚠️ **重要**: 不要在脚本中硬编码私钥
- 使用环境变量或命令行参数传递敏感信息
- 确保私钥文件权限正确设置

---

## 📝 worm-miner 命令速查表

### 常用命令

| 命令                     | 功能         | 主要参数                                                                           |
| ------------------------ | ------------ | ---------------------------------------------------------------------------------- |
| `worm-miner --help`      | 查看帮助     | -                                                                                  |
| `worm-miner info`        | 查看账户状态 | `--network`, `--private-key`, `--custom-rpc`                                       |
| `worm-miner burn`        | 执行燃烧操作 | `--amount`, `--spend`, `--network`, `--private-key`, `--custom-rpc`                |
| `worm-miner claim`       | 领取奖励     | `--from-epoch`, `--num-epochs`, `--network`, `--private-key`, `--custom-rpc`       |
| `worm-miner participate` | 质押参与挖矿 | `--amount-per-epoch`, `--num-epochs`, `--network`, `--private-key`, `--custom-rpc` |

### 使用流程

```
1. info (查看状态)
   ↓
2. participate (质押 bETH) [手动操作，一次性]
   ↓
3. burn (持续挖矿) [autoburn.sh 自动化]
   ↓
4. claim (领取奖励) [autoclaim.sh 自动化]
```

### 批量操作流程

```
使用 auto_burn_participate.sh:
1. 准备 pk.txt（多个私钥）
   ↓
2. 执行脚本（自动处理所有账户）
   ├─ 查询余额 → burn → 保存输出
   └─ 查询 BETH → participate (200 epochs)
```

---

## 📝 更新日志

### 2025-11-17 11:04:10 +08:00

- **[新增]** 创建 `batch_claim.sh` 批量 claim 脚本
- **[新增]** 创建 `BATCH_CLAIM_README.md` 详细使用文档
- **[功能]** 支持自定义 epoch 范围批量领取（默认 558-1058）
- **[功能]** 分批领取机制（默认每次 100 个 epoch）
- **[功能]** 多账户批量处理支持
- **[功能]** 智能延迟避免 RPC 限流
- **[功能]** 执行前显示计划并要求用户确认
- **[功能]** 详细的成功/失败统计报告

### 2025-11-14 11:17:52 +08:00

- **[修复]** 添加单次 burn 金额限制（最大 10 ETH），避免超出 worm-miner 限制
- **[修复]** 优化 burn 流程，删除旧的 rapidsnark_output.json 避免冲突
- **[修复]** 改进错误处理，显示详细的退出码
- **[优化]** 更新默认 RPC 为 PublicNode (https://ethereum-sepolia-rpc.publicnode.com)
- **[优化]** PublicNode 提供快速、免费且注重隐私的 RPC 服务
- **[更新]** 更新所有脚本和文档中的默认 RPC 配置

### 2025-11-14 10:59:22 +08:00

- **[安全]** 完成全面的安全检查，确保无敏感信息泄露
- **[安全]** 更新 `.gitignore` 排除 `disperseETH/` 目录（包含真实私钥）
- **[安全]** 修改 `autoburn.sh` 默认私钥为占位符 `0xYOUR_PRIVATE_KEY_HERE`
- **[安全]** 修改 `auto_burn_participate.sh` 默认 RPC 为公共节点
- **[安全]** 确认所有文档仅包含示例数据，无真实 API Key
- **[新增]** 创建 `SECURITY_CHECK_REPORT.md` 安全检查报告
- **[验证]** 所有即将提交的 8 个文件均通过安全检查 ✅

### 2025-11-14 10:53:46 +08:00

- **[修正]** 修复 `worm-miner burn` 命令参数错误
- **[修正]** `--amount` 和 `--spend` 现在保持一致（之前错误地分开设置）
- **[移除]** 移除不必要的 `--fee` 参数
- **[更新]** 更新 `auto_burn_participate.sh` 使用正确的 burn 命令
- **[更新]** 更新 `autoburn.sh` 使用正确的 burn 命令
- **[更新]** 更新文档中的命令参数说明

### 2025-11-14 10:41:15 +08:00

- **[新增]** 创建 `auto_burn_participate.sh` 批量处理脚本
- **[新增]** 创建 `pk.txt.example` 私钥文件示例
- **[功能]** 支持批量账户的 burn 和 participate 操作
- **[功能]** 智能余额管理（保留 0.1 ETH，精确到 2 位小数）
- **[功能]** 自动保存和管理 rapidsnark 输出文件
- **[功能]** 自动将 BETH 平分为 200 个 epoch 参与挖矿
- **[更新]** 完善 worm-miner 命令速查表
- **[更新]** 更新项目结构说明

### 2025-11-14 09:46:40 +08:00

- **[创建]** 初始化项目记忆库
- **[分析]** 完成对项目结构的全面分析
- **[记录]** 记录核心脚本功能、配置项和依赖关系
