#include <svdpi.h>
#include <stdint.h>
#include <math.h>

#include <string.h>

typedef struct svLogicVecValue {
    uint32_t a;
    uint32_t b;
} svLogicVecValue;

void calculate_QKT_32x16x16x32(
    const svLogicVecValue Q[32][16],  // 直接映射为结构体二维数组
    const svLogicVecValue K[16][32],
    svLogicVecValue QKT[32][32]) 
{
    for (int i = 0; i < 32; ++i) {
        for (int j = 0; j < 32; ++j) {
            int32_t sum = 0;
            for (int kk = 0; kk < 16; ++kk) {
                // 正确访问每个结构体的a字段（低8位）
                int8_t q_val = (int8_t)(Q[i][kk].a & 0xFF);
                int8_t k_val = (int8_t)(K[kk][j].a & 0xFF);
                sum += q_val * k_val;
            }
            // 截断处理
            int32_t truncated = (sum << 11) >> 11; 
            QKT[i][j].a = (uint32_t)(truncated & 0x1FFFFF);
            QKT[i][j].b = 0;  // 确保b字段清零
        }
    }
}
// 处理32x32x32x16配置
void calculate_QKT_32x32x32x16(
    const svLogicVecValue Q[32][32],  // 直接使用结构体二维数组
    const svLogicVecValue K[32][16],
    svLogicVecValue QKT[32][16])
{
    for (int i = 0; i < 32; ++i) {
        for (int j = 0; j < 16; ++j) {
            int32_t sum = 0;
            for (int kk = 0; kk < 32; ++kk) {
                // 提取低8位并符号扩展
                int8_t q_val = (int8_t)(Q[i][kk].a & 0xFF);  // Q:32x32
                int8_t k_val = (int8_t)(K[kk][j].a & 0xFF);  // K:32x16
                sum += q_val * k_val;
            }
            // 截断到21位（保留符号）
            int32_t truncated = (sum << 11) >> 11;
            QKT[i][j].a = (uint32_t)(truncated & 0x1FFFFF);
            QKT[i][j].b = 0;
        }
    }
}
// 处理32x128x128x128配置
void calculate_QKT_32x128x128x128(
    const svLogicVecValue Q[32][128],  // 直接使用结构体二维数组
    const svLogicVecValue K[128][128],
    svLogicVecValue QKT[32][128])
{
    for (int i = 0; i < 32; ++i) {
        for (int j = 0; j < 128; ++j) {
            int64_t sum = 0;
            for (int kk = 0; kk < 128; ++kk) {
                // 提取低8位并符号扩展
                int8_t q_val = (int8_t)(Q[i][kk].a & 0xFF);  // Q:32x128
                int8_t k_val = (int8_t)(K[kk][j].a & 0xFF);  // K:128x128
                sum += (int32_t)q_val * (int32_t)k_val;
            }
            // 截断到23位（保留符号）
            int32_t truncated = (int32_t)((sum << 9) >> 9);
            QKT[i][j].a = (uint32_t)(truncated & 0x7FFFFF);
            QKT[i][j].b = 0;
        }
    }
}


