# ************************* JaguarMicro Confidential *************************

# FSDB 波形记录控制
if {[info exists ::env(WAVE)] && $env(WAVE) == "fsdb"} {
    puts "FSDB waveform dumping enabled: $env(WAVE)"
    
    # 记录所有层级的信号
    fsdbDumpvars 0 "top_tb" "+all"
    
    # 条件记录多维数组
    if {[info exists ::env(MEM)] && $env(MEM) == "on"} {
        puts "Memory array dumping enabled"
        fsdbDumpMDA 0 "top_tb"
    }
    
    # 条件记录 SVA 断言
    if {[info exists ::env(SVA)] && $env(SVA) == "on"} {
        puts "SVA assertion dumping enabled"
        fsdbDumpSVA 0 "top_tb"
    }
} else {
    puts "FSDB waveform dumping disabled"
}

# 仿真模式控制
if {[info exists ::env(GUI)] && $env(GUI) == "off"} {
    puts "Running in batch mode"
    run
} else {
    puts "Running in interactive GUI mode"
}

