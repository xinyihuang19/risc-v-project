#!/bin/bash
# 设置颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 项目路径
PROJECT_DIR="$PWD"
RTL_DIR="$PROJECT_DIR/phase1/rtl"
OUTPUT_DIR="$PROJECT_DIR/build"

# 创建输出目录
mkdir -p $OUTPUT_DIR

echo "===== RISC-V Verilog 编译 ====="
echo "开始整体项目编译..."

# 直接编译整个项目
echo -e "${YELLOW}使用搜索路径编译顶层模块...${NC}"
iverilog -I "$RTL_DIR" -y "$RTL_DIR" -s open_risc_v -g2012 -o "$OUTPUT_DIR/project.out" "$RTL_DIR/open_risc_v.v" 2> "$OUTPUT_DIR/project.log"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 整体项目编译成功!${NC}"
    echo "输出文件: $OUTPUT_DIR/project.out"
    
    # 询问是否运行仿真
    echo -e "\n${YELLOW}是否运行仿真? [y/N]${NC}"
    read -r run_sim
    if [[ "$run_sim" =~ ^[Yy]$ ]]; then
        echo "运行仿真..."
        vvp "$OUTPUT_DIR/project.out"
    fi
else
    ERROR_COUNT=$(grep -c "error:" "$OUTPUT_DIR/project.log")
    if [ $ERROR_COUNT -gt 0 ]; then
        echo -e "${RED}❌ 编译失败，有 $ERROR_COUNT 个错误${NC}"
        grep "error:" "$OUTPUT_DIR/project.log"
    else
        echo -e "${RED}❌ 编译失败，但没有标准错误消息${NC}"
        echo "查看完整日志: $OUTPUT_DIR/project.log"
        
        # 尝试显示日志内容
        echo -e "${YELLOW}日志内容:${NC}"
        cat "$OUTPUT_DIR/project.log"
        
        # 尝试另一种编译方法
        echo -e "\n${YELLOW}尝试一次性编译所有文件...${NC}"
        iverilog -I "$RTL_DIR" -g2012 -o "$OUTPUT_DIR/all_files.out" "$RTL_DIR"/*.v 2> "$OUTPUT_DIR/all_files.log"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ 一次性编译所有文件成功!${NC}"
        else
            echo -e "${RED}❌ 一次性编译也失败了${NC}"
            echo "错误信息:"
            cat "$OUTPUT_DIR/all_files.log"
        fi
    fi
fi