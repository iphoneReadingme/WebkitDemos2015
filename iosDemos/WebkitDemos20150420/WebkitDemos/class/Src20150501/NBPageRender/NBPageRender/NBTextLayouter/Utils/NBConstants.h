

#import <Foundation/Foundation.h>


// unicode characters

#define UNICODE_OBJECT_PLACEHOLDER @"\ufffc"
#define UNICODE_LINE_FEED @"\u2028"

// unicode spaces (see http://www.cs.tut.fi/~jkorpela/chars/spaces.html)

#define UNICODE_SPACE @"\u0020"
#define UNICODE_NON_BREAKING_SPACE @"\u00a0"
#define UNICODE_OGHAM_SPACE_MARK @"\u1680"
#define UNICODE_MONGOLIAN_VOWEL_SEPARATOR @"\u180e"
#define UNICODE_EN_QUAD @"\u2000"
#define UNICODE_EM_QUAD @"\u2001"
#define UNICODE_EN_SPACE @"\u2002"
#define UNICODE_EM_SPACE @"\u2003"
#define UNICODE_THREE_PER_EM_SPACE @"\u2004"
#define UNICODE_FOUR_PER_EM_SPACE @"\u2005"
#define UNICODE_SIX_PER_EM_SPACE @"\u2006"
#define UNICODE_FIGURE_SPACE @"\u2007"
#define UNICODE_PUNCTUATION_SPACE @"\u2008"
#define UNICODE_THIN_SPACE @"\u2009"
#define UNICODE_HAIR_SPACE @"\u200a"
#define UNICODE_ZERO_WIDTH_SPACE @"\u200b"
#define UNICODE_NARROW_NO_BREAK_SPACE @"\u202f"
#define UNICODE_MEDIUM_MATHEMATICAL_SPACE @"\u205f"
#define UNICODE_IDEOGRAPHIC_SPACE @"\u3000"
#define UNICODE_ZERO_WIDTH_NO_BREAK_SPACE @"\ufeff"

// standard options

#if TARGET_OS_IPHONE
extern NSString * const NSBaseURLDocumentOption;
extern NSString * const NSTextEncodingNameDocumentOption;
extern NSString * const NSTextSizeMultiplierDocumentOption;
extern NSString * const NSAttachmentAttributeName; 
#endif

// custom options

extern NSString * const NBMaxImageSize;
extern NSString * const NBDefaultFontFamily;
extern NSString * const NBDefaultFontName;
extern NSString * const NBDefaultFontSize;
extern NSString * const NBDefaultTextColor;
extern NSString * const NBDefaultLinkColor;
extern NSString * const NBDefaultLinkDecoration;
extern NSString * const NBDefaultLinkHighlightColor;
extern NSString * const NBDefaultTextAlignment;
extern NSString * const NBDefaultLineHeightMultiplier;
extern NSString * const NBDefaultLineHeightMultiplier;
extern NSString * const NBDefaultFirstLineHeadIndent;
extern NSString * const NBDefaultHeadIndent;
extern NSString * const NBDefaultStyleSheet;
extern NSString * const NBUseiOS6Attributes;
extern NSString * const NBWillFlushBlockCallBack;
extern NSString * const NBProcessCustomHTMLAttributes;
extern NSString * const NBIgnoreInlineStylesOption;


// attributed string attribute constants

extern NSString * const NBTextListsAttribute;
extern NSString * const NBAttachmentParagraphSpacingAttribute;
extern NSString * const NBLinkAttribute;
extern NSString * const NBLinkHighlightColorAttribute;
extern NSString * const NBAnchorAttribute;
extern NSString * const NBGUIDAttribute;
extern NSString * const NBHeaderLevelAttribute;
extern NSString * const NBStrikeOutAttribute;
extern NSString * const NBBackgroundColorAttribute;
extern NSString * const NBShadowsAttribute;
extern NSString * const NBHorizontalRuleStyleAttribute;
extern NSString * const NBTextBlocksAttribute;
extern NSString * const NBFieldAttribute;
extern NSString * const NBCustomAttributesAttribute;
extern NSString * const NBAscentMultiplierAttribute;
extern NSString * const NBBackgroundStrokeColorAttribute;
extern NSString * const NBBackgroundStrokeWidthAttribute;
extern NSString * const NBBackgroundCornerRadiusAttribute;


