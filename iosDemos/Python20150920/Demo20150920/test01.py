# -*- coding:utf-8 -*-
#__author__ = 'yangfs'

import sys
# sys.path.pop(0)
# sys.path.pop(0)
#sys.path.remove("/Volumes/d2/Backup20150529/20150810_ios/trunk_src20150920/Script20150920.git/Python20150920/Python20150920/Python20150920/Demo20150920/")
# sys.path.insert(0, "./class20150922")
# sys.path.insert(0, "/Volumes/d2/Backup20150529/20150810_ios/trunk_src20150920/Script20150920.git/Python20150920/Python20150920/Python20150920/Demo20150920/")
# sys.path.insert(0, "/Volumes/d2/Backup20150529/20150810_ios/trunk_src20150920/Script20150920.git/Python20150920/Python20150920/Python20150920/Demo20150920/class20150922/")
sys.path.insert(0, "/Volumes/d2/Backup20150529/20150810_ios/trunk_src20150920/Script20150920.git/Python20150920/Python20150920/Python20150920/Demo20150920/class20150922/")

#/Volumes/d2/Backup20150529/20150810_ios/trunk_src20150920/Script20150920.git/Python20150920/Python20150920/Python20150920/Demo20150920/
# import fun01.py

from demo02_fun import *
# from class20150922/function.py import *
# import demo02_fun
#import Demo02_fun01.py
# import function.py
#from class20150922/Demo02_fun01 import *
import time; # 导入时间模块

# 【2015-09-22 模块间函数调用】函数
print sys.path
v = 0;
v = addFun(1, 2);
print "a + b = ", v;

v = addFun2(1, 4);
print "a + b = ", v;
