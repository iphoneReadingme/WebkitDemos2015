__author__ = 'yangfs'
# -*- coding:utf-8 -*-

# import demo02_fun.py
from demo02_fun import *
from function import *
# from function import *
import time; # 导入时间模块

# 【2015-09-22 模块间函数调用】函数
# print sys.path
v = 0;
v = addFun(1, 2);
print "a + b = ", v;

v = addFun2(1, 4);
print "a + b = ", v;

v = addFun3(1, 4);
print "a + b = ", v;
