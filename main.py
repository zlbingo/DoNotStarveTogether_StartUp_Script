import os.path
import platform
import re
import tkinter as tk
from tkinter import filedialog


# 常量类
TAKEN_FILE = "cluster_token.txt"
MOD_SET_FILE = r"Master\modoverrides.lua"
SERVER_MOD_FILE = "dedicated_server_mods_setup.lua"
CLUSTER_NAME = "Cluster_13"
WORKSHOP_PATTERN = re.compile("workshop-\d+")
SERVER_MOD_PATTERN = re.compile("ServerModSetup\(\"\d+\"\)")


def judge_platform():
    """
    判断当前平台
    :return:
    """
    sys = platform.system()
    if sys == "Windows":
        print("OS is Windows!!!")
    else:
        print("[warning]: This platform is not yet adapted")
        exit(0)


def format_slash(path_str):
    return path_str.replace("/", "\\")


def set_dst_path():
    # 打开选择文件夹对话框
    windows = tk.Tk()
    windows.withdraw()

    dst_run_path = format_slash(filedialog.askdirectory(title=r"[choose dst folder] e.g. D:\Steam\steamapps\common\Don't Starve Together\bin64"))
    dst_sever_mod_path = format_slash(filedialog.askdirectory(title=r"[chose dst server mod folder] e.g. D:\Steam\steamapps\common\Don't Starve Together Dedicated Server\mods"))
    cluster_save_path = format_slash(filedialog.askdirectory(title=r"[chose cluster save path] e.g. C:\Users\xxx\Documents\Klei\DoNotStarveTogether\Cluster_shenhuan"))

    print('[info] dst folder is :                ', dst_run_path)
    print('[info] dst server mod folder is :     ', dst_sever_mod_path)
    print('[info] cluster save folder is :       ', cluster_save_path)

    return dst_run_path, dst_sever_mod_path, cluster_save_path


def make_token_file(path, key):
    full_path = os.path.join(path, TAKEN_FILE)
    print(full_path)
    with open(full_path, "w") as f:
        f.write(key)


def add_mod_id_2_setup_lua(save_path, server_path):
    # 获取mod配置文件的路径
    mod_set_file = os.path.join(save_path, MOD_SET_FILE)
    # 获取dst server 下载mod的文件
    server_mod_file = os.path.join(server_path, SERVER_MOD_FILE)
    # 找到所有mod的名字
    # todo 增加判断文件存在性
    with open(mod_set_file, "r", encoding="utf-8") as f:
        mod_set_result = set(map(lambda x: x[9:],
                                 re.findall(WORKSHOP_PATTERN, f.read())))

    with open(server_mod_file, "r") as f:
        server_mod_result = set(map(lambda x: x[16:-2],
                                    re.findall(SERVER_MOD_PATTERN, f.read())))

    # 找出未放在更新列表里面的mod ID
    add_set = mod_set_result - server_mod_result
    # 将ID进行拼接成ServerModSetup(123)的形式
    add_str = "\n".join([f"ServerModSetup(\"{i}\")" for i in add_set])
    print(f"add mod: {add_str}")
    with open(server_mod_file, "a") as add_content:
        add_content.write("\n" + add_str)


def run_game(game_path):
    # todo 加判断是否是64位
    os.chdir(game_path)
    os.system(f"start cmd.exe @cmd /k dontstarve_dedicated_server_nullrenderer_x64.exe -console -cluster {CLUSTER_NAME} -shard Master")
    os.system(f"start cmd.exe @cmd /k dontstarve_dedicated_server_nullrenderer_x64.exe -console -cluster {CLUSTER_NAME} -shard Caves")


if __name__ == "__main__":
    # 判断平台
    judge_platform()

    # 选择相应的文件夹

    # exe_path, sever_mod_path, cluster_path = set_dst_path()
    exe_path = r"D:\Program\Steam\steamapps\common\Don't Starve Together Dedicated Server\bin64"
    sever_mod_path = r"D:\Program\Steam\steamapps\common\Don't Starve Together Dedicated Server\mods"
    cluster_path = f"C:\\Users\\zongl\\Documents\\Klei\\DoNotStarveTogether\\{CLUSTER_NAME}"


    # 输入饥荒服务器的key
    # input_key = input("please input dst server key: ")
    # print(f"the dst server key is :{input_key}")
    input_key = "pds-g^KU_f7yzsmr4^rZTvqQbtYexIGALvqx746ywNaxVA42q/lG9psKmnsmc="
    # 制作key文件
    make_token_file(cluster_path, input_key)

    # 将需要的mod放到server启动时的下载目录里面
    add_mod_id_2_setup_lua(cluster_path, sever_mod_path)

    # 运行代码
    run_game(exe_path)
