#!/usr/bin/env python3

import os
import jinja2

_cur_dir = os.path.dirname(os.path.abspath(__file__))
_template_dir = os.path.join(_cur_dir, 'templates')

_jinja_env = jinja2.Environment(
    loader=jinja2.FileSystemLoader(_template_dir),
    keep_trailing_newline=True,
    trim_blocks=False,
    lstrip_blocks=False,
    undefined=jinja2.StrictUndefined,
)

_jinja_env.globals['upper'] = str.upper


def render_template(template_path, **context):
    tpl = _jinja_env.get_template(template_path)
    return tpl.render(**context)


def render_to_file(template_path, output_path, **context):
    content = render_template(template_path, **context)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w') as f:
        f.write(content)
