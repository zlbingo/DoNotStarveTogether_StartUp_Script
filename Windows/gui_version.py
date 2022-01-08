from functools import partial
from tkinter import *
from tkinter import filedialog

from conf_set import Conf

CONF_FILE = "conf.ini"
CONF_OBJ = Conf(CONF_FILE)
EXE_SET = {"dontstarve_dedicated_server_nullrenderer_x64.exe", "dontstarve_dedicated_server_nullrenderer.exe"}


def format_slash(path_str):
    return path_str.replace("/", "\\")


def set_dst_path(display_name, conf, sections, options):
    """
    打开对话框查找路径
    将路径保持到配置文件中
    :return:
    """
    dst_run_path = format_slash(filedialog.askopenfilename(title=display_name))

    # 解析路径获取执行程序路径和mod路径
    path_split = dst_run_path.split("\\")
    if path_split[-1] in EXE_SET:
        mod_path  = "\\".join(path_split[:-1]) + "\\mods"

        if not conf.has_section(sections):
            conf.add_section(sections)
        conf.set(sections, options, dst_run_path)
        conf.set(sections, "mod_path", mod_path)

        dts_server_content.configure(text=dst_run_path+ "\n" + mod_path)
        conf.write(open(CONF_FILE, "w"))

    else:
        dts_server_content.configure(text="路径选择错误")
    





window = Tk()
# 设置窗口大小
window.geometry("600x400")
# 设置标题
window.title("一键式启动饥荒服务器程序")

# 饥荒服务器执行程序路径
dts_server_title = Label(window, text="饥荒服务器执行程序路径")
dts_server_title.grid(row=0, column=0)


dts_server_content = Label(window, text=CONF_OBJ.check())
dts_server_content.grid(row=1, column=0)

set_path_partical = partial(set_dst_path, '1', CONF_OBJ.config, "common", "dst_server_path")
dts_server_btn = Button(window, text="选择路径", command=set_path_partical)
dts_server_btn.grid(row=1, column=1)

window.mainloop()