void calculate_QKV(
    const svLogicVecValue X_in[32][128],
    const svLogicVecValue WQ_in[128][128],
    const svLogicVecValue WK_in[128][128],
    const svLogicVecValue WV_in[128][128],
    svLogicVecValue result_Q[32][128],
    svLogicVecValue result_K[32][128],
    svLogicVecValue result_V[32][128]
) {
    // 计算Q矩阵
    for (int i = 0; i < 32; ++i) {
        for (int j = 0; j < 128; ++j) {
            int64_t sum = 0;
            for (int kk = 0; kk < 128; ++kk) {
                // 提取输入矩阵的低8位并进行符号扩展
                int8_t x_val = (int8_t)(X_in[i][kk].a & 0xFF);
                int8_t wq_val = (int8_t)(WQ_in[kk][j].a & 0xFF);
                sum += (int32_t)x_val * (int32_t)wq_val;
            }
            // 饱和处理：将累加和限制在8位有符号数范围内
            int32_t saturated_sum;
            if (sum > 127) {
                saturated_sum = 127;
            } else if (sum < -128) {
                saturated_sum = -128;
            } else {
                saturated_sum = (int32_t)sum;
            }
            // 存储结果并清零b字段
            result_Q[i][j].a = (uint32_t)(saturated_sum & 0xFF);
            result_Q[i][j].b = 0;
        }
    }

    // 计算K矩阵（结构完全对称）
    for (int i = 0; i < 32; ++i) {
        for (int j = 0; j < 128; ++j) {
            int64_t sum = 0;
            for (int kk = 0; kk < 128; ++kk) {
                int8_t x_val = (int8_t)(X_in[i][kk].a & 0xFF);
                int8_t wk_val = (int8_t)(WK_in[kk][j].a & 0xFF);
                sum += (int32_t)x_val * (int32_t)wk_val;
            }
            // 饱和处理
            int32_t saturated_sum;
            if (sum > 127) {
                saturated_sum = 127;
            } else if (sum < -128) {
                saturated_sum = -128;
            } else {
                saturated_sum = (int32_t)sum;
            }
            result_K[i][j].a = (uint32_t)(saturated_sum & 0xFF);
            result_K[i][j].b = 0;
        }
    }

    // 计算V矩阵（结构完全对称）
    for (int i = 0; i < 32; ++i) {
        for (int j = 0; j < 128; ++j) {
            int64_t sum = 0;
            for (int kk = 0; kk < 128; ++kk) {
                int8_t x_val = (int8_t)(X_in[i][kk].a & 0xFF);
                int8_t wv_val = (int8_t)(WV_in[kk][j].a & 0xFF);
                sum += (int32_t)x_val * (int32_t)wv_val;
            }
            // 饱和处理
            int32_t saturated_sum;
            if (sum > 127) {
                saturated_sum = 127;
            } else if (sum < -128) {
                saturated_sum = -128;
            } else {
                saturated_sum = (int32_t)sum;
            }
            result_V[i][j].a = (uint32_t)(saturated_sum & 0xFF);
            result_V[i][j].b = 0;
        }
    }
}


