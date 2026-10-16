import sys
from datetime import datetime

class PubFunc:
    @staticmethod
    def exit_err(msg):
        print(f"\033[1;31m{msg}\033[0m")
        sys.exit(1)

    @staticmethod
    def get_file_header(comment_style='//', file_name=''):
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        user = "unknown"
        try:
            import getpass
            user = getpass.getuser()
        except Exception:
            pass
        lines = []
        lines.append(f"{comment_style} FILE NAME    : {file_name}")
        lines.append(f"{comment_style} AUTHOR       : {user}")
        lines.append(f"{comment_style} DATE         : {now}")
        lines.append(f"{comment_style} DESCRIPTION  : Auto-generated file")
        lines.append(f"{comment_style} " + "-" * 70)
        lines.append("")
        return "\n".join(lines)
