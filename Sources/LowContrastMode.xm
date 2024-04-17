#import "uYouPlus.h"

//
static int contrastMode() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"lcm"];
}
static BOOL lowContrastMode() {
    return IS_ENABLED(@"lowContrastMode_enabled") && contrastMode() == 0;
}
static BOOL customContrastMode() {
    return IS_ENABLED(@"lowContrastMode_enabled") && contrastMode() == 1;
}

UIColor *lcmHexColor;

%group gLowContrastMode // Low Contrast Mode v1.5.2 (Compatible with only YouTube v17.33.2-v17.38.10)
%hook UIColor
+ (UIColor *)whiteColor { // Dark Theme Color
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)lightTextColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)lightGrayColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)ychGrey7 {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)skt_chipBackgroundColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)placeholderTextColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)systemLightGrayColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)systemExtraLightGrayColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)labelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)secondaryLabelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)tertiaryLabelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)quaternaryLabelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
%end
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig;
}
- (UIColor *)textSecondary {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig;
}
- (UIColor *)overlayTextPrimary {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig;
}
- (UIColor *)overlayTextSecondary {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig;
}
- (UIColor *)iconActive {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig;
}
- (UIColor *)iconActiveOther {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig;
}
- (UIColor *)brandIconActive {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig;
}
- (UIColor *)staticBrandWhite {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig;
}
- (UIColor *)overlayIconActiveOther {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig;
}
- (UIColor *)overlayIconInactive {
    return self.pageStyle == 1 ? [[UIColor whiteColor] colorWithAlphaComponent:0.7] : %orig;
}
- (UIColor *)overlayIconDisabled {
    return self.pageStyle == 1 ? [[UIColor whiteColor] colorWithAlphaComponent:0.3] : %orig;
}
- (UIColor *)overlayFilledButtonActive {
    return self.pageStyle == 1 ? [[UIColor whiteColor] colorWithAlphaComponent:0.2] : %orig;
}
%end
%hook YTColor
+ (BOOL)darkerPaletteTextColorEnabled {
    return NO;
}
+ (UIColor *)white1 {
    return [UIColor whiteColor];
}
+ (UIColor *)white2 {
    return [UIColor whiteColor];
}
+ (UIColor *)white3 {
    return [UIColor whiteColor];
}
+ (UIColor *)white4 {
    return [UIColor whiteColor];
}
+ (UIColor *)white5 {
    return [UIColor whiteColor];
}
+ (UIColor *)grey1 {
    return [UIColor whiteColor];
}
+ (UIColor *)grey2 {
    return [UIColor whiteColor];
}
%end
%hook QTMColorGroup
- (UIColor *)tint100 {
    return [UIColor whiteColor];
}
- (UIColor *)tint300 {
    return [UIColor whiteColor];
}
- (UIColor *)tint500 {
    return [UIColor whiteColor];
}
- (UIColor *)tint700 {
    return [UIColor whiteColor];
}
- (UIColor *)accent200 {
    return [UIColor whiteColor];
}
- (UIColor *)accent400 {
    return [UIColor whiteColor];
}
- (UIColor *)accentColor {
    return [UIColor whiteColor];
}
- (UIColor *)brightAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)regularColor {
    return [UIColor whiteColor];
}
- (UIColor *)darkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)lightBodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnRegularColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnLighterColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnDarkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)buttonBackgroundColor {
    return [UIColor whiteColor];
}
%end
%hook YCHLiveChatLabel
- (NSAttributedString *)attributedText {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *modifiedAttributedString = [originalAttributedString mutableCopy];
    [modifiedAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, modifiedAttributedString.length)];
    return modifiedAttributedString;
}
%end
%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *currentImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[UIColor whiteColor]];
    %orig(currentImage);
}
%end
%hook UIExtendedSRGColorSpace
- (void)setTextColor:(UIColor *)textColor {
    textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    %orig();
}
%end
%hook UIExtendedSRGBColorSpace
- (void)setTextColor:(UIColor *)textColor {
    textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    %orig();
}
%end
%hook UIExtendedGrayColorSpace
- (void)setTextColor:(UIColor *)textColor {
    textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    %orig();
}
%end
%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end
%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end
%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig([UIColor whiteColor].CGColor);
}
%end
%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];
    return newAttributedString;
}
%end
%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook UIControl // snackbar fix for lcm
- (UIColor *)backgroundColor {
    return [UIColor blackColor];
}
%end
%end

