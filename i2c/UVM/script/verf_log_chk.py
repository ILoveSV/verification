#******************************************************************************
#   Copyright   : xbj Reserved
#   File        : verf_log_chk.py
#   Author      : xbj 
#   Modified    : 22-12-19 Created
#******************************************************************************

import sys
import re
import os
import argparse
import logging
from datetime import datetime

def print_result(pass_flag):
    string = ""
    if pass_flag :
        string = string + "\n"
        string = string + "PPPPPPPPPPPPPPPP           A                SSSSSS              SSSSSS         EEEEEEEEEEEEEEEEE   DDDDDDDDDDDD\n"
        string = string + "PPPPPPPPPPPPPPPPP         AAA            SSSSSSSSSSSSS       SSSSSSSSSSSSS     EEEEEEEEEEEEEEEEE   DDDDDDDDDDDDDD\n"
        string = string + "PPP           PPP         AAA          SSSSS       SSSSS   SSSSS       SSSSS   EEE                 DDD        DDDD\n"
        string = string + "PPP           PPP        AAAAA         SSS           SSS   SSS           SSS   EEE                 DDD          DDD\n"
        string = string + "PPP          PPPP        AAAAA          SSS                 SSS                EEE                 DDD           DDD\n"
        string = string + "PPPPPPPPPPPPPPPP        AAAAAAA         SSSS                SSSS               EEE                 DDD           DDD\n"
        string = string + "PPPPPPPPPPPPPP          AAA AAA          SSSSSS              SSSSSS            EEE                 DDD           DDD\n"
        string = string + "PPP                    AAA   AAA           SSSSSS              SSSSSS          EEEEEEEEEEEEEEEEE   DDD           DDD\n"
        string = string + "PPP                    AAA   AAA              SSSSSS              SSSSSS       EEEEEEEEEEEEEEEEE   DDD           DDD\n"
        string = string + "PPP                   AAA     AAA               SSSSSS              SSSSSS     EEE                 DDD           DDD\n"
        string = string + "PPP                   AAAAAAAAAAA                  SSSS                SSSS    EEE                 DDD           DDD\n"
        string = string + "PPP                  AAAAAAAAAAAAA                  SSS                 SSS    EEE                 DDD           DDD\n"
        string = string + "PPP                 AAA         AAA    SSS           SSS   SSS           SSS   EEE                 DDD          DDD\n"
        string = string + "PPP                 AAA         AAA    SSSSS       SSSSS   SSSSS       SSSSS   EEE                 DDD        DDDD\n"
        string = string + "PPP                AAA           AAA     SSSSSSSSSSSSS       SSSSSSSSSSSSS     EEEEEEEEEEEEEEEEE   DDDDDDDDDDDDDD\n"
        string = string + "PPP                AAA           AAA        SSSSSS              SSSSSS         EEEEEEEEEEEEEEEEE   DDDDDDDDDDDD\n"
    else :
        string = string + "\n"
        string = string + "FFFFFFFFFFFFFFFFF           A                IIIIIII       LLL                 EEEEEEEEEEEEEEEEE   DDDDDDDDDDDD\n"
        string = string + "FFFFFFFFFFFFFFFFF          AAA                 III         LLL                 EEEEEEEEEEEEEEEEE   DDDDDDDDDDDDDD\n"
        string = string + "FFF                        AAA                 III         LLL                 EEE                 DDD        DDDD\n"
        string = string + "FFF                       AAAAA                III         LLL                 EEE                 DDD          DDD\n"
        string = string + "FFF                       AAAAA                III         LLL                 EEE                 DDD           DDD\n"
        string = string + "FFFFFFFFFFFF             AAAAAAA               III         LLL                 EEE                 DDD           DDD\n"
        string = string + "FFFFFFFFFFFF             AAA AAA               III         LLL                 EEE                 DDD           DDD\n"
        string = string + "FFF                     AAA   AAA              III         LLL                 EEEEEEEEEEEEEEEEE   DDD           DDD\n"
        string = string + "FFF                     AAA   AAA              III         LLL                 EEEEEEEEEEEEEEEEE   DDD           DDD\n"
        string = string + "FFF                    AAA     AAA             III         LLL                 EEE                 DDD           DDD\n"
        string = string + "FFF                    AAAAAAAAAAA             III         LLL                 EEE                 DDD           DDD\n"
        string = string + "FFF                   AAAAAAAAAAAAA            III         LLL                 EEE                 DDD           DDD\n"
        string = string + "FFF                  AAA         AAA           III         LLL                 EEE                 DDD          DDD\n"
        string = string + "FFF                  AAA         AAA           III         LLL                 EEE                 DDD        DDDD\n"
        string = string + "FFF                 AAA           AAA          III         LLLLLLLLLLLLLLLLL   EEEEEEEEEEEEEEEEE   DDDDDDDDDDDDDD\n"
        string = string + "FFF                 AAA           AAA        IIIIIII       LLLLLLLLLLLLLLLLL   EEEEEEEEEEEEEEEEE   DDDDDDDDDDDD\n"
    return string

