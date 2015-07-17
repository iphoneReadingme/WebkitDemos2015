
#import "ResManagerHelp.h"
#import "ResManager.h"



UIImage* resGetImage(NSString* shortName)
{
	assert([shortName pathExtension].length > 0);
	
	UIImage* image = nil;
	
	image = [ResManagerHelp getImageObjectBy:shortName];
	
	return image;
}
