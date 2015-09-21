# -*- coding:utf-8 -*-
#__author__ = 'yangfs'

# /Users/yangfs/Desktop/B/Backup20150529/20150810_ios/trunk_Src20150920/Script20150920/Python20150920/Python20150920/Demo20150920
# /Users/yangfs/Desktop/E/Instrument_20150915/环境配置

'''
# /*
# 【PyCharm】好用的MAC平台上的Python IDE
# https://www.jetbrains.com/pycharm/download/
# PyCharm 是 JetBrains 开发的 Python IDE。PyCharm用于一般IDE具备的功能，比如， 调试、语法高亮、Project管理、代码跳转、智能提示、自动完成、单元测试、版本控制……另外，PyCharm还提供了一些很好的功能用于[Django]开发，同时支持Google App Engine，更酷的是，PyCharm支持[IronPython]！
#
# PyCharm,我用的就是这个，很实用，有很好的界面，社区版足够用了，免费的，支持GIT，如果你喜欢vim的话，还支持vim的插件。反正我用起来非常顺手（只要支持VIM，就足够我开心的了，而且也支持GIT，更是方便）
# PyCharm 当前版本 PyCharm4.5
# */
python 中多行注释使用三个单引号(' _' ')或三个单引号(" _" ")。
'''

#
# http://www.runoob.com/python/python-chinese-encoding.html
# Python 中文编码问题
# 让脚本支持中文输出
# -*- coding:utf-8 -*-

import time; # 导入时间模块
print("hello, python!")

print("hello, python 【test.py】 测试！")

ticks = time.time();
print("time:", ticks);

'''
获取当前时间
'''
localtime = time.localtime(time.time());

print "\n当前时间 time:", localtime;

localtime = time.asctime( time.localtime(time.time()) )
print "\n时间 Local current time :", localtime

#raw_input("\n\n回车，退出！");