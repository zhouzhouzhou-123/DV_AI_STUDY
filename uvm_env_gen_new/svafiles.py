#!/usr/bin/env python3

import sys
import os
import re

from operator import attrgetter

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

class SvaFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path
        self.sva_list = env_gen.sva_list

    def __str__(self):
        str_info = ""
        str_info += "------ SvaFiles Start ------\n"
        str_info += "project_path(%s)\n" % self.project_path
        str_info += "------ SvaFiles End ------\n"
        return str_info

    def gen_files(self):
        sva_filelist_name = "sva_top.svh"
        sva_filelist_path = "%s/sva/%s" % (self.project_path, sva_filelist_name)
        sva_filelist = open(sva_filelist_path, 'w')
        sva_filelist.write(PubFunc.get_file_header('//', sva_filelist_name))
        for cur_sva_item in self.sva_list:
            if cur_sva_item.count == 0:
                self.sva_list.remove(cur_sva_item)
            if cur_sva_item.count == 1:
                sva_filelist.write("`include \"../sva/%s_sva.sv\"" % cur_sva_item.name)
                continue
            if cur_sva_item.count > 1:
                PubFunc.exit_err("Not support svaer count(%d) > 1!\n%s" % cur_sva_item.count)
        sva_filelist.close()

        for cur_sva_item in self.sva_list:
            cur_sva_file_name = "%s_sva.sv" % cur_sva_item.name
            cur_sva_file_path = "%s/sva/%s" % (self.project_path, cur_sva_file_name)
            cur_sva_file = open(cur_sva_file_path, 'w')
            cur_sva_file.write(PubFunc.get_file_header('//', cur_sva_file_name))

            cur_sva_file_str = ""
            cur_sva_file_str += "\n"
            cur_sva_file_str += "`ifndef %s_SVA__SV\n" % cur_sva_item.name.upper()
            cur_sva_file_str += "`define %s_SVA__SV\n" % cur_sva_item.name.upper()
            cur_sva_file_str += "\n"
            cur_sva_file_str += "module %s_sva();\n" % cur_sva_item.name
            cur_sva_file_str += "\n"
            cur_sva_file_str += "endmodule : %s_sva\n" % cur_sva_item.name
            cur_sva_file_str += "\n"
            cur_sva_file_str += "`endif // %s_SVA__SV\n" % cur_sva_item.name.upper()

            cur_sva_file.write(cur_sva_file_str)
            cur_sva_file.close()
