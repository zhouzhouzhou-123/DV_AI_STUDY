#!/usr/bin/python

import os
import sys
import re
import linecache
import random

if __name__ == '__main__':
    help_info = '''\
------------------------------------------------------------------
You can use this script like this:
    tarmac.py ../ccode/elf/XX.elf ./tarmac.log ./XX.fsdb'''

    if len(sys.argv) > 1 and (sys.argv[1] in ['-h', '--h', '-H', '--H', '-help', '--help']):
        print(help_info)
        exit()
    if len(sys.argv) < 3:
        print(help_info)
        exit()

    if len(sys.argv) >= 2:
        elf_file = sys.argv[1]
    if len(sys.argv) >= 3:
        input_file = sys.argv[2]
    if len(sys.argv) >= 4:
        output_file = sys.argv[3]
    else:
        output_file = sys.argv[2]

    command = "hwsw_debug_convert cpuType=Cortex-M0 exeFile=%s -i %s -o %s" % \
                (elf_file, input_file, output_file)

    print(command)
    os.system(command)

