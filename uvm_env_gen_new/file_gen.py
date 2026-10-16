#!/usr/bin/env python3

import os
import datetime

_cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(_cur_scr_dir + "/../../public")
import sys
sys.path.append(pubfunc_dir)
from pubfunc import PubFunc


def get_file_header(comment_style, file_name):
    return PubFunc.get_file_header(comment_style, file_name)


def write_file(file_path, content):
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, 'w') as f:
        f.write(content)


def write_template(tpl_engine, template_path, output_path, **context):
    if 'file_header' not in context:
        file_name = os.path.basename(output_path)
        context['file_header'] = get_file_header('//', file_name)
    tpl_engine.render_to_file(template_path, output_path, **context)
