#!/bin/bash

# 并行批量 Claim 脚本
# 特点：按批次执行，每个批次所有账户并行处理

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
PK_FILE=${PK_FILE:-"pk.txt"}
CUSTOM_RPC=${CUSTOM_RPC:-"https://ethereum-sepolia-rpc.publicnode.com"}
NETWORK=${NETWORK:-"sepolia"}
START_EPOCH=${START_EPOCH:-558}
END_EPOCH=${END_EPOCH:-1057}
EPOCHS_PER_CLAIM=${EPOCHS_PER_CLAIM:-100}
DELAY_BETWEEN_BATCHES=${DELAY_BETWEEN_BATCHES:-5}  # 每个批次之间的延迟（秒）

# 允许命令行参数覆盖
while [[ $# -gt 0 ]]; do
  case $1 in
    --pk-file)
      PK_FILE="$2"
      shift 2
      ;;
    --custom-rpc)
      CUSTOM_RPC="$2"
      shift 2
      ;;
    --network)
      NETWORK="$2"
      shift 2
      ;;
    --start-epoch)
      START_EPOCH="$2"
      shift 2
      ;;
    --end-epoch)
      END_EPOCH="$2"
      shift 2
      ;;
    --epochs-per-claim)
      EPOCHS_PER_CLAIM="$2"
      shift 2
      ;;
    --delay)
      DELAY_BETWEEN_BATCHES="$2"
      shift 2
      ;;
    *)
      echo "Unknown option $1"
      echo "Usage: $0 [--pk-file FILE] [--custom-rpc URL] [--network NETWORK] [--start-epoch NUM] [--end-epoch NUM] [--epochs-per-claim NUM] [--delay SECONDS]"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}     🚀 Parallel Batch Claim Script${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "📄 Private Key File: ${YELLOW}$PK_FILE${NC}"
echo -e "🌐 RPC URL: ${YELLOW}$CUSTOM_RPC${NC}"
echo -e "🌐 Network: ${YELLOW}$NETWORK${NC}"
echo -e "📊 Start Epoch: ${YELLOW}$START_EPOCH${NC}"
echo -e "📊 End Epoch: ${YELLOW}$END_EPOCH${NC}"
echo -e "📦 Epochs per Claim: ${YELLOW}$EPOCHS_PER_CLAIM${NC}"
echo -e "⏱️  Delay between Batches: ${YELLOW}${DELAY_BETWEEN_BATCHES}s${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# 检查 pk.txt 是否存在
if [ ! -f "$PK_FILE" ]; then
    echo -e "${RED}❌ Error: $PK_FILE not found!${NC}"
    exit 1
fi

# 验证参数
if [ $START_EPOCH -gt $END_EPOCH ]; then
    echo -e "${RED}❌ Error: Start epoch ($START_EPOCH) must be <= End epoch ($END_EPOCH)${NC}"
    exit 1
fi

# 读取所有私钥到数组
declare -a PRIVATE_KEYS
while IFS= read -r private_key || [ -n "$private_key" ]; do
    # 跳过空行和注释
    [[ -z "$private_key" || "$private_key" =~ ^[[:space:]]*# ]] && continue
    
    # 移除可能的空格
    private_key=$(echo "$private_key" | xargs)
    
    # 确保私钥以 0x 开头
    if [[ ! "$private_key" =~ ^0x ]]; then
        private_key="0x$private_key"
    fi
    
    PRIVATE_KEYS+=("$private_key")
done < "$PK_FILE"

# 获取账户数量
ACCOUNT_COUNT=${#PRIVATE_KEYS[@]}

if [ $ACCOUNT_COUNT -eq 0 ]; then
    echo -e "${RED}❌ Error: No valid private keys found in $PK_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Loaded $ACCOUNT_COUNT accounts${NC}\n"

# 计算总共需要多少次 claim
total_epochs=$((END_EPOCH - START_EPOCH + 1))
total_batches=$(( (total_epochs + EPOCHS_PER_CLAIM - 1) / EPOCHS_PER_CLAIM ))

echo -e "${BLUE}📋 Claim Plan:${NC}"
echo -e "   Total accounts: ${YELLOW}$ACCOUNT_COUNT${NC}"
echo -e "   Total epochs to claim: ${YELLOW}$total_epochs${NC}"
echo -e "   Total batches: ${YELLOW}$total_batches${NC}"
echo -e "   ${GREEN}⚡ All accounts will execute in parallel for each batch${NC}"
echo -e ""

# 计算每次 claim 的 epoch 范围
current_epoch=$START_EPOCH
batch_number=0

while [ $current_epoch -le $END_EPOCH ]; do
    batch_number=$((batch_number + 1))
    
    # 计算这次要 claim 多少个 epoch
    remaining_epochs=$((END_EPOCH - current_epoch + 1))
    if [ $remaining_epochs -lt $EPOCHS_PER_CLAIM ]; then
        epochs_to_claim=$remaining_epochs
    else
        epochs_to_claim=$EPOCHS_PER_CLAIM
    fi
    
    end_of_this_claim=$((current_epoch + epochs_to_claim - 1))
    echo -e "   ${BLUE}Batch #$batch_number:${NC} Epochs $current_epoch - $end_of_this_claim (${epochs_to_claim} epochs) ${GREEN}[All $ACCOUNT_COUNT accounts in parallel]${NC}"
    
    current_epoch=$((current_epoch + epochs_to_claim))
done

echo -e ""
read -p "Continue with parallel batch claim? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Aborted by user.${NC}"
    exit 0
fi

echo -e ""

# 创建临时目录存储日志
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 函数: 执行 claim 操作（单个账户）
perform_claim() {
    local private_key=$1
    local from_epoch=$2
    local num_epochs=$3
    local account_index=$4
    local log_file=$5
    
    {
        echo "[Account #$account_index] Claiming epochs $from_epoch to $((from_epoch + num_epochs - 1))..."
        
        worm-miner claim \
            --from-epoch "$from_epoch" \
            --num-epochs "$num_epochs" \
            --private-key "$private_key" \
            --network "$NETWORK" \
            --custom-rpc "$CUSTOM_RPC" 2>&1
        
        local exit_code=$?
        if [ $exit_code -eq 0 ]; then
            echo "SUCCESS"
            return 0
        else
            echo "FAILED:$exit_code"
            return 1
        fi
    } > "$log_file" 2>&1
}

# 统计变量
declare -a account_success_count
declare -a account_failed_count

for ((i=0; i<$ACCOUNT_COUNT; i++)); do
    account_success_count[$i]=0
    account_failed_count[$i]=0
done

total_success=0
total_failed=0

# 主循环：按批次执行
current_epoch=$START_EPOCH
batch_number=0

while [ $current_epoch -le $END_EPOCH ]; do
    batch_number=$((batch_number + 1))
    
    # 计算这次要 claim 多少个 epoch
    remaining_epochs=$((END_EPOCH - current_epoch + 1))
    if [ $remaining_epochs -lt $EPOCHS_PER_CLAIM ]; then
        epochs_to_claim=$remaining_epochs
    else
        epochs_to_claim=$EPOCHS_PER_CLAIM
    fi
    
    end_of_this_claim=$((current_epoch + epochs_to_claim - 1))
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🔄 Batch #$batch_number/$total_batches${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "📦 Claiming epochs: ${YELLOW}$current_epoch - $end_of_this_claim${NC} (${epochs_to_claim} epochs)"
    echo -e "🚀 Processing ${YELLOW}$ACCOUNT_COUNT${NC} accounts in parallel...\n"
    
    # 启动所有账户的 claim（并行）
    declare -a pids
    for ((i=0; i<$ACCOUNT_COUNT; i++)); do
        account_num=$((i + 1))
        private_key="${PRIVATE_KEYS[$i]}"
        log_file="$TEMP_DIR/batch_${batch_number}_account_${account_num}.log"
        
        echo -e "${YELLOW}   [Account #$account_num] Starting claim...${NC}"
        
        # 后台执行
        perform_claim "$private_key" "$current_epoch" "$epochs_to_claim" "$account_num" "$log_file" &
        pids[$i]=$!
    done
    
    echo -e "\n${YELLOW}⏳ Waiting for all $ACCOUNT_COUNT accounts to complete...${NC}\n"
    
    # 等待所有账户完成
    for ((i=0; i<$ACCOUNT_COUNT; i++)); do
        account_num=$((i + 1))
        pid=${pids[$i]}
        log_file="$TEMP_DIR/batch_${batch_number}_account_${account_num}.log"
        
        wait $pid
        exit_code=$?
        
        # 读取结果
        if grep -q "SUCCESS" "$log_file" 2>/dev/null; then
            echo -e "${GREEN}✅ Account #$account_num: Claim successful!${NC}"
            account_success_count[$i]=$((${account_success_count[$i]} + 1))
            total_success=$((total_success + 1))
        else
            error_code=$(grep "FAILED:" "$log_file" | cut -d: -f2)
            echo -e "${RED}❌ Account #$account_num: Claim failed (exit code: ${error_code:-unknown})${NC}"
            account_failed_count[$i]=$((${account_failed_count[$i]} + 1))
            total_failed=$((total_failed + 1))
        fi
    done
    
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Batch #$batch_number completed!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 移动到下一批 epoch
    current_epoch=$((current_epoch + epochs_to_claim))
    
    # 如果还有更多批次，等待一下
    if [ $current_epoch -le $END_EPOCH ]; then
        echo -e "\n${YELLOW}⏸️  Waiting ${DELAY_BETWEEN_BATCHES}s before next batch...${NC}"
        sleep $DELAY_BETWEEN_BATCHES
    fi
done

# 最终统计
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}        📊 Final Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Total accounts: ${BLUE}$ACCOUNT_COUNT${NC}"
echo -e "Total batches: ${BLUE}$total_batches${NC}"
echo -e "Total operations: ${BLUE}$((ACCOUNT_COUNT * total_batches))${NC}"
echo -e ""
echo -e "Overall Statistics:"
echo -e "  ✅ Successful: ${GREEN}$total_success${NC}"
echo -e "  ❌ Failed: ${RED}$total_failed${NC}"
echo -e ""
echo -e "Per Account Statistics:"

for ((i=0; i<$ACCOUNT_COUNT; i++)); do
    account_num=$((i + 1))
    success=${account_success_count[$i]}
    failed=${account_failed_count[$i]}
    pk="${PRIVATE_KEYS[$i]}"
    echo -e "  Account #$account_num (${pk:0:10}...${pk: -8}): ${GREEN}$success success${NC}, ${RED}$failed failed${NC}"
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $total_failed -eq 0 ]; then
    echo -e "${GREEN}🎉 All claims completed successfully!${NC}"
elif [ $total_success -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some claims completed, but there were failures.${NC}"
else
    echo -e "${RED}❌ All claims failed.${NC}"
fi

