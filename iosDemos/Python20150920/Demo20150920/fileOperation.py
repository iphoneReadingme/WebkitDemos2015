# -*- coding:utf-8 -*-

'''
yangfs
2015-09-22

【03 文件读写操作】
'''


# 打开一个文件
fo = open("Cache/Data/foo.txt", "w+")
print "Name of the file: ", fo.name
print "Closed or not : ", fo.closed
print "Opening mode : ", fo.mode
print "Softspace flag : ", fo.softspace

#fo.write( "Python is a great language.\nYeah its great!!\n");
# str = input("输入：")
text = "文件读写操作测试。"
fo.write(text)

str = fo.read(100)
print "【文件内容：】", str

# 关闭打开的文件
fo.close()

fread = open("Cache/Data/foo.txt", "r+")
str = fread.read()
print "【读取文件内容：】\n", str

fread.close()
