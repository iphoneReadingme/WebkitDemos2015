// add 2012-01-12
;(function() {
  
  var LPResult =
  {
    createNew: function(href,src,tagName,text, width, height)
    {
        var result = {};
        result.href = href;
        result.src = src;
        result.tagName = tagName;
        result.text = text;
        result.width = width;
        result.height = height;
        return result;
    }
  
  };
  
function UCWEBAppHandleIFrameElement(x, y, e)
{
	if (e.tagName == 'IFRAME' && e.contentDocument)
	{
		var left = e.getBoundingClientRect().left;
		var top = e.getBoundingClientRect().top;
		
		e = e.contentDocument.elementFromPoint(x-left,y-top);
	}
	
	return e;
}

// 往上递归N层，检查是否带嵌套在A标签内，并返回A标签
function findParentATag(e)
{
	var parent = e;
	while (parent && parent.tagName !== 'BODY')
	{
		if (parent.tagName == 'A' && typeof(parent.href) != "undefined")
		{
			return parent;
		}
		
		parent = parent.parentNode;
	}

	return e;
}


function GetHTMLElementsAtPoint(x,y)
{
	var testFlag = false;
	var offset = [[0, 0], [-15, 0], [0, -15], [15, 0], [0, 15], [15, 15], [-15, -15], [15, -15], [-15, 15]];
    // 根据产品的意见, 不对嵌套的元素进行递归查找<a>, <img>元素
	for (var i=0;i<offset.length;i++)
	{
		var x1 = x + offset[i][0];
		var y1 = y + offset[i][1];
		var e = document.elementFromPoint(x1,y1);
		
		if (e)
		{
			e = UCWEBAppHandleIFrameElement(x1, y1, e);
			if (!e){
				continue;
			}
			// 只对第一次，即正中的点击坐标所取的元素才执行向上检索的处理
			if (i == 0){
				e = findParentATag(e);
			}
			
			if(e.tagName == 'A')
			{
				testFlag = true;
			}
			else if(e.tagName == 'IMG')
			{
				testFlag = true;
			}
			else if((e.tagName == 'AREA') && e.href != null)
			{
				testFlag = true;
			}
			
			if (testFlag){
				return e;
			}
		}
	}
    
	return null;
}

  function GetTagURL(tag)
  {
    var att = tag.getAttribute('href');
    var url = tag.href;
    if (att == undefined)
    {
        return url;
    }
    else if (url == undefined)
    {
        return att;
    }
    else
    {
        return url.length > att.length ? url : att;
    }
  }

  function NewGetHTMLElementsAtPoint(x,y)
  {
      var testFlag = false;
      var offset = [[0, 0], [-15, 0], [0, -15], [15, 0], [0, 15], [15, 15], [-15, -15], [15, -15], [-15, 15]];
      var aTag = null;
      // 根据产品的意见, 不对嵌套的元素进行递归查找<a>, <img>元素
      for (var i=0;i<offset.length;i++)
      {
          var x1 = x + offset[i][0];
          var y1 = y + offset[i][1];
          var e = document.elementFromPoint(x1,y1);
          
          if (e)
          {
              e = UCWEBAppHandleIFrameElement(x1, y1, e);
              if (!e){
              continue;
              }
              // 只对第一次，即正中的点击坐标所取的元素才执行向上检索的处理
              if (i == 0){
                aTag = findParentATag(e);
              }
  
              
              if(e.tagName == 'A')
              {
                testFlag = true;
              }
              else if(e.tagName == 'IMG')
              {
                testFlag = true;
              }
              else if((e.tagName == 'AREA') && e.href != null)
              {
                testFlag = true;
              }
              else if (aTag != e)
              {
                 return LPResult.createNew(GetTagURL(aTag),"", aTag.tagName, aTag.text, "", "");
              }
  
              if (testFlag)
              {
                 var aTagHref = GetTagURL(aTag);
                 if(typeof(aTagHref) == "undefined")
                 {
                    return LPResult.createNew(GetTagURL(e), e.src, e.tagName, "", e.naturalWidth, e.naturalHeight);
                 }
                 else
                 {
                    return LPResult.createNew(aTagHref, e.src, e.tagName, "", e.naturalWidth, e.naturalHeight);
                 }
              }
          }
      }
      
      return null;
  }

function positonOfElementByElement(obj)
{
	var  getPos=
	{
		getTop:function(e)
			{
				var offset=e.offsetTop;
  				if (e.offsetParent!=null)
  				{
  					offset+=getPos.getTop(e.offsetParent);
  				}
  				return offset;
			},
  		getLeft:function(e)
			{
  				var offset=e.offsetLeft;
  				if (e.offsetParent!=null)
				{
					offset+=getPos.getLeft(e.offsetParent);
				}
				return offset;
			},
		getCss3offsetTop:function(e)
			{
				//console.log(e)
				var css3offset=window.getComputedStyle(e).webkitTransform;
				if (css3offset=="none")
				{
					var css3offsetTop=0;
				}else
				{//存在CSS3属性
					//console.log(e.id)
					var css3offsetTop=parseInt(css3offset.split(",")[5].replace(")",""),10)
					//console.log(css3offsetTop)
				}
  
				if (e.parentNode.tagName!="BODY")
				{
					css3offsetTop+=getPos.getCss3offsetTop(e.parentNode);
				}
				return css3offsetTop;
  
			},
		getCss3offsetLeft:function(e)
			{
				//console.log(e)
				var css3offset=window.getComputedStyle(e).webkitTransform;
				if (css3offset=="none")
				{
					var css3offsetLeft=0;
				}
				else
				{//存在CSS3属性
					var css3offsetLeft=parseInt(css3offset.split(",")[4],10)
				}
  
				if (e.parentNode.tagName!="BODY")
				{
					css3offsetLeft+=getPos.getCss3offsetLeft(e.parentNode);
				}
  
				return css3offsetLeft;
			},
		getNodeInfoByElement:function(obj)
			{
				//var myNode=document.getElementById(e);
				var myNode=obj;
				if (myNode)
				{
					var pos =  '{{'+(getPos.getLeft(myNode)+getPos.getCss3offsetLeft(myNode))+','+(getPos.getTop(myNode)+getPos.getCss3offsetTop(myNode))+'},{'+myNode.offsetWidth+','+myNode.offsetHeight+'}}';
					return pos;
				}
				else
				{
					return ""
				}
			}
		}
		
		return getPos.getNodeInfoByElement(obj);
}
  
function UCWEBAppGetHTMLElementsAtPoint(x,y)
{
	var tags = "■";
	var e = NewGetHTMLElementsAtPoint(x, y);
	
    // 根据产品的意见, 不对嵌套的元素进行递归查找<a>, <img>元素
	if (e)
	{
		if(e.tagName == 'A')
		{
			tags +=  e.tagName + '■';
			tags +=  e.href + '■';
			tags +=  e.text + '■';
		}
		else if(e.tagName == 'IMG')
		{
			tags +=  e.tagName + '■';
			tags +=  e.src + '■';
            tags +=  e.href + '■';
            tags +=  e.width + '■';
            tags +=  e.height + '■';
  
  			var node = document.elementFromPoint(x, y);
  			if (node)
  			{
  				tags += positonOfElementByElement(node) + '■';
  			}
		}
		else if((e.tagName == 'AREA') && e.href != null)
		{
			tags +=  e.tagName + '■';
			tags +=  e.href + '■';
		}
	}
	return tags;
}

function UCHomePageGetLinkInfoAtPoint(x, y)
{
    var des = '';
	var e = GetHTMLElementsAtPoint(x, y);
    if (e && e.children.length == 1 )
    {
        var c = e.children[0];
        if(c.tagName == 'A' || c.tagName =='a')
        {
            e = c;
        }
    }
    
    while(e)
    {
        if(e.tagName == 'A' || e.tagName == 'a')
        {
            des = e.innerText.trim();
            if (des.length > 0)
            {
                des = des + '■' + e.href;
            }
            
            break;
        }
        
        e = e.parentNode;
    }
    
    return des;
}

function UCHomePageGetHTMLElementsAtPoint(x, y)
{
    var tags = "■";
	var e = document.elementFromPoint(x,y);
	while (e) {
		if(e.tagName){
			tags += e.tagName + '■';
			if(e.tagName == 'A' || e.tagName =='a')
			{
				tags +=  e.href + '■';
				tags +=  e.text + '■';
				tags +=  '{{' + e.getBoundingClientRect().left + ', ';
				tags +=  e.getBoundingClientRect().top + '}, {';
				tags +=  e.offsetWidth + ', ';
				tags +=  e.offsetHeight + '}}'+ '■';
				//break;
			}
			else if(e.tagName == 'IMG' || e.tagName == 'img')
			{
				tags +=  e.tagName + '■';
				tags +=  e.src + '■';
				//break;
			}
			else if((e.tagName == 'AREA' || e.tagName == 'area') && e.href != null)
			{
				tags +=  e.tagName + '■';
				tags +=  e.href + '■';
				//break;
			}
		}
        
		e = e.parentNode;
	}
	
	return tags;
}

function UCWEBAppGetLinkHREFAtPoint(x,y)
{
	var tags = "";
    //	var e = document.elementFromPoint(x,y);
	var e = GetHTMLElementsAtPoint(x, y);
	while (e)
	{
		if (e.href)
		{
			tags += e.href;
			//tags +=  e.tagName + '■';
			//tags +=  e.href + '■';
			break;
		}
		e = e.parentNode;
	}
	return tags;
}

function UCWEBGetLinkInfoAtPoint(x, y)
{
    var des = '';
	var e = GetHTMLElementsAtPoint(x, y);
    while(e)
    {
        if(e.tagName == 'A' || e.tagName == 'a')
        {
            des = e.innerText.trim();
            if (des.length > 0)
            {
                des = des + '■' + e.href;
            }
            
            break;
        }
        
        e = e.parentNode;
    }
    
    return des;
}


function UCWEBAppGetElementTagAtPoint(x, y)
{
   	var tags = "";
	var e = document.elementFromPoint(x,y);
    // 根据产品的意见, 不对嵌套的元素进行递归查找<a>, <img>元素
	if (e)
	{
		if (e.tagName)
		{
			e = UCWEBAppHandleIFrameElement(x, y, e);
            tags = e.tagName;
        }
    }
    
    return tags;
}

function canBeTapToScrollAtPoint(x, y)
{
    var canBeTapToScrollAtPoint = "false";
    
   	var e = document.elementFromPoint(x,y);
	if (e)
	{
		if (e.tagName)
		{
			e = UCWEBAppHandleIFrameElement(x, y, e);
            
            if (!e.href
                && !e.hasAttribute("onclick")
                && !e.hasAttribute("onselect")
                && !e.hasAttribute("onsubmit")
                && !e.hasAttribute("onreset")
                && !e.hasAttribute("ondblclick")
                && !e.hasAttribute("onmousedown")
                && !e.hasAttribute("onmouseup")
                && !e.hasAttribute("onkeyup")
                && !e.hasAttribute("onkeydown")
                && !e.hasAttribute("onkeypress"))
                
            {
                var upperTagName = e.tagName.toUpperCase();
                if((upperTagName != "INPUT")
				   &&(upperTagName != "SELECT")
				   &&(upperTagName != "TEXTAREA")
				   &&(upperTagName != "OPTGROUP")
				   &&(upperTagName != "OPTION"))
                {
                    canBeTapToScrollAtPoint = "true";
                }
            }
        }
    }
    
    return canBeTapToScrollAtPoint;
}
  
var JSPoint = {
  createNew: function(x,y){
  var point = {};
  point.x = x;
  point.y = y;
  return point;
  }
};
  
function convertViewPointToPage(x,y, viewSizeWidth, hrefPointX, hrefPointY)
{
  
  var longPressPointX = x;
  var longPressPointY = y;
  var offsetY = window.pageYOffset;
  var windowSizeWidth = window.innerWidth;
  var convertValue = windowSizeWidth / viewSizeWidth;
  if (offsetY < 1)//不知道有什么作用,用于保持与旧代码相同的逻辑
  {
      longPressPointX = hrefPointX;
      longPressPointY = hrefPointY;
  }
  longPressPointX = longPressPointX * convertValue;
  longPressPointY = longPressPointY * convertValue;
  return JSPoint.createNew(longPressPointX,longPressPointY);
}

function UCWEBAppGetLongPressResultAtPoint(x,y, viewSizeWidth, hrefPointX, hrefPointY)
{
    var pagePoint = convertViewPointToPage(x,y, viewSizeWidth, hrefPointX, hrefPointY);
    x = pagePoint.x;
    y = pagePoint.y;
    var resultHref = "";
    var e = GetHTMLElementsAtPoint(x,y);
    
    if (e == undefined)
    {
        return resultHref;
    }
    
    if(e.tagName == 'A')
    {
        if (e.href != undefined)
        {
            resultHref = e.href;
        }
    }
    else if(e.tagName == 'IMG')
    {
        resultHref = "";
        var tagHREF = UCWEBAppGetLinkHREFAtPoint(x,y);
        if (tagHREF.length > 0)
        {
            resultHref += tagHREF;
        }
        resultHref += "■";
        if (e.src != undefined)
        {
            resultHref += e.src;
        }
        if (resultHref.length == 1)
        {
            resultHref = "";
        }
    }
    else
    {
        var tagHREF = UCWEBAppGetLinkHREFAtPoint(x,y);
        if (tagHREF.length > 0)
        {
            resultHref = tagHREF;
        }
    }

    //结果:
    //1. 没有找到URL,则返回 ""
    //2. 找到超链接则返回   href
    //3. 找到图片链接则返回  href■src
  return resultHref ;//+ "■" + "■" + x + "■" + y;
}
  
  function UCWEBAppGetTapResultAtPoint(x,y, viewSizeWidth, hrefPointX, hrefPointY)
  {
     var pagePoint = convertViewPointToPage(x,y, viewSizeWidth, hrefPointX, hrefPointY);
     var x1 = pagePoint.x;
     var y1 = pagePoint.y;
     var resultHref = UCWEBGetLinkInfoAtPoint(x1,y1);
  
     return resultHref;
  }
  
window['UCWEBAppGetHTMLElementsAtPoint']=UCWEBAppGetHTMLElementsAtPoint;
window['UCWEBAppGetLinkHREFAtPoint']=UCWEBAppGetLinkHREFAtPoint;
window['UCWEBGetLinkInfoAtPoint']=UCWEBGetLinkInfoAtPoint;
window['UCWEBAppGetLongPressResultAtPoint']=UCWEBAppGetLongPressResultAtPoint;
window['UCWEBAppGetTapResultAtPoint']=UCWEBAppGetTapResultAtPoint;
window['UCHomePageGetLinkInfoAtPoint']=UCHomePageGetLinkInfoAtPoint;
window['UCHomePageGetHTMLElementsAtPoint']=UCHomePageGetHTMLElementsAtPoint;

})();