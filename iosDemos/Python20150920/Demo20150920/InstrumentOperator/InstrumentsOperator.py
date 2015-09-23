#!/usr/bin/python
# -*- coding: utf-8 -*-
'''
Created on 2013-11-26

@author: lixm@ucweb.com
@modifer: yanglong@ucweb.com

'''
import os
import time
import subprocess
import re

# from common import Common


#from dbgp.client import brk

class Instruments(object):
    '''
     the Instruments Operator
    
    '''
    def __init__(self, devid, appname, jspath, out_path):
        
        self.uuid = devid
        self.target_app = appname
        self.js_path = jspath
        self.output_path = out_path
#        self.comm  =Common()
        self.clearTraceFile()
        
    def startInstruments(self,jsfile):
        print 'start Instruments'
        tracetemplate =self.getXcodePath()
        jsfile = self.js_path+"/"+jsfile
        #for subprocess use
        cmd_test = ['/usr/bin/instruments','-w',self.uuid,'-t',tracetemplate,self.target_app,'-e','UIASCRIPT',jsfile,'-e','UIARESULTSPATH',self.output_path]
        print "instruments command:   " + " ".join(cmd_test)
        try:
            sub_process = subprocess.Popen(cmd_test,stdout=subprocess.PIPE,stderr=subprocess.PIPE,stdin=subprocess.PIPE,env=os.environ)
        except Exception,e:
            print str(e)
            print("Instruments subprocess open exception: "+str(e))
            raise e
        time.sleep(6)
        return sub_process

    def localExcCMD(self,cmd):
        '''
        执行本地命令.
        Args:
        cmd：命令行
        Returns:
        handle：执行结果
        '''
        handle = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)
        return handle
    
    def stopInstruments(self):
        
        print("stop Instruments: ")
        os.system("kill -9 $(ps ux | grep instruments | grep -v grep | awk {'print $2'})")
        os.system("kill -9 $(ps ux | grep Instruments | grep -v grep | awk {'print $2'})")

    def restartInstruments(self,jsfile):
        
        print("restart Instruments!")
        self.stopInstruments()
        time.sleep(5)
        self.startInstruments(jsfile)
        
    def isInstrumentsRunning(self):
        
        instrumentsCount = os.popen('ps -ef | grep "/Instrument" | grep -v grep | wc -l').readlines()[0].replace("\n","")
        time.sleep(5)
        if int(instrumentsCount) :
            return 1
        else:
            return 0

        
    def getXcodePath(self):
        xode_path = self.localExcCMD("xcode-select -print-path")
        xode_path = xode_path.stdout.read().replace('\n','')
        xode_path = xode_path.replace(' ','\ ')
        xcode_version = self.localExcCMD("xcodebuild -version")
        xcode_version = int("".join(re.findall("Xcode\s+(\d)",xcode_version.stdout.read(),re.M)))
        if xcode_version==5:
            tracetemplate = xode_path + "/../Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate"
        elif xcode_version==4:
            tracetemplate = xode_path + "/Platforms/iPhoneOS.platform/Developer/Library/Instruments/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate"
        elif xcode_version==6:
            tracetemplate = xode_path + "/../Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.xrplugin/Contents/Resources/Automation.tracetemplate"
        else:
            tracetemplate = xode_path + "/../Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.xrplugin/Contents/Resources/Automation.tracetemplate"
        return os.path.abspath(tracetemplate)

    def clearTraceFile(self):
        os.system("rm -rf instrumentscli*.trace")
         

def test2():
    def getUUID():
        udid = os.popen('''system_profiler SPUSBDataType | grep "Serial Number:.*" | sed s#".*Serial Number: "## ''').readlines()
        if udid:
            udid = udid[0].replace('\n','')
        return udid
        
    #devid = getUUID()
    #appname = "com.ucweb.iphone"
    #jsfile_dir = '/Users/yanglong/buildbot/scripts/qmsinterceptor/resource/ios/monkey/uimonkey'

    # 设备UUID
    devid = getUUID()
    print devid
    print "\n"
    # appname = "com.ucweb.iphone"
    appname = "com.ucweb.iphone"
    # appname = "Sooyo.UCWebViewTest"
    #jsfile_dir = '/Users/yanglong/buildbot/scripts/qmsinterceptor/resource/ios/monkey/uimonkey'
    jsfile_dir = '/Users/yangfs/Desktop/E/20150920Python/InstrumentOperator'
    
    ins = Instruments(devid,appname,jsfile_dir,jsfile_dir)
    ins.startInstruments("stressTest.js")
    ins.clearTraceFile()
    time.sleep(20)
       
if  __name__ == '__main__':
    
    test2()