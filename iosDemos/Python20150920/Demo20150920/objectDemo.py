# -*- coding:utf-8 -*-

'''
yangfs
2015-09-22

【04 类和对象】
'''

from DemoFont import *

fontDefault = DemoFont();

print "fontsize = ", fontDefault.getFontSize();
print "fontname = ", fontDefault.getFontName();
print "私有变量：__secretCount = ", fontDefault._DemoFont__secretCount;

del fontDefault;

pt1 = CPoint(1, 2);
pt2 = pt1
pt3 = CPoint(3, 5);

print "pt1=", id(pt1), "pt2 = ", id(pt2), "pt3 = ", pt3;

del pt1;
del pt2;
del pt3;

v1 = CVector();
v1.setZ(5);
del v1;


