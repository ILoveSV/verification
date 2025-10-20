# Multi-Head Self-Attention (MHSA) RTL 实现

这个项目实现了一个基于 RTL 的多头自注意力机制（Multi-Head Self-Attention）加速器。该实现采用 SystemVerilog 编写，主要针对 Transformer 架构中的注意力计算进行优化。

## 项目结构

```
RTL/
├── 0-MHSA_top.sv      # 顶层模块，整合所有子模块
├── 1-QKV.sv           # 输入QKV 矩阵计算模块
├── 2-SDPA.sv          # Scaled Dot-Product Attention 模块
├── 3-Concat.sv        # 矩阵拼接模块
├── 4-FinalLinear.sv   # 最终线性变换模块
├──── MAC.sv           # 子模块之矩阵乘法加速器
├──── Quantize.sv      # 子模块之量化模块
├──── Softmax.sv       # 子模块之Softmax 计算模块
└──── Multipiler.sv    # 子模块之乘法器
```

## 模块说明

### 1. MHSA_top
- 顶层模块，整合所有子模块
- 处理输入矩阵 X 和权重矩阵 WQ、WK、WV
- 输出经过注意力计算后的结果

### 2. QKV
- 计算 Query、Key、Value 矩阵
- 输入：X 矩阵和权重矩阵 WQ、WK、WV
- 输出：Q、K、V 矩阵

### 3. SDPA (Scaled Dot-Product Attention)
- 实现注意力计算
- 包含矩阵乘法和 Softmax 操作
- 支持并行计算以提高性能

### 4. Concat
- 将多个注意力头的输出拼接
- 支持 8 个注意力头的输出拼接

### 5. FinalLinear
- 实现最终的线性变换
- 将拼接后的结果转换为所需的输出维度

### 6. MAC (Multiply-Add-Compute)
- 实现矩阵乘法加速
- 支持不同维度的矩阵运算
- 包含流水线设计以提高性能
**包含三个类型的矩阵乘法**

### 7. Quantize
- 实现数据量化
- 支持不同位宽的输入到 8 位输出的转换
- 包含溢出保护机制
**包含三个规格的量化**

### 8. Softmax
- 实现 Softmax 函数
- 支持矩阵形式的输入
- 包含数值稳定性处理

### 9. Multiplier
- 实现乘法器
**包含三个数量规格的乘法器**


## 使用说明

1. 编译环境要求：
   - SystemVerilog 编译器
   - 支持 SystemVerilog 的仿真工具

2. 编译命令：
   ```bash
   vlog -work work -vopt -sv *.sv
   ```

3. 仿真命令：
   ```bash
   vsim -c work.mhsa_top
   ```

## 注意事项

1. 输入数据需要是 8 位有符号数
2. 矩阵维度需要符合模块要求
3. 时钟和复位信号需要正确连接

## 未来改进

1. 添加更多配置选项
2. 优化资源使用
3. 增加更多测试用例
4. 添加性能分析工具

## 作者

- 作者：zy
- 最后修改：2025/05/16

## 许可证

本项目采用 MIT 许可证 