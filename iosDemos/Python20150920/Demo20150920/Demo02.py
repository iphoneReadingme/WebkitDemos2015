#!/usr/bin/python
#  -*- coding:utf-8 -*-

# 【02 Python 变量类型】
import time; # 导入时间模块
# import Demo02_fun01.py
#import class20150922/fun01.py
#from class20150922/Demo02_fun01 import *


print("hello, python!")

print("hello, python 【Demo01.py】 测试！")

counter = 100
miles = 1000.0
name = "John"

print "\n【01】变量赋值"
print "counter = ", counter
print "miles = ", miles
print "name = ", name

print "\n【02】Python有五个标准的数据类型："
print "Numbers（数字）"
print "String（字符串）"
print "List（列表）"
print "Tuple（元组）"
print "Dictionary（字典）"

#z = a + bi
#z = complex(a, b)
#print "复数：z = ", z

s = "ilovepython"
print "\n字符串操作：上下界取子串，s[1:5]", s[1:5]


def printTest(str):
    "函数说明：打印任何传入的字符串"
    print str;
    return;

# 函数调用
printTest("test")

#可写函数说明
def printinfo( name, age ):
   "打印任何传入的字符串"
   print "Name: ", name;
   print "Age ", age;
   return;

#调用printinfo函数
printinfo( age=50, name="miki" );

# 可写函数说明
def printinfo( arg1, *vartuple ):
   "打印任何传入的参数"
   print "\n函数开始\n输出: "
   print "arg1:", arg1
   print "\nvartupe:"
   for var in vartuple:
      print var

   print "【结束】\n"
   return;

# 调用printinfo 函数
printinfo( 10 );
printinfo( 70, 60, 50 );


# 【2015-09-22 模块间函数调用】函数
v = 0;
v = addFun(1, 2);
print "a + b = ", v;

v = addFun2(1, 4);
print "a + b = ", v;
