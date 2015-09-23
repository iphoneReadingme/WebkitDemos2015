# -*- coding:utf-8 -*-

'''
yangfs
2015-09-22
'''
#!/usr/bin/python

import demjson

# from function import *
import time; # 导入时间模块
# sys.path.insert(0, "/Library/Python/2.7/site-packages");

# 【2015-09-22 模块间函数调用】函数
# print sys.path


json = '{"a":1,"b":2,"c":3,"d":4,"e":5}';
text = demjson.decode(json)
print  text


print dir()