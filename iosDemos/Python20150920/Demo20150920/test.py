# -*- coding:utf-8 -*-

'''
yangfs
2015-09-22
'''
#!/usr/bin/python
# from demo02_fun import *
# from function import *
from class20150920.demo02_fun import *
from class20150920.function import *
# import sys

# from function import *
import time; # 导入时间模块
# sys.path.insert(0, "/Library/Python/2.7/site-packages");

# 【2015-09-22 模块间函数调用】函数
# print sys.path
v = 0;
v = addFun(1, 2);
print "a + b = ", v;

v = addFun2(1, 4);
print "a + b = ", v;

v = addFun3(1, 4);
print "a + b = ", v;

v = sumFun(1, 2, 3)
print "a + b + c = ", v;


# print sys.path


print dir()