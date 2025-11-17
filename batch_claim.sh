#!/bin/bash

# {{CHENGQI:
# Action: Added; Timestamp: 2025-11-14 11:30:00 +08:00; Reason: Create batch claim script for epochs 558-1058;
# }}
# {{START MODIFICATIONS}}

# 批量 Claim 脚本
# 用途：从指定 epoch 开始，每次领取固定数量的 epoch，直到结束 epoch

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
END_EPOCH=${END_EPOCH:-1058}
EPOCHS_PER_CLAIM=${EPOCHS_PER_CLAIM:-100}
DELAY_BETWEEN_CLAIMS=${DELAY_BETWEEN_CLAIMS:-5}  # 每次 claim 之间的延迟（秒）

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
      DELAY_BETWEEN_CLAIMS="$2"
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
echo -e "${BLUE}        🎁 Batch Claim Script${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "📄 Private Key File: ${YELLOW}$PK_FILE${NC}"
echo -e "🌐 RPC URL: ${YELLOW}$CUSTOM_RPC${NC}"
echo -e "🌐 Network: ${YELLOW}$NETWORK${NC}"
echo -e "📊 Start Epoch: ${YELLOW}$START_EPOCH${NC}"
echo -e "📊 End Epoch: ${YELLOW}$END_EPOCH${NC}"
echo -e "📦 Epochs per Claim: ${YELLOW}$EPOCHS_PER_CLAIM${NC}"
echo -e "⏱️  Delay between Claims: ${YELLOW}${DELAY_BETWEEN_CLAIMS}s${NC}"
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

# 函数: 执行 claim 操作
perform_claim() {
    local private_key=$1
    local from_epoch=$2
    local num_epochs=$3
    local account_index=$4
    
    echo -e "${YELLOW}💰 Account #$account_index: Claiming epochs $from_epoch to $((from_epoch + num_epochs - 1))...${NC}"
    
    worm-miner claim \
        --from-epoch "$from_epoch" \
        --num-epochs "$num_epochs" \
        --private-key "$private_key" \
        --network "$NETWORK" \
        --custom-rpc "$CUSTOM_RPC"
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ Claim successful! (epochs $from_epoch-$((from_epoch + num_epochs - 1)))${NC}"
        return 0
    else
        echo -e "${RED}❌ Claim failed with exit code: $exit_code${NC}"
        return 1
    fi
}

# 计算总共需要多少次 claim
total_epochs=$((END_EPOCH - START_EPOCH + 1))
total_claims=$(( (total_epochs + EPOCHS_PER_CLAIM - 1) / EPOCHS_PER_CLAIM ))

echo -e "${BLUE}📋 Claim Plan:${NC}"
echo -e "   Total epochs to claim: ${YELLOW}$total_epochs${NC}"
echo -e "   Total claim operations: ${YELLOW}$total_claims${NC} (per account)"
echo -e ""

# 计算每次 claim 的 epoch 范围
current_epoch=$START_EPOCH
claim_number=0

while [ $current_epoch -le $END_EPOCH ]; do
    claim_number=$((claim_number + 1))
    
    # 计算这次要 claim 多少个 epoch
    remaining_epochs=$((END_EPOCH - current_epoch + 1))
    if [ $remaining_epochs -lt $EPOCHS_PER_CLAIM ]; then
        epochs_to_claim=$remaining_epochs
    else
        epochs_to_claim=$EPOCHS_PER_CLAIM
    fi
    
    end_of_this_claim=$((current_epoch + epochs_to_claim - 1))
    echo -e "   ${BLUE}Batch #$claim_number:${NC} Epochs $current_epoch - $end_of_this_claim (${epochs_to_claim} epochs)"
    
    current_epoch=$((current_epoch + epochs_to_claim))
done

echo -e ""
read -p "Continue with batch claim? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Aborted by user.${NC}"
    exit 0
fi

echo -e ""

# 主循环：处理每个私钥
account_num=0
total_success=0
total_failed=0

while IFS= read -r private_key || [ -n "$private_key" ]; do
    # 跳过空行和注释
    [[ -z "$private_key" || "$private_key" =~ ^[[:space:]]*# ]] && continue
    
    # 移除可能的空格
    private_key=$(echo "$private_key" | xargs)
    
    # 确保私钥以 0x 开头
    if [[ ! "$private_key" =~ ^0x ]]; then
        private_key="0x$private_key"
    fi
    
    account_num=$((account_num + 1))
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📌 Processing Account #$account_num${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "🔑 Private Key: ${private_key:0:10}...${private_key: -8}\n"
    
    # 重置当前 epoch
    current_epoch=$START_EPOCH
    claim_number=0
    account_success=0
    account_failed=0
    
    # 为这个账户执行所有 claim
    while [ $current_epoch -le $END_EPOCH ]; do
        claim_number=$((claim_number + 1))
        
        # 计算这次要 claim 多少个 epoch
        remaining_epochs=$((END_EPOCH - current_epoch + 1))
        if [ $remaining_epochs -lt $EPOCHS_PER_CLAIM ]; then
            epochs_to_claim=$remaining_epochs
        else
            epochs_to_claim=$EPOCHS_PER_CLAIM
        fi
        
        echo -e "${YELLOW}🔄 Batch #$claim_number/$total_claims${NC}"
        
        # 执行 claim
        perform_claim "$private_key" "$current_epoch" "$epochs_to_claim" "$account_num"
        
        if [ $? -eq 0 ]; then
            account_success=$((account_success + 1))
            total_success=$((total_success + 1))
        else
            account_failed=$((account_failed + 1))
            total_failed=$((total_failed + 1))
        fi
        
        # 移动到下一批 epoch
        current_epoch=$((current_epoch + epochs_to_claim))
        
        # 如果还有更多要 claim，等待一下
        if [ $current_epoch -le $END_EPOCH ]; then
            echo -e "${YELLOW}⏳ Waiting ${DELAY_BETWEEN_CLAIMS}s before next claim...${NC}"
            sleep $DELAY_BETWEEN_CLAIMS
        fi
    done
    
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Account #$account_num Summary:${NC}"
    echo -e "   Successful claims: ${GREEN}$account_success${NC}/$total_claims"
    echo -e "   Failed claims: ${RED}$account_failed${NC}/$total_claims"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 账户之间稍微延迟
    echo -e "\n${YELLOW}⏸️  Waiting 3s before next account...${NC}\n"
    sleep 3
    
done < "$PK_FILE"

# 最终统计
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}        📊 Final Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Total accounts processed: ${BLUE}$account_num${NC}"
echo -e "Total claim operations: ${BLUE}$((account_num * total_claims))${NC}"
echo -e "✅ Successful: ${GREEN}$total_success${NC}"
echo -e "❌ Failed: ${RED}$total_failed${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $total_failed -eq 0 ]; then
    echo -e "${GREEN}🎉 All claims completed successfully!${NC}"
elif [ $total_success -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some claims completed, but there were failures.${NC}"
else
    echo -e "${RED}❌ All claims failed.${NC}"
fi

# {{END MODIFICATIONS}}

