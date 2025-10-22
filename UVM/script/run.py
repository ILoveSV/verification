import os
import sys
import argparse
import random
import time
import threading
from multiprocessing import Process, Queue, Manager
import subprocess
from pathlib import Path
import re

class Run(object):
    'Run for some test cases'
    
    def __init__(self, args):
        self.all_cmd = ['regr']
        self.__dict__.update(vars(args))
        self.workarea = ''
        self.testcase = self.tc
        
        # 使用Manager创建共享的统计字典
        self.manager = Manager()
        self.shared_results = self.manager.dict({
            'COMP_DONE': 0,
            'COMP_ERROR': 0, 
            'NOT_RUN': 0,
            'PASS': 0,
            'FAIL': 0,
            'WARN': 0,
            'ABORT': 0,
            'TOTAL': 0
        })
        
        # 用于进程间通信的队列
        self.result_queue = Queue()
        
    def colorize(self, text, color_code):
        return "\033[{};1m{}\033[0m".format(color_code, text)
    
    def red(self, text):
        print(self.colorize(text, 31))
    
    def green(self, text):
        print(self.colorize(text, 32))
    
    def blue(self, text):
        print(self.colorize(text, 34))
    
    def yellow(self, text):
        print(self.colorize(text, 33))
    
    def check_env(self, envname):
        if os.getenv(envname) is None:
            self.red("[Error]: Please source workarea - environment variable '{}' not set".format(envname))
            sys.exit()
        else:
            return os.getenv(envname)
    
    def gen_path(self):
        self.workarea = self.check_env('WORK_HOME')
        self.outpath = os.path.join(self.workarea, 'out')
        os.makedirs(self.outpath, exist_ok=True)
    
    def run_command(self, cmd, task_name="", capture_output=True, realtime_output=False):
        """运行命令并处理输出"""
        self.blue("[INFO] {}: {}".format(task_name, cmd))
        
        try:
            if not realtime_output:
                # 不实时显示，只捕获输出用于分析
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
                return result.returncode == 0, result.stdout, result.stderr
            else:
                # 实时输出到控制台
                process = subprocess.Popen(cmd, shell=True, 
                                         stdout=subprocess.PIPE, 
                                         stderr=subprocess.STDOUT,
                                         universal_newlines=True,
                                         bufsize=1)
                
                output_lines = []
                for line in process.stdout:
                    print(line, end='', flush=True)  # 实时显示每一行
                    output_lines.append(line)
                
                process.wait()
                output = ''.join(output_lines)
                return process.returncode == 0, output, ""
                
        except Exception as e:
            self.red("[ERROR] Failed to run command: {}".format(str(e)))
            return False, "", str(e)
    
    def analyze_simulation_result(self, output, seed):
        """分析仿真输出判断测试结果"""
        # 检查常见的成功模式
        success_patterns = [
            r'TEST CASE PASSED',
            r'UVM_ERROR\s*:\s*0',
            r'UVM_FATAL\s*:\s*0', 
            r'Simulation\s+passed',
            r'PASSED',
            r'chk pass',
            r'UVM_REPORT_INFO'
        ]
        
        # 检查常见的失败模式
        failure_patterns = [
            r'TEST CASE FAILED',
            r'UVM_ERROR\s*:\s*[1-9]',
            r'UVM_FATAL\s*:\s*[1-9]',
            r'Simulation\s+failed',
            r'FAILED'
        ]
        
        # 优先检查明确的结果指示
        if any(re.search(pattern, output, re.IGNORECASE) for pattern in success_patterns):
            return 'PASS'
        elif any(re.search(pattern, output, re.IGNORECASE) for pattern in failure_patterns):
            return 'FAIL'
        
        # 如果没有明确结果，检查退出码和最终状态
        if "$finish" in output and "UVM_ERROR :    0" in output and "UVM_FATAL :    0" in output:
            return 'PASS'
        else:
            return 'FAIL'
    
    def do_comp(self):
        """执行编译"""
        self.gen_path()
        
        make_cmd = "python3 $WORK_HOME/UVM/script/jm.py com"
        
        if self.tc is not None:
            make_cmd += " -t {}".format(self.tc)
        
        if self.mode is not None:
            make_cmd += " -mode {}".format(self.mode)
        
        if self.seed is not None:
            make_cmd += " -s {}".format(self.seed)
        
        # 使用verbose参数控制输出
        success, output, error = self.run_command(make_cmd, "Compilation", 
                                                 realtime_output=self.verbose)
        
        if success:
            self.green("[SUCCESS] Compilation completed")
            self.shared_results['COMP_DONE'] += 1
        else:
            self.red("[ERROR] Compilation failed")
            self.shared_results['COMP_ERROR'] += 1
        
        self.shared_results['TOTAL'] += 1
        return success
    
    def _sim_worker(self, seed, result_queue):
        """工作进程函数 - 添加分隔线和输出控制"""
        # 重新创建必要的环境
        testcase = self.testcase
        tc = self.tc
        mode = self.mode
        dump = self.dump
        verbose = self.verbose
        
        workarea = os.getenv('WORK_HOME')
        if not workarea:
            print("ERROR: WORK_HOME environment variable not set")
            result_queue.put(('FAIL', seed))
            return
        
        # 构建仿真命令
        sim_cmd = "python3 $WORK_HOME/UVM/script/jm.py ncrun"
        
        if tc is not None:
            sim_cmd += " -t {}".format(tc)
        
        if mode is not None:
            sim_cmd += " -mode {}".format(mode)
        
        sim_cmd += " -s {}".format(seed)
        
        if dump:
            sim_cmd += " -d"
        
        print("[PROCESS-{}] Starting simulation with seed {}".format(os.getpid(), seed))
        
        if verbose:
              print("")
        try:
            if verbose:
                # 实时显示输出
                process = subprocess.Popen(sim_cmd, shell=True, 
                                         stdout=subprocess.PIPE, 
                                         stderr=subprocess.STDOUT,
                                         universal_newlines=True,
                                         bufsize=1)
                
                output_lines = []
                for line in process.stdout:
                    print(line, end='', flush=True)  # 实时显示仿真输出
                    output_lines.append(line)
                
                process.wait()
                output = ''.join(output_lines)
                
                if verbose:
                    print("")
            else:
                # 不显示输出，只捕获结果
                process = subprocess.run(sim_cmd, shell=True, capture_output=True, text=True)
                output = process.stdout + process.stderr
            
            # 分析结果
            success_patterns = [
                r'TEST CASE PASSED',
                r'UVM_ERROR\s*:\s*0',
                r'UVM_FATAL\s*:\s*0', 
                r'Simulation\s+passed',
                r'PASSED',
                r'chk pass'
            ]
            
            failure_patterns = [
                r'TEST CASE FAILED',
                r'UVM_ERROR\s*:\s*[1-9]',
                r'UVM_FATAL\s*:\s*[1-9]',
                r'Simulation\s+failed',
                r'FAILED'
            ]
            
            # 判断结果
            result = 'FAIL'  # 默认设为FAIL
            if any(re.search(pattern, output, re.IGNORECASE) for pattern in success_patterns):
                result = 'PASS'
                print("[PROCESS-{}] PASS: Simulation with seed {} passed".format(os.getpid(), seed))
            elif any(re.search(pattern, output, re.IGNORECASE) for pattern in failure_patterns):
                result = 'FAIL'
                print("[PROCESS-{}] FAIL: Simulation with seed {} failed".format(os.getpid(), seed))
            elif process.returncode == 0:
                # 检查UVM报告摘要
                if "UVM_REPORT" in output and "UVM_ERROR" in output:
                    # 提取UVM错误和致命错误数量
                    error_match = re.search(r'UVM_ERROR\s*:\s*(\d+)', output)
                    fatal_match = re.search(r'UVM_FATAL\s*:\s*(\d+)', output)
                    
                    errors = int(error_match.group(1)) if error_match else 0
                    fatals = int(fatal_match.group(1)) if fatal_match else 0
                    
                    if errors == 0 and fatals == 0:
                        result = 'PASS'
                        print("[PROCESS-{}] PASS: Simulation with seed {} completed with 0 UVM errors/fatals".format(os.getpid(), seed))
                    else:
                        result = 'FAIL'
                        print("[PROCESS-{}] FAIL: Simulation with seed {} has {} UVM errors and {} UVM fatals".format(
                            os.getpid(), seed, errors, fatals))
                else:
                    result = 'PASS'
                    print("[PROCESS-{}] PASS: Simulation with seed {} completed with return code 0".format(os.getpid(), seed))
            else:
                result = 'FAIL'
                print("[PROCESS-{}] FAIL: Simulation with seed {} failed with return code {}".format(os.getpid(), seed, process.returncode))
            
            result_queue.put((result, seed))
            
        except Exception as e:
            print("[PROCESS-{}] ERROR: Simulation with seed {} failed with exception: {}".format(os.getpid(), seed, str(e)))
            result_queue.put(('FAIL', seed))
    
    def do_sim_regr(self):
        """执行回归测试"""
        time1 = time.time()
        
        total_sims = int(self.node) if self.node > 0 else 1
        parallel_processes = min(int(self.cpu), total_sims)
        
        self.blue("[INFO] Starting {} simulations with {} parallel processes".format(
            total_sims, parallel_processes))
        
        # 生成不同的随机种子
        seeds = [random.randint(1, 1000000) for _ in range(total_sims)]
        
        # 用于收集结果的列表
        results = []
        
        # 分批启动进程
        for i in range(0, total_sims, parallel_processes):
            batch_processes = []
            
            # 启动一批进程
            for j in range(parallel_processes):
                if i + j < total_sims:
                    seed = seeds[i + j]
                    # 创建新的进程，传递必要的参数
                    process = Process(target=self._sim_worker, args=(seed, self.result_queue))
                    process.start()
                    batch_processes.append(process)
                    self.blue("[INFO] Started process {} with seed {}".format(i + j + 1, seed))
            
            # 等待这批进程完成并收集结果
            for process in batch_processes:
                process.join()
            
            # 从队列中获取结果
            while not self.result_queue.empty():
                result, seed = self.result_queue.get()
                results.append((result, seed))
        
        # 统计结果
        pass_count = sum(1 for result, seed in results if result == 'PASS')
        fail_count = sum(1 for result, seed in results if result == 'FAIL')
        
        # 更新共享统计
        self.shared_results['PASS'] += pass_count
        self.shared_results['FAIL'] += fail_count
        self.shared_results['TOTAL'] += len(results)
        
        time2 = time.time()
        self.green("[INFO] All simulations completed in {:.2f} seconds".format(time2 - time1))
        self.green("[SUMMARY] PASS: {}, FAIL: {}, TOTAL: {}".format(pass_count, fail_count, len(results)))
    
    def gen_summary_report(self):
        """生成总结报告"""
        # 使用中文字符宽度计算
        cell_width = 10  # 每个单元格的宽度（英文字符数）
    
        # 构建表头
        header_line = "+" + "-" * (cell_width * 8 + 7) + "+"
        title_line = "|" + "Compilation/Simulation Summary".center(cell_width * 8 + 7) + "|"
    
        # 表头字段
        headers = ["COMP_DONE", "COMP_ERROR", "NOT_RUN", "PASS", "FAIL", "WARN", "ABORT", "TOTAL"]
        header_row = "|" + "|".join(h.center(cell_width) for h in headers) + "|"
    
        # 数据行
        data = [
            str(self.shared_results['COMP_DONE']),
            str(self.shared_results['COMP_ERROR']), 
            str(self.shared_results['NOT_RUN']),
            str(self.shared_results['PASS']),
            str(self.shared_results['FAIL']),
            str(self.shared_results['WARN']),
            str(self.shared_results['ABORT']),
            str(self.shared_results['TOTAL'])
        ]
        data_row = "|" + "|".join(d.center(cell_width) for d in data) + "|"
    
        # 组装完整表格
        string = "\033[34m\n"
        string += header_line + "\n"
        string += title_line + "\n" 
        string += header_line + "\n"
        string += header_row + "\n"
        string += header_line + "\n"
        string += data_row + "\n"
        string += header_line + "\n"
        string += "\033[0m\n"
        print(string)    
        
    def main(self):
        """主执行函数"""
        self.blue("[INFO] Starting regression run for testcase: {}".format(self.testcase))
        
        try:
            if not self.notcomp:
                comp_success = self.do_comp()
                if not comp_success:
                    self.red("[ERROR] Compilation failed, skipping simulations")
                    return
                self.do_sim_regr()
            else:
                self.do_sim_regr()
            
            # 生成最终报告
            self.gen_summary_report()
            
        except KeyboardInterrupt:
            self.yellow("[INFO] Execution interrupted by user")
        except Exception as e:
            self.red("[ERROR] Unexpected error: {}".format(str(e)))
            import traceback
            traceback.print_exc()