def print_small_result(pass_flag):
    string = ""
    if pass_flag :
        string = string + "\n"
        string = string + "PPPPPPPPP      AA        SSSS       SSSS    EEEEEEEEEE DDDDDDDD\n"
        string = string + "PPPPPPPPPP    AAAA     SSSSSSSS   SSSSSSSS  EEEEEEEEEE DDDDDDDDD\n"
        string = string + "PP      PP    AAAA    SSS    SSS SSS    SSS EE         DD     DDD\n"
        string = string + "PP      PP   AAAAAA   SSS        SSS        EE         DD      DD\n"
        string = string + "PPPPPPPPPP   AA  AA    SSS        SSS       EEEEEEEEEE DD      DD\n"
        string = string + "PPPPPPPPP   AA    AA     SSSS       SSSS    EEEEEEEEEE DD      DD\n"
        string = string + "PP          AAAAAAAA        SSS        SSS  EE         DD      DD\n"
        string = string + "PP         AAAAAAAAAA SSS    SSS SSS    SSS EE         DD     DDD\n"
        string = string + "PP         AA      AA  SSSSSSSS   SSSSSSSS  EEEEEEEEEE DDDDDDDDD\n"
        string = string + "PP         AA      AA    SSSS       SSSS    EEEEEEEEEE DDDDDDDD\n"
    else :
        string = string + "\n"
        string = string + "FFFFFFFFFF     AA        IIII    LL         EEEEEEEEEE DDDDDDDD\n"
        string = string + "FFFFFFFFFF    AAAA        II     LL         EEEEEEEEEE DDDDDDDDD\n"
        string = string + "FF            AAAA        II     LL         EE         DD     DDD\n"
        string = string + "FF           AAAAAA       II     LL         EE         DD      DD\n"
        string = string + "FFFFFFF      AA  AA       II     LL         EEEEEEEEEE DD      DD\n"
        string = string + "FFFFFFF     AA    AA      II     LL         EEEEEEEEEE DD      DD\n"
        string = string + "FF          AAAAAAAA      II     LL         EE         DD      DD\n"
        string = string + "FF         AAAAAAAAAA     II     LL         EE         DD     DDD\n"
        string = string + "FF         AA      AA     II     LLLLLLLLLL EEEEEEEEEE DDDDDDDDD\n"
        string = string + "FF         AA      AA    IIII    LLLLLLLLLL EEEEEEEEEE DDDDDDDD\n"
    return string

def print_other_result(pass_flag):
    string = ""
    if pass_flag :
        string = string + "\033[32m\n"
        string = string + "+----------------------------------------------------------------------+\n"
        string = string + "|           .______      ___           _______.     _______.           |\n"
        string = string + "|           |   _  \\    /   \\         /       |    /       |           |\n"
        string = string + "|           |  |_)  |  /  ^  \\       |   (----`   |   (----`           |\n"
        string = string + "|           |   ___/  /  /_\\  \\       \\   \\        \\   \\               |\n"
        string = string + "|           |  |     /  _____  \\  .----)   |   .----)   |              |\n"
        string = string + "|           | _|    /__/     \\__\\ |_______/    |_______/               |\n"
        string = string + "|                                                                      |\n"
        string = string + "+----------------------------------------------------------------------+\n"
        string = string + "\033[m\n"

    else :
        string = string + "\033[31m\n"
        string = string + "+----------------------------------------------------------------------+\n"
        string = string + "|                    _______    ___       __   __                      |\n"
        string = string + "|                   |   ____|  /   \\     |  | |  |                     |\n"
        string = string + "|                   |  |__    /  ^  \\    |  | |  |                     |\n"
        string = string + "|                   |   __|  /  /_\\  \\   |  | |  |                     |\n"
        string = string + "|                   |  |    /  _____  \\  |  | |  `----.                |\n"
        string = string + "|                   |__|   /__/     \\__\\ |__| |_______|                |\n"
        string = string + "|                                                                      |\n"
        string = string + "+----------------------------------------------------------------------+\n"
        string = string + "\033[m\n"

    return string

