//function UC_picBAddImgClickObserver(picBCurrentWebAgentTag, picBMaxImgCount)
function onButtonClicked(e)
{
    var imgs = Array.prototype.slice.call(document.images);
    var length = imgs.length;
    for(var i=0;i<length;i++)
    {
        var img = imgs[i];
        if (img.className.indexOf('galleryLink') >= 0)
        {
            continue;
        }
        var imgHref = img.getAttribute("href");
        var parent = img.parentNode;
        if (null != parent)
        {
            var dataLink = parent.getAttribute("data-link");
            if (dataLink)
            {
                continue;
            }
            parent = parent.parentNode;
        }
        if (null == img.onclick && (imgHref == null || imgHref == "") &&
            (null == parent || (parent.tagName != 'A' && parent.className.indexOf('bigImgContainer') < 0)) &&
            img.naturalWidth >= 200 && img.naturalHeight >= 200)
        {
            img.onclick = function onImgClick(e)
            {
                //if (typeof ucbrowser != 'undefined' && ucbrowser.isMethodSupported('picBImgClicked'))
                {
					var cs = window.getComputedStyle(img);
                    var data = {};
                    data["src"] = e.target.src;
                    data["tag"] = '%d';
                    data["naturalWidth"] = img.naturalWidth;
                    data["naturalHeight"] = img.naturalHeight;
                    data["clientX"] = e.clientX;
                    data["clientY"] = e.clientY;
                    data["width"] = cs.width;
                    data["height"] = cs.height;
                    data["info"] = positonOfElementByElement(img); // 得到字符串："{{8,196},{362,233}}"，可以转换成CGRect
					
                    //var jsonString = JSON.stringify(data);
                    //ucbrowser.picBImgClicked(jsonString);
                }
            }
        }
        if (i > '%d')
        {
            break;
        }
    }
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
                var rect
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

