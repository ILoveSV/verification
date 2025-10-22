import os
import sys
import argparse
import random


class jm(object):
    'EDA simulation run and regression class'
#---------------------------------------------初始化------------------------------------------------#
    def __init__(self):
        self.all_cmd      = ['compile','compile_tb','compile_rtl','batch_run','run','ncrun','all','clean','clean_blk','clean_all','verdi', 'regr']
        self.__dict__.update(vars(args))
        # 将命令行参数对象args的属性动态注入当前对象
        # 相当于将 args.xxx 参数全部变成 self.xxx 成员变量
        # 例如：若命令行有 --cov 参数，这里会变成 self.cov = True

        # 初始化路径相关变量（后续由gen_path()方法填充实际值）
        #self.tmppath     = ''          # 临时目录
        self.workarea     = ''          # 工作区根目录（从环境变量 WORKAREA 获取）
        self.blklevel     = ''          # 模块层级
        self.mdlname      = ''          # 模块名称
      #  self.workpath     = ''          # 模块工作路径
        self.makepath     = ''          # Makefile 所在路径
        self.outpath      = ''          # 输出目录
        self.makefile     = ''          # Makefile 完整路径
        self.seedfile     = ''          # 种子文件路径
        self.lsf_cmd      = "bsub  -Is" # 定义默认的作业提交命令，用于通过 LSF集群管理系统提交仿真任务

#---------------------------------------------颜色设置------------------------------------------------#
    def colorize(self,text,color_code):
        print("\033[{};1m{}\033[0m".format(color_code,text))
    def red(self,text):
        self.colorize(text,31)
    def green(self,text):
        self.colorize(text,32)
    def blue(self,text):
        self.colorize(text,34)
#-------------------------------------------路径与环境设置--------------------------------------------------#

    def check_env(self,envname):                                         # 指令拼写检查
        if  os.getenv(envname) is None:
            self.red("[jm][ERROR]: Please execute sop script first!".format(envname))
            sys.exit()
        else:
            return os.getenv(envname)
        
    def gen_path(self):                                    
        self.workarea = self.check_env('WORK_HOME')                       # 指令拼写检查                     
        self.makepath = os.path.join(self.workarea,'UVM','sim')                 # 构建Makefile所在目录路径：WORKAREA/UVM/sim
        self.outpath  = os.path.join(self.makepath,'out')                # 构建输出目录路径：WORKAREA/UVM/sim/out
        self.makefile = os.path.join(self.makepath,'makefile')           # 构建完整的Makefile文件路径：WORKAREA/UVM/sim/makefile
        #self.workpath = os.path.join(self.workarea,'dv',self.blklevel,self.mdlname)# 构建模块工作路径：WORKAREA/dv/模块层级/模块名称/
        #buildname = self.blklevel+'_'+self.mdlname                       # 拼接模块层级和名称作为构建名称


#--------------------------------------------特殊命令处理------------------------------------------------------#
    def check_cmdline_para(self):
        if self.cmd == 'comp':                        # 将comp识别为compile
            self.cmd ='compile'                             
        if self.cmd not in self.all_cmd:              # 错误命令提示
           self.blue("[WARN]:user_defined cmd used,Please check: {}".format(self.cmd))



#----------------------------------------------主函数--------------------------------------------------------#

    def main(self):
        self.gen_path()                                              # 路径与环境设置
        os.chdir(self.makepath)                                      # 切换到Makefile所在目录
        self.check_cmdline_para()                                    # 特殊命令处理
        make_cmd= " ".join(['make -f',self.makefile, self.cmd])      # 执行语句 make -f self.makefile self.cmd

#----------------------------------------------参数设置--------------------------------------------------------#
        if self.no_lsf is True:                                      # LSF开启
            make_cmd = " ".join([make_cmd,'LSF=off'])                     
        if self.mode is not None:                                    # 设置模式参数
            make_cmd = " ".join([make_cmd,'MODE={}'.format(self.mode)])  
        if self.out is not None:                                     # 设置输出目录
            make_cmd = " ".join([make_cmd,'OUT={}'.format(self.out)])

