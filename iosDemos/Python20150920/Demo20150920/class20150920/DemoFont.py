# -*- coding:utf-8 -*-

'''
DemoFont.py
yangfs
2015-09-22

【05 文字类】
'''

class DemoFont:
    "文字类"
    __secretCount = 0  # 私有变量

# 构造函数
    def __init__(self, fontsize = 10, fontaligment = 0, fontname = "aria"):
        self.fontsize = 10;
        self.fontname = "aria";
        self.fontaligment = 0;

    def getFontSize(self):
        return self.fontsize;

    def getFontName(self):
        return self.fontname;

# 析构方法, 删除一个对象
    def __del__(self):
        clasename = self.__class__.__name__
        print " destroyed:", clasename

# point类
class CPoint:
    def __init__(self, x=0, y=0):
        self.x = x;
        self.y = y;

    def __del__(self):
        name = self.__class__.__name__
        print "【类名】 ", name

# 子类
class CVector(CPoint):
    def __init__(self):
        self.z = 0;
        print "调用子类构造函数"
    def setZ(self, z = 0):
        self.z = z;
        print "调用子类方法，z = ", z;

