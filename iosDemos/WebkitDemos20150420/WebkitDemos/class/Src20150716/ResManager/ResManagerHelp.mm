
#import "ResManagerHelp.h"



#define kHardcodeResourceDir           @"resource/Themes/Classic/Images"

//获取屏幕相对于物理尺寸的缩放比例
//对于普通屏幕来说,结果是1.0
//对于retina来说,结果是2.0
inline CGFloat getScreenScale()
{
	CGFloat scale = 1.0;
	UIScreen* screen = [UIScreen mainScreen];
	if([screen respondsToSelector:@selector(scale)])
	{
		scale = [screen scale];
	}
	
	return scale;
}

@implementation ResManagerHelp



+ (NSString *)get2xPathWithPath:(NSString*)path
{
	if ([path length] == 0)
	{
		return nil;
	}
	
	NSString* fileName = [[path lastPathComponent] stringByDeletingPathExtension];
	NSString* path2x = nil;
	
	if ([fileName hasSuffix:@"@2x"])
	{
		path2x = path;
	}
	else if ([fileName hasSuffix:@"@3x"])
	{
		fileName = [fileName stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
		path2x = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:
				  [NSString stringWithFormat:@"%@@2x.%@", fileName, [path pathExtension]]];
	}
	else
	{
		path2x = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:
				  [NSString stringWithFormat:@"%@@2x.%@", fileName, [path pathExtension]]];
	}
	
	return path2x;
}

+ (NSString *)get3xPathWithPath:(NSString*)path
{
	if ([path length] == 0)
	{
		return nil;
	}
	
	NSString* fileName = [[path lastPathComponent] stringByDeletingPathExtension];
	NSString* path3x = nil;
	
	if ([fileName hasSuffix:@"@3x"])
	{
		path3x = path;
	}
	else if ([fileName hasSuffix:@"@2x"])
	{
		fileName = [fileName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
		path3x = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:
				  [NSString stringWithFormat:@"%@@3x.%@", fileName, [path pathExtension]]];
	}
	else
	{
		path3x = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:
				  [NSString stringWithFormat:@"%@@3x.%@", fileName, [path pathExtension]]];
	}
	
	return path3x;
}

+ (UIImage*)getImageObjectBy:(NSString*)shortName
{
	NSString* filePath = [kHardcodeResourceDir stringByAppendingPathComponent:shortName];
	filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filePath];
	
	// 如果文件不存在，则查找高分(@2x)文件...
	NSString* path2x = [ResManagerHelp get2xPathWithPath:filePath];
	
	// 加载原始@2x文件
	UIImage * image2x = [[[UIImage alloc] initWithContentsOfFile:path2x] autorelease];
	
	return image2x;
}

@end