#--------------------------------------编译相关命令处理--------------------------------------------------------#
        if self.tc is not None:                                   # 必须指定测试用例名称
                make_cmd = " ".join([make_cmd,"TEST_NAME={}".format(self.tc)])
        else:
                self.red("[jm][ERROR]: test name must be set by -t option")
                sys.exit()

        if self.cmd in ['compile','compile_tb','compile_rtl','run','all']:

            if self.cmp_opts is not None:                            # 添加编译选项
                make_cmd = " ".join([make_cmd,"CMDLINE_VLOG_OPTS='{}'".format(' '.join(self.cmp_opts))])
            if self.cov is True:                                     # 添加覆盖率收集
                make_cmd = " ".join([make_cmd,'COV=on'])
            if self.idpdt_cmp is True:                               # 独立编译模式
                make_cmd = " ".join([make_cmd,'COMP_ONE=off'])
                

#--------------------------------------仿真相关命令处理------------------------------------------------------#
        if self.cmd in ['batch_run','ncrun','run','all']:
            
            if self.seed is not None:                                 # 设置随机种子
                make_cmd = " ".join([make_cmd,'SEED={}'.format(self.seed)])
            if self.verbosity is not None:                            # 设置日志详细级别
                make_cmd = " ".join([make_cmd,'VERBOSITY={}'.format(self.verbosity)])
            if self.run_opts is not None:                             # 添加运行选项
                make_cmd = " ".join([make_cmd,"CMDLINE_VCS_RUN_OPTS='{}'".format(' '.join(self.run_opts))])
            if self.gui is True:                                      # 启用图形界面调试
                make_cmd = " ".join([make_cmd,'WAVE=fsdb'])
                make_cmd = " ".join([make_cmd,'GUI=on'])
            if self.cfg is not None:                                  # 指定配置文件
                make_cmd = " ".join([make_cmd,"CFG={}".format(self.cfg)])
            if self.random is True:                                   # 启用随机种子
                make_cmd = " ".join([make_cmd,'RANDOM=on'])
            if self.dump is True:                                     # 开启波形记录
                make_cmd = " ".join([make_cmd,'WAVE=fsdb'])
            if self.mem is True:                                      # 记录内存波形
                make_cmd = " ".join([make_cmd,'MEM=on'])
            if self.sva is True:                                      # 记录SVA断言波形
                make_cmd = " ".join([make_cmd,'SVA=on'])

    
            if self.cmd in ['batch_run','ncrun']:                     # 批量运行特殊处理
                if self.cov is True:                                  # 批量收集覆盖率
                    make_cmd = " ".join([make_cmd,'COV=on'])
                if self.idpdt_cmp is True:                            # 批量独立编译
                    make_cmd = " ".join([make_cmd,'COMP_ONE=off'])

#--------------------------------------回归测试命令处理------------------------------------------------------#
        if self.cmd in ['regr']:                                      # 设置并行节点数
            make_cmd = " ".join([make_cmd,'NODE_NO={}'.format(self.node)])
            if self.gui is True:                                      # 回归调试模式
                make_cmd = " ".join([make_cmd,'GUI=on'])
            if self.emc is not None:                                  # 指定EMC回归配置文件
                make_cmd = " ".join([make_cmd,'EMC_NAME={}'.format(self.emc)])
            if self.hvp is not None:                                  # 指定HVP回归配置文件
                make_cmd = " ".join([make_cmd,'HVP_NAME={}'.format(self.hvp)])
            if self.tags is not None:                                 # 指定回归TAG
                make_cmd = " ".join([make_cmd,'TAGS={}'.format(self.tags)])


#--------------------------------------Verdi调试命令处理------------------------------------------------------#
        if self.cmd in ['verdi']:
            if self.cmp_opts is not None:                             # 传递编译选项
                make_cmd = " ".join([make_cmd,'CMDLINE_VLOG_OPTS={}'.format(' '.join(self.cmp_opts))])
            if self.tc is not None:                                   # 指定测试用例
                make_cmd = " ".join([make_cmd,"TEST_NAME={}".format(self.tc)])
            if self.cfg is not None:                                  # 指定配置文件
                make_cmd = " ".join([make_cmd,"CFG={}".format(self.cfg)])
            if self.idpdt_cmp is True:                                # 独立编译模式
                make_cmd = " ".join([make_cmd,'COMP_ONE=off'])
            if self.seed is not None:                                 # 自动获取最后使用的种子
                make_cmd = " ".join([make_cmd,'SEED={}'.format(self.seed)])
            else:
                if os.path.exists(self.seedfile):                     # 检查种子文件
                    with open(self.seedfile,'r') as f:
                        self.seed=int(f.read())
                    make_cmd =" ".join([make_cmd,'SEED={}'.format(self.seed)])

