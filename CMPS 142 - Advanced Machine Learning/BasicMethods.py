# -*- coding: UTF-8 -*-
import os


# 方法获取一个文件夹里面最新的file_num个文件
def get_latest_files(folder, file_num):
    try:
        file_num = int(file_num)
        path_ls = []
        for path, subdirs, filenames in os.walk(folder):
            filenames_completed = []
            for filename in filenames:
                if filename.endswith(".COMPLETED"):
                    filenames_completed.append(filename)
            filenames_sorted = sorted(filenames_completed, reverse=True)
            if len(filenames_sorted) >= file_num:
                filenames_top = filenames_sorted[:file_num]
            else:
                filenames_top = filenames_sorted
            for filename in filenames_top:
                path_ls.append(os.path.join(path, filename))
        return path_ls
    except Exception, e:
        print Exception, "get_latest_files:", e
        return []