%group gCustomContrastMode // Custom Contrast Mode (Hex Color)
%hook UIColor
+ (UIColor *)whiteColor {
         return lcmHexColor;
}
+ (UIColor *)lightTextColor {
         return lcmHexColor;
}
+ (UIColor *)lightGrayColor {
         return lcmHexColor;
}
+ (UIColor *)ychGrey7 {
         return lcmHexColor;
}
+ (UIColor *)skt_chipBackgroundColor {
         return lcmHexColor;
}
+ (UIColor *)placeholderTextColor {
         return lcmHexColor;
}
+ (UIColor *)systemLightGrayColor {
         return lcmHexColor;
}
+ (UIColor *)systemExtraLightGrayColor {
         return lcmHexColor;
}
+ (UIColor *)labelColor {
         return lcmHexColor;
}
+ (UIColor *)secondaryLabelColor {
         return lcmHexColor;
}
+ (UIColor *)tertiaryLabelColor {
         return lcmHexColor;
}
+ (UIColor *)quaternaryLabelColor {
         return lcmHexColor;
}
%end
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
    return self.pageStyle == 1 ? lcmHexColor : %orig;
}
- (UIColor *)textSecondary {
    return self.pageStyle == 1 ? lcmHexColor : %orig;
}
- (UIColor *)overlayTextPrimary {
    return self.pageStyle == 1 ? lcmHexColor : %orig;
}
- (UIColor *)overlayTextSecondary {
    return self.pageStyle == 1 ? lcmHexColor : %orig;
}
- (UIColor *)iconActive {
    return self.pageStyle == 1 ? lcmHexColor : %orig;
}
- (UIColor *)iconActiveOther {
    return self.pageStyle == 1 ? lcmHexColor : %orig;
}
- (UIColor *)brandIconActive {
    return self.pageStyle == 1 ? lcmHexColor : %orig;
}
- (UIColor *)staticBrandWhite {
    return self.pageStyle == 1 ? lcmHexColor : %orig;
}
- (UIColor *)overlayIconActiveOther {
    return self.pageStyle == 1 ? lcmHexColor : %orig;
}
- (UIColor *)overlayIconInactive {
    return self.pageStyle == 1 ? [lcmHexColor colorWithAlphaComponent:0.7] : %orig;
}
- (UIColor *)overlayIconDisabled {
    return self.pageStyle == 1 ? [lcmHexColor colorWithAlphaComponent:0.3] : %orig;
}
- (UIColor *)overlayFilledButtonActive {
    return self.pageStyle == 1 ? [lcmHexColor colorWithAlphaComponent:0.2] : %orig;
}
%end
%hook YTColor
+ (BOOL)darkerPaletteTextColorEnabled {
    return NO;
}
+ (UIColor *)white1 {
    return lcmHexColor;
}
+ (UIColor *)white2 {
    return lcmHexColor;
}
+ (UIColor *)white3 {
    return lcmHexColor;
}
+ (UIColor *)white4 {
    return lcmHexColor;
}
+ (UIColor *)white5 {
    return lcmHexColor;
}
+ (UIColor *)grey1 {
    return lcmHexColor;
}
+ (UIColor *)grey2 {
    return lcmHexColor;
}
%end
%hook QTMColorGroup
- (UIColor *)tint100 {
    return [UIColor whiteColor];
}
- (UIColor *)tint300 {
    return [UIColor whiteColor];
}
- (UIColor *)tint500 {
    return [UIColor whiteColor];
}
- (UIColor *)tint700 {
    return [UIColor whiteColor];
}
- (UIColor *)accent200 {
    return [UIColor whiteColor];
}
- (UIColor *)accent400 {
    return [UIColor whiteColor];
}
- (UIColor *)accentColor {
    return [UIColor whiteColor];
}
- (UIColor *)brightAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)regularColor {
    return [UIColor whiteColor];
}
- (UIColor *)darkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)lightBodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnRegularColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnLighterColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnDarkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)buttonBackgroundColor {
    return [UIColor whiteColor];
}
%end
%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *currentImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[UIColor whiteColor]];
    %orig(currentImage);
}
%end
%hook UIExtendedSRGColorSpace
- (void)setTextColor:(UIColor *)textColor {
    textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    %orig();
}
%end
%hook UIExtendedSRGBColorSpace
- (void)setTextColor:(UIColor *)textColor {
    textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    %orig();
}
%end
%hook UIExtendedGrayColorSpace
- (void)setTextColor:(UIColor *)textColor {
    textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    %orig();
}
%end
%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end
%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end
%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig([UIColor whiteColor].CGColor);
}
%end
%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];
    return newAttributedString;
}
%end
%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook UIControl // snackbar fix for lcm
- (UIColor *)backgroundColor {
    return [UIColor blackColor];
}
%end
%end

# pragma mark - ctor
%ctor {
    %init;
    if (lowContrastMode()) {
        %init(gLowContrastMode);
    }
    if (customContrastMode()) {
    NSData *lcmColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCustomUIColor"];
    NSKeyedUnarchiver *lcmUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:lcmColorData error:nil];
    [lcmUnarchiver setRequiresSecureCoding:NO];
    NSString *lcmHexString = [lcmUnarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    if (lcmHexString != nil) {
        lcmHexColor = [lcmUnarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
        %init(gCustomContrastMode);
        }
    }
}
