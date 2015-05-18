

#import "NBFontDescriptor.h"
#import "NBFontCollection.h"


#if TARGET_OS_IPHONE
#import <CoreText/CoreText.h>
#elif TARGET_OS_MAC
#import <ApplicationServices/ApplicationServices.h>
#endif

@interface NBFontCollection ()

@property (nonatomic, strong) NSArray *fontDescriptors;
@property (nonatomic, strong) NSCache *fontMatchCache;

- (id)initWithAvailableFonts;

@end

static NBFontCollection *_availableFontsCollection = nil;


@implementation NBFontCollection
{
	NSArray *_fontDescriptors;
	NSCache *_fontMatchCache;
}

+ (NBFontCollection *)availableFontsCollection
{
	static dispatch_once_t predicate;

	dispatch_once(&predicate, ^{
		_availableFontsCollection = [[NBFontCollection alloc] initWithAvailableFonts];
	});
	
	return _availableFontsCollection;
}

- (void)dealloc
{
	[_fontDescriptors release];
	_fontDescriptors = nil;
	
	[_fontMatchCache release];
	_fontMatchCache = nil;
	
	[super dealloc];
}

- (id)initWithAvailableFonts
{
	self = [super init];
	
	if (self)
	{
		
	}
	
	return self;
}


- (NBFontDescriptor *)matchingFontDescriptorForFontDescriptor:(NBFontDescriptor *)descriptor
{
	NBFontDescriptor *firstMatch = nil;
	NSString *cacheKey = [NSString stringWithFormat:@"fontFamily BEGINSWITH[cd] %@ and boldTrait == %d and italicTrait == %d", descriptor.fontFamily, descriptor.boldTrait, descriptor.italicTrait];
	
	firstMatch = [self.fontMatchCache objectForKey:cacheKey];
	
	if (firstMatch)
	{
		NBFontDescriptor *retMatch = [[firstMatch copy] autorelease];
		retMatch.pointSize = descriptor.pointSize;
		return retMatch;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fontFamily BEGINSWITH[cd] %@ and boldTrait == %d and italicTrait == %d", descriptor.fontFamily, descriptor.boldTrait, descriptor.italicTrait];
	
	NSArray *matchingDescriptors = [self.fontDescriptors filteredArrayUsingPredicate:predicate];
	
	//NSLog(@"%@", matchingDescriptors);
	
	if ([matchingDescriptors count])
	{
		firstMatch = [matchingDescriptors objectAtIndex:0];
		[self.fontMatchCache setObject:firstMatch forKey:cacheKey];
		
		NBFontDescriptor *retMatch = [[firstMatch copy] autorelease];
		
		retMatch.pointSize = descriptor.pointSize;
		return retMatch;
	}
	
	return nil;
}

#pragma mark Properties

- (NSArray *)fontDescriptors
{
	if (!_fontDescriptors)
	{
		CTFontCollectionRef fonts = CTFontCollectionCreateFromAvailableFonts(NULL);
		
		CFArrayRef matchingFonts = CTFontCollectionCreateMatchingFontDescriptors(fonts);
		
		if (matchingFonts)
		{
			NSMutableArray *tmpArray = [[[NSMutableArray alloc] init] autorelease];
			
			for (NSInteger i=0; i<CFArrayGetCount(matchingFonts); i++)
			{
				CTFontDescriptorRef fontDesc = (CTFontDescriptorRef)CFArrayGetValueAtIndex(matchingFonts, i);
				
				
				NBFontDescriptor *desc = [[[NBFontDescriptor alloc] initWithCTFontDescriptor:fontDesc] autorelease];
				[tmpArray addObject:desc];
			}
			
			CFRelease(matchingFonts);
			
			self.fontDescriptors = [tmpArray retain];
		}
		
		CFRelease(fonts);
	}
	
	return _fontDescriptors;
}

- (NSCache *)fontMatchCache
{
	if (!_fontMatchCache)
	{
		_fontMatchCache = [[NSCache alloc] init];
	}
	
	return _fontMatchCache;
}

- (NSArray *)fontFamilyNames
{
	NSMutableArray *tmpArray = [NSMutableArray array];
	
	for (NBFontDescriptor *oneDescriptor in [self fontDescriptors])
	{
		NSString *familyName = oneDescriptor.fontFamily;
		
		if (![tmpArray containsObject:familyName])
		{
			[tmpArray addObject:familyName];
		}
	}
	
	return [tmpArray sortedArrayUsingSelector:@selector(compare:)];
}

@synthesize fontDescriptors = _fontDescriptors;
@synthesize fontMatchCache = _fontMatchCache;

@end
