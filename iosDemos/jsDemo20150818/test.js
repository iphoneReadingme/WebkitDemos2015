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
                if (typeof ucbrowser != 'undefined' && ucbrowser.isMethodSupported('picBImgClicked'))
                {
					var cs = window.getComputedStyle(e);
                    var data = {};
                    data["src"] = e.target.src;
					data["tag"] = '%d';
					data["naturalWidth"] = img.naturalWidth;
					data["naturalHeight"] = img.naturalHeight;
					data["clientWidth"] = img.width;
					data["clientHeight"] = img.height;
					data["width"] = cs.width;
					data["height"] = cs.height;
					data["x"] = 0;
					data["y"] = 0;
					
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