def chk_log(args,log):
    # 1. check args
    if not args :
        sys.exit("[ERROR]: script fail, not args.")
    if (not os.path.exists(args.log)) :
        sys.exit("[ERROR]: this log( " + args.log + " )is not exists.")
    else :
        pass_key_c   = []
        pass_true    = []
        fail_key_c   = []
        ignore_key_c = []
        start_flag   = True
        start_key_c  = ""
        end_flag     = False
        end_key_c    = ""
        if args.start_key :
            start_key_c = re.compile(args.start_key);
            log.debug("start key re compile:{}".format(start_key_c))
            start_flag  = False
        if args.fail_key :
            for fail_key in args.fail_key :
                if fail_key :
                    fail_key_c.append(re.compile(fail_key))
            log.debug("fail_key re compile:{}".format(fail_key_c))
        else :
            sys.exit("[ERROR]: must give fail_key, but now fail_key is None.")
        if args.pass_key :
            for pass_key in args.pass_key :
                if pass_key :
                    pass_key_c.append(re.compile(pass_key))
                    pass_true.append(False)
            log.debug("pass_key re compile:{}".format(pass_key_c))
        if args.ignore_key :
            for ignore_key in args.ignore_key :
                if ignore_key :
                    ignore_key_c.append(re.compile(ignore_key))
            log.debug("ignore_key re compile:{}".format(ignore_key_c))
        if args.end_key :
            end_key_c = re.compile(args.end_key);
            log.debug("end key re compile:{}".format(end_key_c))
            end_flag  = False
        fail_flag    = False
        args.log = os.path.realpath(args.log)
        cnt = 1;
        with (open(args.log, "r", encoding='ISO-8859-1')) as f :
            for line in f:
                cur_chk = True
                if cnt > args.line :
                    if start_flag and (not end_flag):
                        for i,key_c in enumerate(pass_key_c):
                            if (not pass_true[i]) and key_c.search(line) :
                                pass_true[i] = True
                        for i,key_c in enumerate(ignore_key_c):
                            if key_c.search(line) :
                                cur_chk = False
                                break
                        if cur_chk :
                            for i,key_c in enumerate(fail_key_c):
                                if key_c.search(line) :
                                    fail_string       = "[chk fail]: this content is fail. key:{key} @ {line_num} line `{line}` in {log} . @ {date}\n".format(key=args.fail_key[i], line_num=cnt, line=line.strip(),log=args.log, date=datetime.now())
                                    fail_string_color = "[chk fail]: this content is \033[91mfail\033[0m. key:\033[1m\033[91m{key}\033[0m @ \033[1m\033[91m{line_num}\033[0m line `{line}` in \033[1m\033[91m{log}\033[0m . @ {date}\n".format(key=args.fail_key[i], line_num=cnt, line=line.strip(), log=args.log, date=datetime.now())
                                    fail_flag = True
                                    break
                    elif (not start_flag) and (not end_flag) and start_key_c.search(line) :
                        start_flag = True
                    if start_flag and (not end_flag) and end_key_c.search(line) :
                        end_flag = True
                        break
                if fail_flag :
                    break
                cnt = cnt + 1;
            if not start_flag :
                fail_string       = "[chk fail]: not find ignore_before_key({key}) from {s} to {e} line all content of log: {log} @ {date}\n".format(s=args.line + 1,e=cnt,key=args.start_key, log=args.log, date=datetime.now())
                fail_string_color = "[chk fail]: \033[91mnot find\033[0m ignore_before_key(\033[91m{key}\033[0m) from {s} to {e} line all content of log: \033[91m{log}\033[0m @ {date}\n".format(s=args.line + 1,e=cnt,key=args.start_key, log=args.log, date=datetime.now())
                fail_flag = True
        if not fail_flag and pass_true :
            for key,v in enumerate(pass_true) :
                if not v :
                    fail_string       = "[chk fail]: not find pass_key({key}) from {s} to {e} line all content of log: {log} @ {date}\n".format(s=args.line + 1,e=cnt,key=args.pass_key[key], log=args.log, date=datetime.now())
                    fail_string_color = "[chk fail]: \033[91mnot find\033[0m pass_key(\033[91m{key}\033[0m) from {s} to {e} line all content of log: \033[91m{log}\033[m @ {date}\n".format(s=args.line + 1,e=cnt,key=args.pass_key[key], log=args.log, date=datetime.now())
                    fail_flag = True
                    break

        if args.other :
            string = print_other_result((fail_flag == False));
        elif args.big :
            string = print_result((fail_flag == False));
        else :
            string = print_small_result((fail_flag == False));

        if fail_flag :
            print ('\033[91m\n' + fail_string + string + '\033[m')
        else :
            fail_string  = "[chk pass] happy!!!! from {s} to {e} line in {log} @ {date}\n".format(s=args.line,e=cnt,log=args.log,date=datetime.now());
            print ('\033[92m\n' + fail_string + string + '\033[m')
        with (open(args.log, "a")) as f :
            f.write(fail_string)
            f.write(string)
        if args.eman :
            if "EMAN_TOP_RUN_DIR" in os.environ and os.environ["EMAN_TOP_RUN_DIR"] :
                if fail_flag :
                    status = "fail"
                else :
                    status = "pass"
                if "EMAN_RANDOM" in os.environ and os.environ["EMAN_RANDOM"] :
                    seed = os.environ["EMAN_RANDOM"]
                else :
                    seed = ""
                if "EMAN_TEST_NAME" in os.environ and os.environ["EMAN_TEST_NAME"] :
                    tc   = os.environ["EMAN_TEST_NAME"]
                else :
                    tc   = ""
                if "EMAN_TEST_FLAGS" in os.environ and os.environ["EMAN_TEST_FLAGS"] :
                    cfg   = os.environ["EMAN_TEST_FLAGS"]
                else :
                    cfg   = ""
                str_content = "{status:^"+str(args.eman_width[0])+"}|{seed:^"+str(args.eman_width[1])+"}|{tc:^"+str(args.eman_width[2])+"}|{cfg:^"+str(args.eman_width[3])+"}|{cont}"
                str_content = str_content.format(status=status,seed=seed,tc=tc,cfg=cfg,cont=fail_string)
                with(open(os.path.join(os.environ["EMAN_TOP_RUN_DIR"],'eman_status.txt'),"a")) as f :
                    f.write(str_content)
                if fail_flag :
                    with(open(os.path.join(os.environ["EMAN_TOP_RUN_DIR"],'eman_status_fail.txt'),"a")) as f :
                        f.write(str_content)
                else :
                    with(open(os.path.join(os.environ["EMAN_TOP_RUN_DIR"],'eman_status_pass.txt'),"a")) as f :
                        f.write(str_content)
    return fail_flag

