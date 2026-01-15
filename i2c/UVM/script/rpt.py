#!/usr/bin/env python
#******************************************************************************
#   Copyright   : Zzy Reserved
#   File        : jm.py
#   Author      : zzy
#   Modified    : 25-10-22 Created
#   Description : Used for report results analysis.
#
#                 For example:  python3 rpt.py -p tc_wwdg_reg_test --output custom_report.log
#                               --output is set by default
#
#                 Find passed/failed files and record them in custom_report.log
#
#                   /path/to/tc_wwdg_reg_test_001.log : fail
#                   /path/to/tc_wwdg_reg_test_002.log : pass
#                   /path/to/tc_wwdg_reg_test_003.log : ongoing
#******************************************************************************
#!/usr/bin/env python
import sys
import os
import argparse
import logging
from typing import List

def parse_arguments():
    parser = argparse.ArgumentParser(description="Test Case Result Analyzer")
    parser.add_argument("-p", "--prefix", required=True, help="Test case prefix")
    return parser.parse_args()

def find_test_files(prefix: str) -> List[str]:
    """查找测试日志文件"""
    workhome = os.getenv('WORK_HOME')
    test_dir = os.path.join(workhome,'UVM','sim','out','test')
    matched_files = []
    
    for root, _, files in os.walk(test_dir):
        for filename in files:
            if (filename.endswith('.log') and 
                prefix in filename and
                not filename.endswith('_summary.log')):
                matched_files.append(os.path.join(root, filename))
    
    return matched_files

class TestCaseAnalyzer:
    def __init__(self, file_list: List[str]):
        self.file_list = file_list
        self.pass_cases = []
        self.fail_cases = []
        self.ongoing_cases = []

    def _check_keywords(self, filepath: str) -> str:
        """检查测试结果"""
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                
                if 'UVM REPORT SUMMARY' in content:
                    if 'UVM_ERROR :    0' in content and 'UVM_FATAL :    0' in content:
                        return 'pass'
                    else:
                        return 'fail'
                
                if 'TEST CASE PASSED' in content:
                    return 'pass'
                if 'TEST CASE FAILED' in content:
                    return 'fail'
                    
                return 'ongoing'
                
        except Exception:
            return 'ongoing'

    def analyze(self):
        """执行分析"""
        for filepath in self.file_list:
            status = self._check_keywords(filepath)
            if status == 'pass':
                self.pass_cases.append(filepath)
            elif status == 'fail':
                self.fail_cases.append(filepath)
            else:
                self.ongoing_cases.append(filepath)

def main():
    args = parse_arguments()
    
    # 设置默认输出文件
    workhome = os.getenv('WORK_HOME')
    output_file = os.path.join(workhome, 'UVM', 'sim', 'out', f"{args.prefix}_summary.log")
    
    # 查找测试文件
    test_files = find_test_files(args.prefix)
    
    if not test_files:
        print(f"No test files found with prefix: {args.prefix}")
        return
    
    # 分析结果
    analyzer = TestCaseAnalyzer(test_files)
    analyzer.analyze()
    
    # 生成报告
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"Test Summary for '{args.prefix}':\n")
        f.write(f"Total: {len(analyzer.file_list)}, Pass: {len(analyzer.pass_cases)}, "
                f"Fail: {len(analyzer.fail_cases)}, Ongoing: {len(analyzer.ongoing_cases)}\n\n")
        
        f.write("FAILED:\n")
        for path in analyzer.fail_cases:
            f.write(f"  {os.path.basename(path)}\n")
            
        f.write("\nONGOING:\n")
        for path in analyzer.ongoing_cases:
            f.write(f"  {os.path.basename(path)}\n")
            
        f.write("\nPASSED:\n")
        for path in analyzer.pass_cases:
            f.write(f"  {os.path.basename(path)}\n")
    
    print(f"Report generated: {output_file}")
    print(f"Summary: Total={len(analyzer.file_list)}, Pass={len(analyzer.pass_cases)}, "
          f"Fail={len(analyzer.fail_cases)}")

if __name__ == "__main__":
    main()
