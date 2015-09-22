# -*- coding:utf-8 -*-

# 【02 Python 函数模块调用】
#import time; # 导入时间模块

'''
unindent does not match any outer indentation level
取消缩排不匹配 外部缩进级别
调试时出现以上错误，是因为，下面的代码是在Xcode编辑器中编写，而Xcode的行首缩进是table,不是空格
导致函数定义出现异常
'''
# 加法函数
def addFun(a, b):
    "【加法】两数相加"
    return (a+b);

def addFun2(a, b):
    "【加法】两数相加"
    sumExt = a + b
    return sumExt;

def addFun3(a, b):
    "【乘法】两数相加"
    sumExt = a * b
    return sumExt;