#-------------------------------------------其他选项处理------------------------------------------------------#

        if self.no_kdb is True:                                       # 禁用KDB数据库
             make_cmd = " ".join([make_cmd,'KDB=off'])
        if self.make_opts is not None:                                # 用户自定义Make选项
             make_cmd = " ".join([make_cmd,'{}'.format(' '.join(self.make_opts))])

        self.blue(f"[INFO] 执行命令: {make_cmd}")                      # 执行构建命令
        os.system(make_cmd)
        self.blue(f"[INFO] 命令执行完成: {make_cmd}")


#----------------------------------------帮助文档--------------------------------------------------------------#

usage_help='''jm <cmd> [options]
cmd    :position arguments, Makefile target
options:optional arguments, Makefile control variable

example:
	jm compile -co +define+xxx +define+yyy
	jm run -d  -t tc_sanity -co +define+xxx -ro +a=1 +b=2
	jm verdi   -t tc_sanity
	jm regr    --emc *.emc --hvp *.jm
	...
'''
cmd_help='''
compile_rtl     :Compile RTL only.
compile_tb      :Compile TB only.
comp/compile    :Compile RTL and TB files.
batch_run       :Run simulation only.
ncrun           :pre_run + batch_run + post_run, default pre_run/post_run do nothing
run             :compile + ncrun.
all             :clean_blk + run.
verdi           :open verdi by -t testname,-s seed,-s is optional,load wave if wave exists,load rc if rc exists
regr            :regression
clean           :Delete the temporary files, like log/waves under out directory
clean_blk       :Delete current module out forder,including regression/coverage/build/test temporary files
clean_all       :Delte the whole out folder,including regression/coverage/build/test temporary files
...             :support other makefile target,but optional arguments unavailable
'''
#----------------------------------------输入参数设置-----------------------------------------------------------#
if __name__=='__main__':
    parser = argparse.ArgumentParser(description=usage_help,formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('cmd',help=cmd_help)
    parser.add_argument('-d','--dump',action='store_true',help='dump waveform option')
    parser.add_argument('-c','--cov',action='store_true',help='enable vcs coverage option')
    parser.add_argument('-r','--random',action='store_true',help='gen new random seed simulation,default use last.seed')
    parser.add_argument('-g','--gui',action='store_true',help='use verdi gui debug')
    parser.add_argument('-t','--tc',default=None,metavar='testcase',help='testcase name')
    parser.add_argument('-s','--seed',type=int,metavar='seed',help='testcase seed')
    parser.add_argument('-v','--verbosity',metavar='verbosity',help='testbench display verbosity,default=UVM_LOW')
    parser.add_argument('-co','--cmp_opts',nargs='+',metavar='option',help='testcase compile time option')
    parser.add_argument('-ro','--run_opts',nargs='+',metavar='option',help='testcase run time option')
    parser.add_argument('-mo','--make_opts',nargs='+',metavar='option',help='user define makefile option')
    parser.add_argument('-nk','--no_kdb',action='store_true',help='use filelist mode open verdi')
    parser.add_argument('-nl','--no_lsf',action='store_true',help='do not use lsf cmd,default use lsf cmd:bsub')
    parser.add_argument('-ic','--idpdt_cmp',action='store_true',help='independent compile each testcase')
    parser.add_argument('-cfg','--cfg',metavar='cfg',help='the cfg of testcase,must in test/testcase directory')
    parser.add_argument('-mem','--mem',action='store_true',help='dump mda waveform enable')
    parser.add_argument('-sva','--sva',action='store_true',help='dump sva waveform enable')
    parser.add_argument('-n','--node',type=int,default=50,metavar='num',help='the number of parrallel runs for regression')
    parser.add_argument('-emc','--emc',metavar='*.emc',help='regression emc file')
    parser.add_argument('-hvp','--hvp',metavar='*.hvp',help='regression hvp file')
    parser.add_argument('-tags','--tags',metavar='tag',help='regression tags')
    parser.add_argument('-mode','--mode',metavar='mode',help='for multi mode testbench,default=default')
    parser.add_argument('-out','--out',metavar='out',help='for multi out testbench,default=default')

#----------------------------------------运行程序--------------------------------------------------------------#
    args = parser.parse_args()
    kwargs=(vars(args))
    jm = jm()
    jm.main()