# 帮助信息
usage_help = ''' 
Run regression tests for verification environment

Examples:
  python run.py -t my_test -n 4 -u 2        # Run 4 simulations with 2 parallel processes
  python run.py -t my_test -n 1 --notcomp   # Run simulation without recompilation
  python run.py -t my_test -s 1234 -d       # Run with specific seed and waveform dump
  python run.py -t my_test -v               # Run with verbose output
'''

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=usage_help,
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    parser.add_argument('-d', '--dump', action='store_true', 
                       help='Dump waveform option')
    parser.add_argument('-c', '--notcomp', action='store_true', 
                       help='Skip compilation option')
    parser.add_argument('-t', '--tc', required=True, metavar='testcase',
                       help='Testcase name (required)')
    parser.add_argument('-n', '--node', type=int, default=1, metavar='num',
                       help='Total number of simulations (default: 1)')
    parser.add_argument('-u', '--cpu', type=int, default=1, metavar='num',
                       help='Number of parallel processes (default: 1)')
    parser.add_argument('-mode', '--mode', metavar='mode', 
                       help='Testbench mode (default: default)')
    parser.add_argument('-s', '--seed', type=int, metavar='seed',
                       help='Specific random seed')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Show detailed compilation and simulation output')
    
    args = parser.parse_args()
    
    # 参数验证
    if args.node < 1:
        print("Error: Number of simulations must be at least 1")
        sys.exit(1)
    
    if args.cpu < 1:
        print("Error: Number of parallel processes must be at least 1")
        sys.exit(1)
    
    # 创建并运行回归测试
    run = Run(args)
    run.main()
