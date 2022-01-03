import configparser


class Conf:
    def __init__(self, path):
        self.config = configparser.ConfigParser()
        self.config.read(path, encoding="utf-8")

    def check(self):
        if self.config:
            try:
                return self.config.get("common", "dst_server_path")
            except configparser.Error:
                return "配置文件中未找到饥荒服务器执行程序路径，请点击按钮选择路径"

