export TEST_NAME ?= rkv_i2c_master_rx_status_test
export TEST_DUT  ?= i2c

export SEED ?= 1
VERBOSITY = UVM_LOW
# 波形配置
export WAVE          ?= fsdb
export GUI           ?= off
export MEM           ?= off
export WAVE_FILE     ?= ${TEST_OUT_PATH}/${TEST_NAME}_${SEED}.fsdb
SCRIPT_PATH           = ${WORK_HOME}/UVM/script

ifeq (${WAVE}, fsdb)
VCS_RUN_OPTS += +fsdb+autoflush +fsdbfile+${WAVE_FILE} +fsdb+force
VCS_RUN_OPTS += -ucli -do ${SCRIPT_PATH}/wave_fsdb.do
endif

# 覆盖率配置
export COV        = on
export CM_OPTS    = line+branch+cond+tgl+assert+fsm
CM_NAME           = $(TEST_NAME)_$(SEED)
CM_DIR            = $(COV_OUT_PATH)/$(CM_NAME)
ifeq (${COV}, on)
VCS_OPTS += -cm ${CM_OPTS} 
VCS_OPTS += -cm_tgl portsonly 
VCS_OPTS += -cm_dir $(CM_DIR) 
VCS_OPTS += -cm_name $(CM_NAME)
VCS_OPTS += -cm_glitch 0
VCS_OPTS += -debug_access+all  # 修改为+all
VCS_OPTS += -kdb -lca
endif

# DPI 配置
DPI_SRC_PATH     = ${WORK_HOME}/UVM/dpi
DPI_SRCS         = $(wildcard ${DPI_SRC_PATH}/*.c)
DPI_LIB_PATH     = ${WORK_HOME}/UVM/lib
DPI_LIB_NAME     = dpi
DPI_LIB_FILE     = ${DPI_LIB_PATH}/lib${DPI_LIB_NAME}.so
DPI_INC         += $(VCS_HOME)/include

# 工作目录配置
WORKAREA         = ${WORK_HOME}/UVM/sim
OUT_STEM         = ${WORKAREA}/out
BUILD_OUT_PATH   = ${OUT_STEM}/build
COV_OUT_PATH     = ${OUT_STEM}/coverage/$(TEST_DUT)
TEST_OUT_PATH    = ${OUT_STEM}/test/${TEST_NAME}_${SEED}
RUN_LOG_FILE     = ${TEST_OUT_PATH}/${TEST_NAME}_${SEED}.log

# 编译源文件选项
ifeq (${TEST_DUT}, i2c)
TB_FILES        += -f ${WORK_HOME}/UVM/tb/I2C_filelist.f
TB_FILES        += -f ${WORK_HOME}/DUT/rtl_filelist.f
endif

# 编译和运行选项
UVM_TESTNAME     = ${TEST_NAME}
CFLAGS          += -I${DPI_LIB_PATH}
LDFLAGS         += -L${DPI_LIB_PATH} -l${DPI_LIB_NAME} -ldl -Wl,-rpath=${DPI_LIB_PATH}

VCS_OPTS         = -ntb_opts uvm -full64 -sverilog -CFLAGS "-m64" -LDFLAGS "-m64 -lpthread" -lca
VCS_OPTS        += -debug_access+pp -kdb

# 生成 DPI 库
${DPI_LIB_FILE}: ${DPI_SRCS}
	@mkdir -p ${DPI_LIB_PATH}
	gcc -shared -fPIC -m64 -I${VCS_HOME}/include -o $@ $^

# 主目标
compile:create_build_dir com
run: create_build_dir create_test_dir com sim ana_log
ncrun:create_test_dir sim ana_log

create_out_dir:
	@mkdir -p ${OUT_STEM}

create_build_dir:create_out_dir
	@mkdir -p ${BUILD_OUT_PATH}
	@mkdir -p ${CM_DIR}  # 添加这一行

create_test_dir:create_out_dir
	@mkdir -p ${TEST_OUT_PATH}

com: ${DPI_LIB_FILE} create_build_dir
	@echo "-----------ready to compile----------------"
	@cd ${BUILD_OUT_PATH} && \
	vcs ${VCS_OPTS} \
	    -CFLAGS "${CFLAGS} " \
	    -LDFLAGS "${LDFLAGS}" \
	    -timescale=1ns/1ns ${TB_FILES} \
	    -l comp.log \
			-VCSMX_FAST_UVM

sim:
	@echo "------------------ready to simulation------------"
	@cd ${BUILD_OUT_PATH} && \
	./simv +UVM_TESTNAME=${UVM_TESTNAME} +UVM_VERBOSITY=$(VERBOSITY) ${VCS_RUN_OPTS} \
	-cm ${CM_OPTS} -cm_name ${CM_NAME} -cm_dir ${CM_DIR} \
	-l ${RUN_LOG_FILE}
	@echo "Simulation log: ${RUN_LOG_FILE}"

merge:
	@mkdir -p ${COV_OUT_PATH}/merged
	urg -full64 -dir ${COV_OUT_PATH}/*/ -dbname ${COV_OUT_PATH}/merged/merged_cov -report ${COV_OUT_PATH}/merged/report
	@echo "Coverage merged: ${COV_OUT_PATH}/merged/report/hierarchy.html"


#报告生成
ANALYSE_LOG           = on
FAIL_KEYS            = "UVM_ERROR\b.*[1-9]" "UVM_FATAL\b.*[1-9]" "^MVP TEST FAILED\b" "\bfailed\b" "\bERROR\b" "\bFATAL\b" "Error" "\berror\b" "\bVIRL_MEM_WARNING\b" "\bVIRL_MEM_ERR\b"
PASS_KEYS            = "TEST CASE PASSED"
IGNORE_FAIL_KEYS     = "\bVIRL_MEM_ERR\b" "\bVIRL_MEM_WARNING\b" "UVM_ERROR\s*:\s*0" "UVM_FATAL\s*:\s*0"
ANALYSE_LOG_SCRIPTS = $(wildcard ${WORK_HOME}/UVM/script/verf_log_chk.py)
ifeq ($(ANALYSE_LOG),on)
    ifneq (${ANALYSE_LOG_SCRIPTS},)
        ANALYSE_LOG_CMD = python3 ${ANALYSE_LOG_SCRIPTS} \
                           ${RUN_LOG_FILE} \
                           -o \
                           -fk ${FAIL_KEYS} \
                           $(if ${PASS_KEYS}           ,-pk ${PASS_KEYS}           ,)\
                           $(if ${IGNORE_FAIL_KEYS}    ,-ik ${IGNORE_FAIL_KEYS}    ,)\
                           $(if ${IGNORE_BEFORE_KEY}   ,-i  ${IGNORE_BEFORE_KEY}   ,)\
                           $(if ${IGNORE_AFTER_KEY}    ,-e  ${IGNORE_AFTER_KEY}    ,)\
                           $(if ${START_AFTER_LINE_NUM},-s  ${START_AFTER_LINE_NUM},)
        ifeq (${REGR_FLAG}, 1)
	        ANALYSE_LOG_CMD += -em
        endif
    endif
endif

ana_log:
	@${ANALYSE_LOG_CMD}        
	@echo ${RUN_LOG_FILE}    

clean:
	@rm -rf ${OUT_STEM}
