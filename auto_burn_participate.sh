#!/bin/bash

# {{CHENGQI:
# Action: Added; Timestamp: 2025-11-14 10:41:15 +08:00; Reason: Create auto burn & participate script for batch processing accounts;
# }}
# {{START MODIFICATIONS}}

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
PK_FILE=${PK_FILE:-"pk.txt"}
CUSTOM_RPC=${CUSTOM_RPC:-"https://1rpc.io/sepolia"}
NETWORK=${NETWORK:-"sepolia"}
RESERVE_ETH="0.1"
NUM_EPOCHS=200
OUTPUT_DIR="rapidsnark_outputs"

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
    --reserve-eth)
      RESERVE_ETH="$2"
      shift 2
      ;;
    --num-epochs)
      NUM_EPOCHS="$2"
      shift 2
      ;;
    *)
      echo "Unknown option $1"
      echo "Usage: $0 [--pk-file FILE] [--custom-rpc URL] [--network NETWORK] [--reserve-eth AMOUNT] [--num-epochs NUM]"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}   Auto Burn & Participate Script${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "📄 Private Key File: ${YELLOW}$PK_FILE${NC}"
echo -e "🌐 RPC URL: ${YELLOW}$CUSTOM_RPC${NC}"
echo -e "🌐 Network: ${YELLOW}$NETWORK${NC}"
echo -e "💰 Reserve ETH: ${YELLOW}$RESERVE_ETH${NC}"
echo -e "📊 Epochs: ${YELLOW}$NUM_EPOCHS${NC}"
echo -e "${BLUE}=======================================${NC}\n"

# 检查 pk.txt 是否存在
if [ ! -f "$PK_FILE" ]; then
    echo -e "${RED}❌ Error: $PK_FILE not found!${NC}"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 函数: 从私钥推导地址
get_address_from_pk() {
    local private_key=$1
    
    # 尝试使用 cast（如果安装了 foundry）
    if command -v cast &> /dev/null; then
        cast wallet address "$private_key" 2>/dev/null
        return $?
    fi
    
    # 如果没有 cast，返回空（后续可用其他方法）
    echo ""
    return 1
}

# 函数: 查询 ETH 余额
get_eth_balance() {
    local address=$1
    
    # 使用 cast balance（如果可用）
    if command -v cast &> /dev/null; then
        local balance_wei=$(cast balance "$address" --rpc-url "$CUSTOM_RPC" 2>/dev/null)
        if [ $? -eq 0 ]; then
            # 转换为 ETH（wei 除以 10^18）
            echo "scale=18; $balance_wei / 1000000000000000000" | bc
            return 0
        fi
    fi
    
    # 使用 RPC 调用
    local response=$(curl -s -X POST "$CUSTOM_RPC" \
        -H "Content-Type: application/json" \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBalance\",\"params\":[\"$address\",\"latest\"],\"id\":1}")
    
    local balance_hex=$(echo "$response" | grep -o '"result":"0x[^"]*"' | sed 's/"result":"//;s/"//')
    
    if [ -z "$balance_hex" ]; then
        echo "0"
        return 1
    fi
    
    # 转换十六进制为十进制
    local balance_wei=$(printf "%d" "$balance_hex")
    echo "scale=18; $balance_wei / 1000000000000000000" | bc
}

# 函数: 获取 BETH 余额
get_beth_balance() {
    local private_key=$1
    
    local info_output=$(worm-miner info \
        --network "$NETWORK" \
        --private-key "$private_key" \
        --custom-rpc "$CUSTOM_RPC" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$info_output" ]; then
        echo "0"
        return 1
    fi
    
    # 提取 BETH balance
    local beth_balance=$(echo "$info_output" | grep "BETH balance:" | awk '{print $3}')
    echo "$beth_balance"
}

# 函数: 执行 burn 操作
perform_burn() {
    local private_key=$1
    local amount=$2
    
    echo -e "${YELLOW}🔥 Executing burn with amount: $amount ETH...${NC}"
    
    worm-miner burn \
        --network "$NETWORK" \
        --private-key "$private_key" \
        --amount "$amount" \
        --spend "$amount" \
        --custom-rpc "$CUSTOM_RPC"
    
    return $?
}

# 函数: 执行 participate 操作
perform_participate() {
    local private_key=$1
    local amount_per_epoch=$2
    local num_epochs=$3
    
    echo -e "${YELLOW}💎 Executing participate with $amount_per_epoch BETH per epoch for $num_epochs epochs...${NC}"
    
    worm-miner participate \
        --amount-per-epoch "$amount_per_epoch" \
        --num-epochs "$num_epochs" \
        --private-key "$private_key" \
        --network "$NETWORK" \
        --custom-rpc "$CUSTOM_RPC"
    
    return $?
}

# 主循环：处理每个私钥
account_num=0
success_count=0
skip_count=0
error_count=0

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
    echo -e "🔑 Private Key: ${private_key:0:10}...${private_key: -8}"
    
    # 获取地址
    echo -e "\n${YELLOW}🔍 Step 1: Getting address...${NC}"
    address=$(get_address_from_pk "$private_key")
    if [ -z "$address" ]; then
        echo -e "${RED}⚠️  Warning: Could not derive address, continuing anyway...${NC}"
        address="unknown"
    else
        echo -e "${GREEN}✅ Address: $address${NC}"
    fi
    
    # 查询 ETH 余额
    echo -e "\n${YELLOW}🔍 Step 2: Checking ETH balance...${NC}"
    eth_balance=$(get_eth_balance "$address")
    
    if [ $? -ne 0 ] || [ -z "$eth_balance" ]; then
        echo -e "${RED}❌ Failed to get ETH balance for account #$account_num${NC}"
        error_count=$((error_count + 1))
        continue
    fi
    
    echo -e "${GREEN}✅ ETH Balance: $eth_balance ETH${NC}"
    
    # 计算可燃烧金额
    burn_amount=$(echo "scale=2; ($eth_balance - $RESERVE_ETH) / 1" | bc)
    
    # 检查是否满足燃烧条件
    if (( $(echo "$eth_balance < $RESERVE_ETH" | bc -l) )); then
        echo -e "${RED}⏭️  Skipping: Balance ($eth_balance ETH) < Reserve ($RESERVE_ETH ETH)${NC}"
        skip_count=$((skip_count + 1))
        continue
    fi
    
    if (( $(echo "$burn_amount <= 0" | bc -l) )); then
        echo -e "${RED}⏭️  Skipping: Burn amount ($burn_amount ETH) <= 0${NC}"
        skip_count=$((skip_count + 1))
        continue
    fi
    
    echo -e "${GREEN}💰 Burn Amount (after reserve): $burn_amount ETH${NC}"
    
    # 执行 burn
    echo -e "\n${YELLOW}🔍 Step 3: Burning tokens...${NC}"
    perform_burn "$private_key" "$burn_amount"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Burn failed for account #$account_num${NC}"
        error_count=$((error_count + 1))
        continue
    fi
    
    echo -e "${GREEN}✅ Burn successful!${NC}"
    
    # 重命名 rapidsnark_output.json
    echo -e "\n${YELLOW}🔍 Step 4: Saving rapidsnark output...${NC}"
    if [ -f "rapidsnark_output.json" ]; then
        # 使用私钥后8位作为文件名（更安全）
        pk_suffix="${private_key: -8}"
        output_filename="${OUTPUT_DIR}/${pk_suffix}.rapidsnark_output.json"
        mv rapidsnark_output.json "$output_filename"
        echo -e "${GREEN}✅ Saved: $output_filename${NC}"
    else
        echo -e "${YELLOW}⚠️  Warning: rapidsnark_output.json not found${NC}"
    fi
    
    # 查询 BETH 余额
    echo -e "\n${YELLOW}🔍 Step 5: Checking BETH balance...${NC}"
    beth_balance=$(get_beth_balance "$private_key")
    
    if [ -z "$beth_balance" ] || (( $(echo "$beth_balance == 0" | bc -l) )); then
        echo -e "${RED}⚠️  Warning: BETH balance is 0 or could not be retrieved${NC}"
        echo -e "${YELLOW}⏭️  Skipping participate for this account${NC}"
        continue
    fi
    
    echo -e "${GREEN}✅ BETH Balance: $beth_balance BETH${NC}"
    
    # 计算每个 epoch 的金额（精确到小数点后18位）
    amount_per_epoch=$(echo "scale=18; $beth_balance / $NUM_EPOCHS" | bc)
    
    echo -e "${GREEN}💎 Amount per epoch: $amount_per_epoch BETH${NC}"
    
    # 执行 participate
    echo -e "\n${YELLOW}🔍 Step 6: Participating in mining...${NC}"
    perform_participate "$private_key" "$amount_per_epoch" "$NUM_EPOCHS"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Participate failed for account #$account_num${NC}"
        error_count=$((error_count + 1))
        continue
    fi
    
    echo -e "${GREEN}✅ Participate successful!${NC}"
    success_count=$((success_count + 1))
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Account #$account_num completed successfully!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 短暂延迟，避免 RPC 限流
    sleep 2
    
done < "$PK_FILE"

# 最终统计
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}        📊 Final Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Total accounts processed: ${BLUE}$account_num${NC}"
echo -e "✅ Successful: ${GREEN}$success_count${NC}"
echo -e "⏭️  Skipped: ${YELLOW}$skip_count${NC}"
echo -e "❌ Errors: ${RED}$error_count${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $success_count -eq $account_num ]; then
    echo -e "${GREEN}🎉 All accounts processed successfully!${NC}"
elif [ $success_count -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some accounts completed, but there were issues with others.${NC}"
else
    echo -e "${RED}❌ No accounts were successfully processed.${NC}"
fi

# {{END MODIFICATIONS}}