if __name__ == '__main__':
    #parsing arguments
    parser = argparse.ArgumentParser(
             description="when you get the log file and fail_key, will check this log fail or pass."
            ,formatter_class=argparse.ArgumentDefaultsHelpFormatter
            )
    parser.add_argument('-i' ,'--ignore_before_key'   ,dest="start_key",type=str,                                      help= 'check log after this key.'                           )
    parser.add_argument('-e' ,'--end_chk_after_key'   ,dest="end_key"  ,type=str,default="^MVP TEST (FAILED|PASSED)\\b",help= 'check log before this key.'                         )
    parser.add_argument('log',                                          type=str,                                      help= 'compile log or simulation log, which will be checked')
    parser.add_argument('-pk','--pass_key'            ,nargs='+'       ,type=str,                                      help= 'PASS Key list.positional arguments'                  )
    parser.add_argument('-fk','--fail_key'            ,nargs='+'       ,type=str,required=True,                        help= 'Fail Key list.positional arguments'                  )
    parser.add_argument('-ik','--ignore_key'          ,nargs='+'       ,type=str,                                      help= 'ignore Key list.'                                    )
    parser.add_argument('-s' ,'--start_after_line_num',dest="line"     ,type=int,default=1                           , help= 'the first line number of log will not be checked.'   )
    parser.add_argument('-b' ,'--big'                 ,dest="big"      ,action="store_true"                          , help= 'big passed and failed in full terminal.'             )
    parser.add_argument('-o' ,'--other'               ,dest="other"    ,action="store_true"                          , help= 'other passed and failed.'                            )
    parser.add_argument('-d' ,'--debug'               ,dest="debug"    ,type=str,choices=["d","i","w","e","c"], default="w", help= 'debug information.d:DEBUG,i:INFO,W:WARNING,e:ERROR,c:CRITICAL')
    parser.add_argument('-em','--eman_status'         ,dest="eman"     ,action="store_true"                          , help= 'print eman fail and pass status.'                    )
    parser.add_argument('-ew','--eman_width'          ,nargs=4         ,type=int,default=[6,12,40,0]                   , help= 'print eman status field{status,seed,tc} width.'      )
    args = parser.parse_args()
    if args.debug == "d" :
        logging.basicConfig(level=logging.DEBUG)
    elif args.debug == "i" :
        logging.basicConfig(level=logging.INFO)
    elif args.debug == "w" :
        logging.basicConfig(level=logging.WARNING)
    elif args.debug == "e" :
        logging.basicConfig(level=logging.ERROR)
    elif args.debug == "c" :
        logging.basicConfig(level=logging.CRITICAL)
    logging.info(args)
    fail = chk_log(args,logging)		