void calculate_mhsa(
    const svLogicVecValue X_in[32][128],
    const svLogicVecValue WQ_in[128][128],
    const svLogicVecValue WK_in[128][128],
    const svLogicVecValue WV_in[128][128],
    const svLogicVecValue W_in[128][128],
    svLogicVecValue out_s8[32][128]
) {
    // 中间结果存储
    int8_t Q[32][128];
    int8_t K[32][128];
    int8_t V[32][128];
    int8_t head_outputs[8][32][16];  // 存储8个头的输出
    int8_t concat_output[32][128];    // 拼接后的输出
    int8_t linear_output[32][128];    // 线性变换输出

    // ======================== 步骤1: 计算Q, K, V矩阵 ========================
    for (int i = 0; i < 32; i++) {
        for (int j = 0; j < 128; j++) {
            int32_t sumQ = 0;
            int32_t sumK = 0;
            int32_t sumV = 0;
            
            // 矩阵乘法累加
            for (int k = 0; k < 128; k++) {
                int8_t x_val = (int8_t)X_in[i][k].a;
                int8_t wq_val = (int8_t)WQ_in[k][j].a;
                int8_t wk_val = (int8_t)WK_in[k][j].a;
                int8_t wv_val = (int8_t)WV_in[k][j].a;
                
                sumQ += x_val * wq_val;
                sumK += x_val * wk_val;
                sumV += x_val * wv_val;
            }
            
            // 饱和处理到8位范围 (23->8)
            Q[i][j] = (sumQ > 127) ? 127 : (sumQ < -128) ? -128 : (int8_t)sumQ;
            K[i][j] = (sumK > 127) ? 127 : (sumK < -128) ? -128 : (int8_t)sumK;
            V[i][j] = (sumV > 127) ? 127 : (sumV < -128) ? -128 : (int8_t)sumV;
        }
    }

    // ======================== 步骤2: 多头注意力计算 ========================
    const int num_heads = 8;
    const int head_dim = 16;
    
    for (int head = 0; head < num_heads; head++) {
        int col_start = head * head_dim;
        
        // 提取当前头的Q, K, V切片
        int8_t head_Q[32][16];
        int8_t head_K[32][16];
        int8_t head_V[32][16];
        
        for (int i = 0; i < 32; i++) {
            for (int j = 0; j < 16; j++) {
                head_Q[i][j] = Q[i][col_start + j];
                head_K[i][j] = K[i][col_start + j];
                head_V[i][j] = V[i][col_start + j];
            }
        }
        
        // ===== 计算Q*K^T (32x16 * 16x32 = 32x32) =====
        int32_t QKT[32][32];
        for (int i = 0; i < 32; i++) {
            for (int j = 0; j < 32; j++) {
                int32_t sum = 0;
                for (int k = 0; k < 16; k++) {
                    sum += head_Q[i][k] * head_K[j][k]; // K转置
                }
                QKT[i][j] = sum;  // 21位中间结果
            }
        }
        
        // ===== 缩放处理 (除以4 = 算术右移2位) =====
        int32_t scaled_QKT[32][32];
        for (int i = 0; i < 32; i++) {
            for (int j = 0; j < 32; j++) {
                scaled_QKT[i][j] = QKT[i][j] >> 2;  // 19位结果
            }
        }
        
        // ===== Softmax (one-hot实现) =====
        int8_t softmax_out[32][32] = {{0}};
        for (int i = 0; i < 32; i++) {
            int32_t max_val = scaled_QKT[i][0];
            int max_idx = 0;
            
            // 查找行最大值
            for (int j = 1; j < 32; j++) {
                if (scaled_QKT[i][j] > max_val) {
                    max_val = scaled_QKT[i][j];
                    max_idx = j;
                }
            }
            
            // One-hot编码
            softmax_out[i][max_idx] = 1;
        }
        
        // ===== 计算softmax_out * V (32x32 * 32x16 = 32x16) =====
        for (int i = 0; i < 32; i++) {
            for (int k = 0; k < 16; k++) {
                int32_t sum = 0;
                for (int j = 0; j < 32; j++) {
                    sum += softmax_out[i][j] * head_V[j][k];
                }
                
                // 饱和处理到8位 (21->8)
                head_outputs[head][i][k] = 
                    (sum > 127) ? 127 : (sum < -128) ? -128 : (int8_t)sum;
            }
        }
    }
    
    // ======================== 步骤3: 拼接8个头的输出 ========================
    for (int head = 0; head < 8; head++) {
        for (int i = 0; i < 32; i++) {
            for (int k = 0; k < 16; k++) {
                concat_output[i][head*16 + k] = head_outputs[head][i][k];
            }
        }
    }
    
    // ======================== 步骤4: 最终线性变换 ========================
    for (int i = 0; i < 32; i++) {
        for (int j = 0; j < 128; j++) {
            int32_t sum = 0;
            for (int k = 0; k < 128; k++) {
                int8_t concat_val = concat_output[i][k];
                int8_t w_val = (int8_t)W_in[k][j].a;
                sum += concat_val * w_val;
            }
            
            // 最终饱和处理到8位 (23->8)
            int8_t result = 
                (sum > 127) ? 127 : (sum < -128) ? -128 : (int8_t)sum;
            
            // 输出赋值
            out_s8[i][j].a = (uint8_t)result;
            out_s8[i][j].b = 0;
        }
    }
}
/*
void calculate_mhsa(
    const svLogicVecValue X_in[32][128],
    const svLogicVecValue WQ_in[128][128],
    const svLogicVecValue WK_in[128][128],
    const svLogicVecValue WV_in[128][128],
    const svLogicVecValue W_in[128][128],
    svLogicVecValue out_s8[32][128]
) {
    // 中间结果存储
    int32_t Q[32][128] = {0};
    int32_t K[32][128] = {0};
    int32_t V[32][128] = {0};
    int32_t attention_output[32][128] = {0};
    int32_t head_outputs[8][32][16] = {0};  // 存储8个头的输出

    // 步骤1: 计算Q, K, V矩阵 (输入投影)
    for (int i = 0; i < 32; i++) {
        for (int j = 0; j < 128; j++) {
            int32_t sumQ = 0;
            int32_t sumK = 0;
            int32_t sumV = 0;
            
            for (int k = 0; k < 128; k++) {
                int8_t x_val = (int8_t)(X_in[i][k].a & 0xFF);
                
                int8_t wq_val = (int8_t)(WQ_in[k][j].a & 0xFF);
                int8_t wk_val = (int8_t)(WK_in[k][j].a & 0xFF);
                int8_t wv_val = (int8_t)(WV_in[k][j].a & 0xFF);
                
                sumQ += x_val * wq_val;
                sumK += x_val * wk_val;
                sumV += x_val * wv_val;
            }
            
            // 饱和处理到8位范围
            Q[i][j] = (sumQ > 127) ? 127 : (sumK < -128) ? -128 : sumQ;
            K[i][j] = (sumK > 127) ? 127 : (sumK < -128) ? -128 : sumK;
            V[i][j] = (sumV > 127) ? 127 : (sumV < -128) ? -128 : sumV;
        }
    }

    // 步骤2: 多头注意力计算 (8个头部)
    const int num_heads = 8;
    const int head_dim = 16;
    
    for (int head = 0; head < num_heads; head++) {
        int col_start = head * head_dim;
        int col_end = (head + 1) * head_dim;
        
        // 提取当前头的Q, K, V切片
        int8_t head_Q[32][16] = {0};
        int8_t head_K[32][16] = {0};
        int8_t head_V[32][16] = {0};
        
        for (int i = 0; i < 32; i++) {
            for (int j = 0; j < 16; j++) {
                head_Q[i][j] = Q[i][col_start + j];
                head_K[i][j] = K[i][col_start + j];
                head_V[i][j] = V[i][col_start + j];
            }
        }
        
        // 计算Q*K^T (32x16 * 16x32 = 32x32)
        int32_t QKT[32][32] = {0};
        for (int i = 0; i < 32; i++) {
            for (int j = 0; j < 32; j++) {
                int32_t sum = 0;
                for (int k = 0; k < 16; k++) {
                    sum += head_Q[i][k] * head_K[j][k]; // K转置
                }
                QKT[i][j] = sum;
            }
        }
        
        // 缩放 (除以4 = 算术右移2位)
        int32_t scaled_QKT[32][32] = {0};
        for (int i = 0; i < 32; i++) {
            for (int j = 0; j < 32; j++) {
                scaled_QKT[i][j] = QKT[i][j] >> 2; // 算术右移
            }
        }
        
        // Softmax (one-hot)
        int8_t softmax_out[32][32] = {0};
        for (int i = 0; i < 32; i++) {
            int32_t max_val = scaled_QKT[i][0];
            int max_idx = 0;
            
            for (int j = 1; j < 32; j++) {
                if (scaled_QKT[i][j] > max_val) {
                    max_val = scaled_QKT[i][j];
                    max_idx = j;
                }
            }
            
            softmax_out[i][max_idx] = 1;
        }
        
        // 计算softmax_out * V (32x32 * 32x16 = 32x16)
        for (int i = 0; i < 32; i++) {
            for (int k = 0; k < 16; k++) {
                int32_t sum = 0;
                for (int j = 0; j < 32; j++) {
                    sum += softmax_out[i][j] * head_V[j][k];
                }
                // 存储当前头的输出
                head_outputs[head][i][k] = sum;
            }
        }
    }
    
    // 步骤3: 拼接8个头的输出
    for (int head = 0; head < num_heads; head++) {
        for (int i = 0; i < 32; i++) {
            for (int k = 0; k < 16; k++) {
                attention_output[i][head * 16 + k] = head_outputs[head][i][k];
            }
        }
    }
    
    // 步骤4: 最终线性变换
    for (int i = 0; i < 32; i++) {
        for (int j = 0; j < 128; j++) {
            int32_t sum = 0;
            for (int k = 0; k < 128; k++) {
                int8_t attn_val = (attention_output[i][k] > 127) ? 127 : 
                                 (attention_output[i][k] < -128) ? -128 : 
                                 (int8_t)attention_output[i][k];
                
                int8_t w_val = (int8_t)(W_in[k][j].a & 0xFF);
                sum += attn_val * w_val;
            }
            
            // 最终饱和处理到8位范围
            int8_t result = (sum > 127) ? 127 : (sum < -128) ? -128 : sum;
            
            // 输出赋值
            out_s8[i][j].a = (uint32_t)(result & 0xFF);
            out_s8[i][j].b = 0;
        }
    }
}*/
