

#import <UIKit/UIKit.h>
#import "NBParagraphStyle.h"

/**
 Convenience methods for editors dealing with Core Text attribute dictionaries.
 */
@interface NSDictionary (NBCoreText)

/**
 @name Getting State information
 */

/**
 Whether the font in the receiver's attributes is bold.
 @returns `YES` if the text has a bold trait
 */
- (BOOL)isBold;

/**
 Whether the font in the receiver's attributes is italic.
 @returns `YES` if the text has an italic trait
 */
- (BOOL)isItalic;

/**
 Whether the receiver's attributes contains underlining.
 @returns `YES` if the text is underlined
 */
- (BOOL)isUnderline;

/**
 Whether the receiver's attributes contains strike-through.
 @returns `YES` if the text is strike-through
 */
- (BOOL)isStrikethrough;

/**
 Whether the receiver's attributes contain a DTTextAttachment
 @returns `YES` if ther is an attachment
 */
- (BOOL)hasAttachment;

/**
 The header level of the receiver
 @returns The header level (1-6) or 0 if no header level is set
 */
- (NSUInteger)headerLevel;

/**
 @name Getting Style Information
 */

/**
 Retrieves the CoreTextParagraphStyle from the receiver's attributes. This supports both `CTParagraphStyle` as well as `NSParagraphStyle` as a possible representation of the text's paragraph style.
 @returns The paragraph style
 */
- (NBParagraphStyle *)paragraphStyle;

/**
 Retrieves the CoreTextFontDescriptor from the receiver's attributes. This supports both `CTFont` as well as `UIFont` as a possible representation of the text's font.
 @returns The font descriptor
 */
//- (NBFontDescriptor *)fontDescriptor;

/**
 Retrieves the foreground color. On iOS as UIColor, on Mac as NSColor. This supports both the CT as well as the NS/UIKit method of specifying the color. If no foreground color is defined in the receiver then black is assumed.
 @returns The platform-specific color defined for the foreground
 */
- (UIColor *)foregroundColor;

/**
 Retrieves the background color. On iOS as UIColor, on Mac as NSColor. This supports both the DT as well as the NS/UIKit method of specifying the color. If no background color is defined in the receiver then `nil` is returned
 @returns The platform-specific color defined for the background, or `nil` if none is defined
 */
- (UIColor *)backgroundColor;

/**
 The text kerning value
 @returns the kerning value
 */
- (CGFloat)kerning;

@end
