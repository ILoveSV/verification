export TEST_NAME ?= demo_test
export SEED      ?=
export COV       ?= off
VERBOSITY        = UVM_HIGH

# DPI 配置
DPI_SRC_PATH     = ${WORK_HOME}/UVM/dpi
DPI_SRCS         = $(wildcard ${DPI_SRC_PATH}/*.c)
DPI_LIB_PATH     = ${WORK_HOME}/UVM/lib
DPI_LIB_NAME     = dpi
DPI_LIB_FILE     = ${DPI_LIB_PATH}/lib${DPI_LIB_NAME}.so
DPI_INC         += $(VCS_HOME)/include

# 工作目录配置
WORKAREA         = ${WORK_HOME}/UVM/sim
OUT_STEM         = ${WORKAREA}/out
BUILD_OUT_PATH   = ${OUT_STEM}/build
TEST_OUT_PATH    = ${OUT_STEM}/test/${TEST_NAME}
RUN_LOG_FILE   = ${TEST_OUT_PATH}/${TEST_NAME}.log

# 编译和运行选项
UVM_TESTNAME     = ${TEST_NAME}
TB_FILES        += -f ${WORK_HOME}/UVM/tb/tb_filelist.f
TB_FILES        += -f ${WORK_HOME}/DUT/MHSA/rtl_filelist.f
CFLAGS          += -I${DPI_LIB_PATH}
LDFLAGS         += -L${DPI_LIB_PATH} -l${DPI_LIB_NAME} -ldl -Wl,-rpath=${DPI_LIB_PATH}

VCS_OPTS         = -ntb_opts uvm-1.2 -full64 -sverilog -CFLAGS "-m64" -LDFLAGS "-m64 -lpthread" -assertdebug -debug_access+pp -kdb -lca 

# 生成 DPI 库
${DPI_LIB_FILE}: ${DPI_SRCS}
	@mkdir -p ${DPI_LIB_PATH}
	gcc -shared -fPIC -m64 -I${VCS_HOME}/include -o $@ $^

# 主目标
run: com sim

com: ${DPI_LIB_FILE}
	@mkdir -p ${BUILD_OUT_PATH} ${TEST_OUT_PATH}
	@echo "-----------ready to compile----------------"
	@cd ${BUILD_OUT_PATH} && \
	vcs ${VCS_OPTS} \
	    -CFLAGS "${CFLAGS} " \
	    -LDFLAGS "${LDFLAGS}" \
	    -timescale=1ns/1ns ${TB_FILES} \
	    -l comp.log \
      -DVCSMX_FAST_UVM

sim:
	@echo "------------------ready to simulation------------"
	@cd ${BUILD_OUT_PATH} && \
	./simv +UVM_TESTNAME=${UVM_TESTNAME} ${VCS_RUN_OPTS} -l ${RUN_LOG_FILE}
	@echo "Simulation log: ${RUN_LOG_FILE}"

clean:
	@rm -rf ${OUT_STEM}
