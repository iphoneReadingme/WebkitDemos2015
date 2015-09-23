var target = UIATarget.localTarget();
var flag = false;


UIATarget.onAlert = function onAlert(alert) {
    return false;
}

function stress_main() {
    UIALogger.logStart("begin to start borwser");
    UIALogger.logMessage("current app name:"+UIATarget.localTarget().frontMostApp().name());
    target.delay(20);
    try {
        target.frontMostApp().windows()[0].buttons()["PerformanceTest"].tap();
	target.frontMostApp().actionSheet().buttons()["小说定向测试"].tap();
        flag = true;
        while (flag) {
            UIALogger.logMessage("current app name:"+UIATarget.localTarget().frontMostApp().name());
            target.delay(20);
        }
    }catch(e) {
	try {
	    target.frontMostApp().actionSheet().collectionViews()[0].cells()["压力测试（多窗口、联网）"].buttons()["压力测试（多窗口、联网）"].tap();
            flag = true;
            while (flag) {
                UIALogger.logMessage("current app name:"+UIATarget.localTarget().frontMostApp().name());
                target.delay(20);
	    }
	}catch(e) {
	    target.frontMostApp().actionSheet().tableViews()[0].cells()["压力测试（多窗口、联网）"].tap();
            flag = true;
            while (flag) {
                UIALogger.logMessage("current app name:"+UIATarget.localTarget().frontMostApp().name());
                target.delay(20);
        }
	}

    }
}

stress_main();
