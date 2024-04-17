#import "uYouPlusSettings.h"
#import "RootOptionsController.h"
#import "ColourOptionsController.h"
#import "ColourOptionsController2.h"
#import "AppIconOptionsController.h"

#define VERSION_STRING [[NSString stringWithFormat:@"%@", @(OS_STRINGIFY(TWEAK_VERSION))] stringByReplacingOccurrencesOfString:@"\"" withString:@""]
#define SHOW_RELAUNCH_YT_SNACKBAR [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:LOC(@"RESTART_YOUTUBE")]]

#define SECTION_HEADER(s) [sectionItems addObject:[%c(YTSettingsSectionItem) itemWithTitle:@"\t" titleDescription:[s uppercaseString] accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) { return NO; }]]

#define SWITCH_ITEM(t, d, k) [sectionItems addObject:[YTSettingsSectionItemClass switchItemWithTitle:t titleDescription:d accessibilityIdentifier:nil switchOn:IS_ENABLED(k) switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:k];return YES;} settingItemId:0]]

#define SWITCH_ITEM2(t, d, k) [sectionItems addObject:[YTSettingsSectionItemClass switchItemWithTitle:t titleDescription:d accessibilityIdentifier:nil switchOn:IS_ENABLED(k) switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:k];SHOW_RELAUNCH_YT_SNACKBAR;return YES;} settingItemId:0]]

static int contrastMode() {
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSComparisonResult result1 = [appVersion compare:@"17.33.2" options:NSNumericSearch];
    NSComparisonResult result2 = [appVersion compare:@"17.38.10" options:NSNumericSearch];

    if (result1 != NSOrderedAscending && result2 != NSOrderedDescending) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"lcm"];
    } else {
        return 0;
    }
}
static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}
static const NSInteger uYouPlusSection = 500;

@interface YTSettingsSectionItemManager (uYouPlus)
- (void)updateTweakSectionWithEntry:(id)entry;
@end

extern NSBundle *uYouPlusBundle();

// Settings Search Bar
%hook YTSettingsViewController
- (void)loadWithModel:(id)model fromView:(UIView *)view {
    %orig;
    if ([[self valueForKey:@"_detailsCategoryID"] integerValue] == uYouPlusSection)
        MSHookIvar<BOOL>(self, "_shouldShowSearchBar") = YES;
}
- (void)setSectionControllers {
    %orig;
    if (MSHookIvar<BOOL>(self, "_shouldShowSearchBar")) {
        YTSettingsSectionController *settingsSectionController = [self settingsSectionControllers][[self valueForKey:@"_detailsCategoryID"]];
        YTSearchableSettingsViewController *searchableVC = [self valueForKey:@"_searchableSettingsViewController"];
        if (settingsSectionController)
            [searchableVC storeCollectionViewSections:@[settingsSectionController]];
    }
}
%end

// Settings
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(uYouPlusSection) atIndex:insertIndex + 1];
    return mutableOrder;
}
%end

%hook YTSettingsSectionController
- (void)setSelectedItem:(NSUInteger)selectedItem {
    if (selectedItem != NSNotFound) %orig;
}
%end

%hook YTSettingsSectionItemManager
%new(v@:@)
- (void)updateTweakSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = uYouPlusBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    # pragma mark - App Icon Customization
    YTSettingsSectionItem *appIcon = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"Change App Icon")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            AppIconOptionsController *appIconController = [[AppIconOptionsController alloc] init];
            [settingsViewController.navigationController pushViewController:appIconController animated:YES];
            return YES;
        }
    ];
    [sectionItems addObject:appIcon];

    # pragma mark - About
    // SECTION_HEADER(LOC(@"ABOUT"));

    YTSettingsSectionItem *version = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"uYouEnhanced")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return VERSION_STRING;
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@""]];
        }
    ];
    [sectionItems addObject:version];

    YTSettingsSectionItem *bug = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"REPORT_AN_ISSUE")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSString *url = [NSString stringWithFormat:@"https://github.com/arichornlover/uYouEnhanced/issues/new?assignees=&labels=bug&projects=&template=bug.yaml&title=[v%@] %@", VERSION_STRING, LOC(@"ADD_TITLE")];

            return [%c(YTUIUtils) openURL:[NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]];
        }
    ];
    [sectionItems addObject:bug];

    YTSettingsSectionItem *developers = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"Support the Developers")
        titleDescription:LOC(@"MiRO92, PoomSmart, level3tjg, BandarHL, julioverne & Galactic-dev")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return nil;
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/arichornlover/uYouEnhanced/blob/main/README.md#support-the-developers"]];
        }
    ];
    [sectionItems addObject:developers];

    YTSettingsSectionItem *exitYT = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"QUIT_YOUTUBE")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            // https://stackoverflow.com/a/17802404/19227228
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
            [NSThread sleepForTimeInterval:0.5];
            exit(0);
        }
    ];
    [sectionItems addObject:exitYT];

    # pragma mark - App theme
    SECTION_HEADER(LOC(@"THEME_OPTIONS"));

    YTSettingsSectionItem *themeGroup = [YTSettingsSectionItemClass
        itemWithTitle:LOC(@"DARK_THEME")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (APP_THEME_IDX) {
                case 1:
                    return LOC(@"OLD_DARK_THEME");
                case 2:
                    return LOC(@"OLED_DARK_THEME_2");
                case 0:
                default:
                    return LOC(@"DEFAULT_THEME");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass
                    checkmarkItemWithTitle:LOC(@"DEFAULT_THEME")
                    titleDescription:LOC(@"DEFAULT_THEME_DESC")
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"appTheme"];
                        [settingsViewController reloadData];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                ],
                [YTSettingsSectionItemClass
                    checkmarkItemWithTitle:LOC(@"OLD_DARK_THEME")
                    titleDescription:LOC(@"OLD_DARK_THEME_DESC")
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"appTheme"];
                        [settingsViewController reloadData];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                ],
                [YTSettingsSectionItemClass
                    checkmarkItemWithTitle:LOC(@"OLED_DARK_THEME")
                    titleDescription:LOC(@"OLED_DARK_THEME_DESC")
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"appTheme"];
                        [settingsViewController reloadData];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                ],
                [YTSettingsSectionItemClass
                    checkmarkItemWithTitle:LOC(@"Custom Dark Theme")
                    titleDescription:LOC(@"In order to use Custom Themes that is in the uYouPlus Button, you will need to select this to be able to use custom colors.")
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"appTheme"];
                        [settingsViewController reloadData];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                ],
                [YTSettingsSectionItemClass
                    switchItemWithTitle:LOC(@"OLED_KEYBOARD")
                    titleDescription:LOC(@"OLED_KEYBOARD_DESC")
                    accessibilityIdentifier:nil
                    switchOn:IS_ENABLED(@"oledKeyBoard_enabled")
                    switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"oledKeyBoard_enabled"];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                    settingItemId:0
                ]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc]
                initWithNavTitle:LOC(@"THEME_OPTIONS")
                pickerSectionTitle:[LOC(@"THEME_OPTIONS") uppercaseString]
                rows:rows selectedItemIndex:APP_THEME_IDX
                parentResponder:[self parentResponder]
            ];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];
    [sectionItems addObject:themeGroup];

    # pragma mark - Video player options
    SECTION_HEADER(LOC(@"VIDEO_PLAYER_OPTIONS"));

    SWITCH_ITEM2(LOC(@"Enable Portrait Fullscreen"), LOC(@"Enables Portrait Fullscreen on the YouTube App. App restart is required. (only for iPhone)"), @"portraitFullscreen_enabled");
    SWITCH_ITEM2(LOC(@"SLIDE_TO_SEEK"), LOC(@"SLIDE_TO_SEEK_DESC"), @"slideToSeek_enabled");
    SWITCH_ITEM2(LOC(@"Enable Tap To Seek"), LOC(@"Jump to anywhere in a video by single-tapping the seek bar"), @"YTTapToSeek_enabled");
    SWITCH_ITEM(LOC(@"DISABLE_DOUBLE_TAP_TO_SEEK"), LOC(@"DISABLE_DOUBLE_TAP_TO_SEEK_DESC"), @"doubleTapToSeek_disabled");
//  SWITCH_ITEM2(LOC(@"SNAP_TO_CHAPTER"), LOC(@"SNAP_TO_CHAPTER_DESC"), @"snapToChapter_enabled");
    SWITCH_ITEM2(LOC(@"PINCH_TO_ZOOM"), LOC(@"PINCH_TO_ZOOM_DESC"), @"pinchToZoom_enabled");
    SWITCH_ITEM(LOC(@"YT_MINIPLAYER"), LOC(@"YT_MINIPLAYER_DESC"), @"ytMiniPlayer_enabled");
    SWITCH_ITEM2(LOC(@"STOCK_VOLUME_HUD"), LOC(@"STOCK_VOLUME_HUD_DESC"), @"stockVolumeHUD_enabled");
    SWITCH_ITEM2(LOC(@"Disable pull-to-fullscreen gesture"), LOC(@"Disable the drag gesture to enter vertical fullscreen. Only applies to landscape videos."), @"disablePullToFull_enabled");

    # pragma mark - Video controls overlay options
    SECTION_HEADER(LOC(@"VIDEO_PLAYER_OPTIONS"));

    SWITCH_ITEM(LOC(@"Enable Share Button"), LOC(@"Enable the Share Button in video controls overlay."), @"enableShareButton_enabled");
    SWITCH_ITEM(LOC(@"Enable 'Save To Playlist' Button"), LOC(@"Enable the 'Save To Playlist' Button in video controls overlay."), @"enableSaveToButton_enabled");
    SWITCH_ITEM(LOC(@"HIDE_YTMUSIC_BUTTON"), LOC(@"HIDE_YTMUSIC_BUTTON_DESC"), @"hideYTMusicButton_enabled");
    SWITCH_ITEM(LOC(@"HIDE_AUTOPLAY_SWITCH"), LOC(@"HIDE_AUTOPLAY_SWITCH_DESC"), @"hideAutoplaySwitch_enabled");
    SWITCH_ITEM(LOC(@"HIDE_SUBTITLES_BUTTON"), LOC(@"HIDE_SUBTITLES_BUTTON_DESC"), @"hideCC_enabled");
    SWITCH_ITEM(LOC(@"Hide Collapse (Arrow) Button"), LOC(@"Hides and Disables the Arrow Button in the Top Left of the Video Player."), @"disableCollapseButton_enabled");
    SWITCH_ITEM(LOC(@"Hide Fullscreen Button"), LOC(@"Hides and Disables the Fullscreen Button in the Video Player."), @"disableFullscreenButton_enabled");
    SWITCH_ITEM(LOC(@"HIDE_HUD_MESSAGES"), LOC(@"HIDE_HUD_MESSAGES_DESC"), @"hideHUD_enabled");
    SWITCH_ITEM(LOC(@"HIDE_PAID_PROMOTION_CARDS"), LOC(@"HIDE_PAID_PROMOTION_CARDS_DESC"), @"hidePaidPromotionCard_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_CHANNEL_WATERMARK"), LOC(@"HIDE_CHANNEL_WATERMARK_DESC"), @"hideChannelWatermark_enabled");
    SWITCH_ITEM2(LOC(@"Hide Shadow Overlay Buttons"), LOC(@"Hide the Shadow Overlay on the Play/Pause, Previous, Next, Forward & Rewind Buttons."), @"hideVideoPlayerShadowOverlayButtons_enabled");
    // SWITCH_ITEM(LOC(@"HIDE_PREVIOUS_AND_NEXT_BUTTON"), LOC(@"HIDE_PREVIOUS_AND_NEXT_BUTTON_DESC"), @"hidePreviousAndNextButton_enabled");
    SWITCH_ITEM2(LOC(@"RED_PROGRESS_BAR"), LOC(@"RED_PROGRESS_BAR_DESC"), @"redProgressBar_enabled");
    SWITCH_ITEM(LOC(@"HIDE_HOVER_CARD"), LOC(@"HIDE_HOVER_CARD_DESC"), @"hideHoverCards_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_RIGHT_PANEL"), LOC(@"HIDE_RIGHT_PANEL_DESC"), @"hideRightPanel_enabled");
    SWITCH_ITEM2(LOC(@"Hide Fullscreen Action Buttons"), LOC(@"Hides the buttons at the bottom of the screen when in landscape (only for iPhone)"), @"hideFullscreenActions_enabled");
    SWITCH_ITEM2(LOC(@"Hide Suggested Video"), LOC(@"Remove the suggested video popup when finishing a video. Note that this will prevent autoplay from working."), @"noSuggestedVideo_enabled");
    SWITCH_ITEM2(LOC(@"Hide Heatwaves"), LOC(@"Should hide the Heatwaves in the video player. App restart is required."), @"hideHeatwaves_enabled");
    SWITCH_ITEM2(LOC(@"Hide Double Tap to Seek Overlay"), LOC(@"This hides the animated double tap to seek overlay in the video player. App restart is required."), @"hideDoubleTapToSeekOverlay_enabled");
    SWITCH_ITEM2(LOC(@"Hide Dark Overlay Background"), LOC(@"Hide video player's dark overlay background. App restart is required."), @"hideOverlayDarkBackground_enabled");
    SWITCH_ITEM2(LOC(@"Disable Ambient Mode in Fullscreen"), LOC(@"When Enabled, this will Disable the functionality of Ambient Mode from being used in the Video Player when in Fullscreen. App restart is required."), @"disableAmbientMode_enabled");
    SWITCH_ITEM2(LOC(@"Hide Suggested Videos in Fullscreen"), LOC(@"Hide video player's suggested videos whenever in fullscreen. App restart is required."), @"noVideosInFullscreen_enabled");

   # pragma mark - Shorts controls overlay options
    SECTION_HEADER(LOC(@"SHORTS_CONTROLS_OVERLAY_OPTIONS"));

    SWITCH_ITEM(LOC(@"HIDE_SUPER_THANKS"), LOC(@"HIDE_SUPER_THANKS_DESC"), @"hideBuySuperThanks_enabled");
    SWITCH_ITEM(LOC(@"HIDE_SUBCRIPTIONS"), LOC(@"HIDE_SUBCRIPTIONS_DESC"), @"hideSubcriptions_enabled");
    // SWITCH_ITEM(LOC(@"DISABLE_RESUME_TO_SHORTS"), LOC(@"DISABLE_RESUME_TO_SHORTS_DESC"), @"disableResumeToShorts_enabled");

    # pragma mark - Video player button options
    SECTION_HEADER(LOC(@"Video Player Button Options"));

// (the options "Red Subscribe Button" and "Hide Button Containers under player" are currently not working)
//
//  SWITCH_ITEM(LOC(@"Red Subscribe Button"), LOC(@"Replaces the Subscribe Button color from being White to the color Red."), @"redSubscribeButton_enabled");
//  SWITCH_ITEM2(LOC(@"Hide Button Containers under player"), LOC(@"Hides Button Containers under the video player."), @"hideButtonContainers_enabled");
    SWITCH_ITEM(LOC(@"Hide the Connect Button under player"), LOC(@"Hides the Connect Button under the video player."), @"hideConnectButton_enabled");
    SWITCH_ITEM(LOC(@"Hide the Share Button under player"), LOC(@"Hides the Share Button under the video player."), @"hideShareButton_enabled");
    SWITCH_ITEM(LOC(@"HIDE_REMIX_BUTTON"), LOC(@"HIDE_REMIX_BUTTON_DESC"), @"hideRemixButton_enabled");
    SWITCH_ITEM(LOC(@"Hide the Thanks Button under player"), LOC(@"Hides the Thanks Button under the video player."), @"hideThanksButton_enabled");
    SWITCH_ITEM(LOC(@"HIDE_DOWNLOAD_BUTTON"), LOC(@"HIDE_DOWNLOAD_BUTTON_DESC"), @"hideDownloadButton_enabled");
    SWITCH_ITEM(LOC(@"HIDE_CLIP_BUTTON"), LOC(@"HIDE_CLIP_BUTTON_DESC"), @"hideClipButton_enabled");
    SWITCH_ITEM(LOC(@"Hide the Save to playlist Button under player"), LOC(@"Hides the Save to playlist Button under the video player."), @"hideSaveToPlaylistButton_enabled");
    SWITCH_ITEM(LOC(@"Hide the Report Button under player"), LOC(@"Hides the Report Button under the video player."), @"hideReportButton_enabled");
    SWITCH_ITEM(LOC(@"Hide Comment Section previews"), LOC(@"Makes the comment section blank with no previews under the player."), @"hidePreviewCommentSection_enabled");
    SWITCH_ITEM(LOC(@"Hide the comment section under player"), LOC(@"Hides the Comment Section below the player."), @"hideCommentSection_enabled");

# pragma mark - App settings overlay options
    SECTION_HEADER(LOC(@"App Settings Overlay Options"));

    SWITCH_ITEM2(LOC(@"Hide `Account` Section"), LOC(@"App restart is required."), @"disableAccountSection_enabled");
//  SWITCH_ITEM2(LOC(@"Hide `DontEatMyContent` Section"), LOC(@"App restart is required."), @"disableDontEatMyContentSection_enabled");
//  SWITCH_ITEM2(LOC(@"Hide `YouTube Return Dislike` Section"), LOC(@"App restart is required."), @"disableReturnYouTubeDislikeSection_enabled");
//  SWITCH_ITEM2(LOC(@"Hide `YouPiP` Section"), LOC(@"App restart is required."), @"disableYouPiPSection_enabled");
    SWITCH_ITEM2(LOC(@"Hide `Autoplay` Section"), LOC(@"App restart is required."), @"disableAutoplaySection_enabled");
    SWITCH_ITEM2(LOC(@"Hide `Try New Features` Section"), LOC(@"App restart is required."), @"disableTryNewFeaturesSection_enabled");
    SWITCH_ITEM2(LOC(@"Hide `Video quality preferences` Section"), LOC(@"App restart is required."), @"disableVideoQualityPreferencesSection_enabled");
    SWITCH_ITEM2(LOC(@"Hide `Notifications` Section"), LOC(@"App restart is required."), @"disableNotificationsSection_enabled");
    SWITCH_ITEM2(LOC(@"Hide `Manage all history` Section"), LOC(@"App restart is required."), @"disableManageAllHistorySection_enabled");
    SWITCH_ITEM2(LOC(@"Hide `Your data in YouTube` Section"), LOC(@"App restart is required."), @"disableYourDataInYouTubeSection_enabled");
    SWITCH_ITEM2(LOC(@"Hide `Privacy` Section"), LOC(@"App restart is required."), @"disablePrivacySection_enabled");
    SWITCH_ITEM2(LOC(@"Hide `Live Chat` Section"), LOC(@"App restart is required."), @"disableLiveChatSection_enabled");

    # pragma mark - UI interface options
    SECTION_HEADER(LOC(@"UI Interface Options"));

YTSettingsSectionItem *lowContrastMode = [YTSettingsSectionItemClass
    switchItemWithTitle:LOC(@"Low Contrast Mode")
    titleDescription:LOC(@"This will lower the contrast of texts and buttons, similar to the old YouTube Interface. App restart is required.")
    accessibilityIdentifier:nil
    switchOn:IS_ENABLED(@"lowContrastMode_enabled")
    switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
        if (enabled) {
            NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSComparisonResult result1 = [appVersion compare:@"17.33.2" options:NSNumericSearch];
            NSComparisonResult result2 = [appVersion compare:@"17.38.10" options:NSNumericSearch];
            if (result1 == NSOrderedAscending || result2 == NSOrderedDescending) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incompatibile" message:[NSString stringWithFormat:@"LowContrastMode is only available for app versions v17.33.2-v17.38.10. \nYou are currently using v%@. \n\nWorkaround: if you want to use this then I recommend enabling \"Fix LowContrastMode\" Option.", appVersion] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [settingsViewController presentViewController:alert animated:YES completion:nil];
                return NO;
            }
        }
        if (IS_ENABLED(@"fixLowContrastMode_enabled")) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"lowContrastMode_enabled"];
        }
        [settingsViewController reloadData];
        SHOW_RELAUNCH_YT_SNACKBAR;
        return YES;
    }
    settingItemId:0
];
[sectionItems addObject:lowContrastMode];
YTSettingsSectionItem *lowContrastModeButton = [%c(YTSettingsSectionItem)
    itemWithTitle:@"Low Contrast Mode Selector"
    accessibilityIdentifier:nil
    detailTextBlock:^NSString *() {
        switch (contrastMode()) {
            case 1:
                return LOC(@"Custom Color");
            case 0:
            default:
                return LOC(@"Default");
        }
    }
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        if (contrastMode() == 0) {
            NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incompatibile" message:[NSString stringWithFormat:@"LowContrastMode is only available for app versions v17.33.2-v17.38.10. \nYou are currently using v%@. \n\nWorkaround: if you want to use this then I recommend enabling \"Fix LowContrastMode\" Option.", appVersion] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [settingsViewController presentViewController:alert animated:YES completion:nil];
            return NO;
        } else {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"Default") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lcm"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"Custom Color") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"lcm"];
                    [settingsViewController reloadData];
                    return YES;
                }]

            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Low Contrast Mode Selector") pickerSectionTitle:nil rows:rows selectedItemIndex:contrastMode() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    }
];
[sectionItems addObject:lowContrastModeButton];
    SWITCH_ITEM2(LOC(@"Fix LowContrastMode"), LOC(@"This will fix the LowContrastMode functionality by Spoofing to YouTube v17.38.10. App restart is required."), @"fixLowContrastMode_enabled");
    SWITCH_ITEM2(LOC(@"Disable Modern Buttons"), LOC(@"This will remove the new Modern / Chip Buttons in the YouTube App. but not all of them. App restart is required."), @"disableModernButtons_enabled");
    SWITCH_ITEM2(LOC(@"Disable Rounded Corners on Hints"), LOC(@"This will make the Hints in the App to not have Rounded Corners. App restart is required."), @"disableRoundedHints_enabled");
    SWITCH_ITEM2(LOC(@"Disable Modern A/B Flags"), LOC(@"This will turn off any Modern Flag that was enabled by default. App restart is required."), @"disableModernFlags_enabled");
    SWITCH_ITEM2(LOC(@"Enable Specific UI Related Options (YTNoModernUI)"), LOC(@"When Enabled, this will enable other options to give it a less-modern feeling. App restart is required."), @"ytNoModernUI_enabled");
    SWITCH_ITEM2(LOC(@"Enable App Version Spoofer"), LOC(@"Enable this to use the Version Spoofer and select your perferred version below. App restart is required."), @"enableVersionSpoofer_enabled");
    YTSettingsSectionItem *versionSpoofer = [%c(YTSettingsSectionItem)
        itemWithTitle:@"Version spoofer picker"
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (appVersionSpoofer()) {
                case 1:
                    return @"v19.10.6";
                case 2:
                    return @"v19.10.5";
                case 3:
                    return @"v19.09.4";
                case 4:
                    return @"v19.09.3";
                case 5:
                    return @"v19.08.2";
                case 6:
                    return @"v19.07.5";
                case 7:
                    return @"v19.07.4";
                case 8:
                    return @"v19.06.2";
                case 9:
                    return @"v19.05.5";
                case 10:
                    return @"v19.05.3";
                case 11:
                    return @"v19.04.3";
                case 12:
                    return @"v19.03.2";
                case 13:
                    return @"v19.02.1";
                case 14:
                    return @"v19.01.1";
                case 15:
                    return @"v18.49.3";
                case 16:
                    return @"v18.48.3";
                case 17:
                    return @"v18.46.3";
                case 18:
                    return @"v18.45.2";
                case 19:
                    return @"v18.44.3";
                case 20:
                    return @"v18.43.4";
                case 21:
                    return @"v18.41.5";
                case 22:
                    return @"v18.41.3";
                case 23:
                    return @"v18.41.2";
                case 24:
                    return @"v18.40.1";
                case 25:
                    return @"v18.39.1";
                case 26:
                    return @"v18.38.2";
                case 27:
                    return @"v18.35.4";
                case 28:
                    return @"v18.34.5";
                case 29:
                    return @"v18.33.3";
                case 30:
                    return @"v18.33.2";
                case 31:
                    return @"v18.32.2";
                case 32:
                    return @"v18.31.3";
                case 33:
                    return @"v18.30.7";
                case 34:
                    return @"v18.30.6";
                case 35:
                    return @"v18.29.1";
                case 36:
                    return @"v18.28.3";
                case 37:
                    return @"v18.27.3";
                case 38:
                    return @"v18.25.1";
                case 39:
                    return @"v18.23.3";
                case 40:
                    return @"v18.22.9";
                case 41:
                    return @"v18.21.3";
                case 42:
                    return @"v18.20.3";
                case 43:
                    return @"v18.19.1";
                case 44:
                    return @"v18.18.2";
                case 45:
                    return @"v18.17.2";
                case 46:
                    return @"v18.16.2";
                case 47:
                    return @"v18.15.1";
                case 48:
                    return @"v18.14.1";
                case 49:
                    return @"v18.13.4";
                case 50:
                    return @"v18.12.2";
                case 51:
                    return @"v18.11.2";
                case 52:
                    return @"v18.10.1";
                case 53:
                    return @"v18.09.4";
                case 54:
                    return @"v18.08.1";
                case 55:
                    return @"v18.07.5";
                case 56:
                    return @"v18.05.2";
                case 57:
                    return @"v18.04.3";
                case 58:
                    return @"v18.03.3";
                case 59:
                    return @"v18.02.03";
                case 60:
                    return @"v18.01.6";
                case 61:
                    return @"v18.01.4";
                case 62:
                    return @"v18.01.2";
                case 63:
                    return @"v17.49.6";
                case 64:
                    return @"v17.49.4";
                case 65:
                    return @"v17.46.4";
                case 66:
                    return @"v17.45.1";
                case 67:
                    return @"v17.44.4";
                case 68:
                    return @"v17.43.1";
                case 69:
                    return @"v17.42.7";
                case 70:
                    return @"v17.42.6";
                case 71:
                    return @"v17.41.2";
                case 72:
                    return @"v17.40.5";
                case 73:
                    return @"v17.39.4";
                case 74:
                    return @"v17.38.10";
                case 75:
                    return @"v17.38.9";
                case 76:
                    return @"v17.37.2";
                case 77:
                    return @"v17.36.4";
                case 78:
                    return @"v17.36.3";
                case 79:
                    return @"v17.35.3";
                case 80:
                    return @"v17.34.3";
                case 81:
                    return @"v17.33.2";
                case 0:
                default:
                    return @"v19.10.7";
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.10.7" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.10.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.10.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.09.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.09.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.08.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.07.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.07.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:7 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.06.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:8 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.05.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:9 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.05.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.04.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:11 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.03.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:12 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.02.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:13 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.01.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:14 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.49.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:15 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.48.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:16 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.46.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:17 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.45.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:18 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.44.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:19 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.43.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:20 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.41.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:21 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.41.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:22 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.41.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:23 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.40.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:24 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.39.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:25 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.38.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:26 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.35.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:27 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.34.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:28 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.33.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:29 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.33.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:30 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.32.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:31 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.31.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:32 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.30.7" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:33 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.30.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:34 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.29.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:35 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.28.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:36 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.27.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:37 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.25.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:38 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.23.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:39 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.22.9" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:40 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.21.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:41 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.20.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:42 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.19.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:43 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.18.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:44 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.17.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:45 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.16.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:46 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;      
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.15.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:47 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.14.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:48 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.13.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:49 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.12.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:50 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.11.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:51 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.10.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:52 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.09.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:53 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.08.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:54 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.07.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:55 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.05.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:56 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.04.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:57 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.03.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:58 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.02.03" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:59 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:60 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:61 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:62 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.49.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:63 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.49.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:64 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.46.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:65 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.45.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:66 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.44.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:67 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.43.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:68 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.42.7" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:69 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.42.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:70 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.41.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:71 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.40.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:72 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.39.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:73 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.38.10" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:74 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.38.9" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:75 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.37.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:76 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.36.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:77 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.36.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:78 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.35.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:79 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.34.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:80 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.33.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:81 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Version Spoofer Picker") pickerSectionTitle:nil rows:rows selectedItemIndex:appVersionSpoofer() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];
    [sectionItems addObject:versionSpoofer];

    # pragma mark - Miscellaneous
    SECTION_HEADER(LOC(@"MISCELLANEOUS"));

    SWITCH_ITEM(LOC(@"YouTube Premium Logo"), LOC(@"Toggle this to use the official YouTube Premium Logo. App restart is required."), @"premiumYouTubeLogo_enabled");
//  SWITCH_ITEM(LOC(@"Center YouTube Logo"), LOC(@"Toggle this to move the official YouTube Logo to the Center. App restart is required."), @"centerYouTubeLogo_enabled");
    SWITCH_ITEM(LOC(@"Hide YouTube Logo"), LOC(@"Toggle this to hide the YouTube Logo in the YouTube App."), @"hideYouTubeLogo_enabled");
    SWITCH_ITEM2(LOC(@"ENABLE_YT_STARTUP_ANIMATION"), LOC(@"ENABLE_YT_STARTUP_ANIMATION_DESC"), @"ytStartupAnimation_enabled");
    SWITCH_ITEM(LOC(@"DISABLE_HINTS"), LOC(@"DISABLE_HINTS_DESC"), @"disableHints_enabled");
    SWITCH_ITEM(LOC(@"Stick Navigation Bar"), LOC(@"Enable to make the Navigation Bar stay on the App when scrolling."), @"stickNavigationBar_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_ISPONSORBLOCK"), nil, @"hideSponsorBlockButton_enabled");
    SWITCH_ITEM2(LOC(@"Hides uYouPlus button"), nil, @"hideuYouPlusButton_enabled");
    SWITCH_ITEM(LOC(@"HIDE_CHIP_BAR"), LOC(@"HIDE_CHIP_BAR_DESC"), @"hideChipBar_enabled");
    SWITCH_ITEM(LOC(@"HIDE_PLAY_NEXT_IN_QUEUE"), LOC(@"HIDE_PLAY_NEXT_IN_QUEUE_DESC"), @"hidePlayNextInQueue_enabled");
    SWITCH_ITEM2(LOC(@"Hide Community Posts"), LOC(@"Hides the Community Posts. App restart is required."), @"hideCommunityPosts_enabled");
    SWITCH_ITEM2(LOC(@"Hide Header Links under channel profile"), LOC(@"Hides the Header Links under any channel profile."), @"hideChannelHeaderLinks_enabled");
    SWITCH_ITEM2(LOC(@"Hide all videos under player"), LOC(@"Hides all videos below the player."), @"noRelatedWatchNexts_enabled");
    SWITCH_ITEM2(LOC(@"IPHONE_LAYOUT"), LOC(@"IPHONE_LAYOUT_DESC"), @"iPhoneLayout_enabled");
    SWITCH_ITEM2(LOC(@"NEW_MINIPLAYER_STYLE"), LOC(@"NEW_MINIPLAYER_STYLE_DESC"), @"bigYTMiniPlayer_enabled");
    SWITCH_ITEM2(LOC(@"YT_RE_EXPLORE"), LOC(@"YT_RE_EXPLORE_DESC"), @"reExplore_enabled");
    SWITCH_ITEM2(LOC(@"Hide Indicators"), LOC(@"Hides all Indicators that were in the App."), @"hideSubscriptionsNotificationBadge_enabled");
    SWITCH_ITEM(LOC(@"ENABLE_FLEX"), LOC(@"ENABLE_FLEX_DESC"), @"flex_enabled");

    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)])
        [settingsViewController setSectionItems:sectionItems forCategory:uYouPlusSection title:@"uYouEnhanced" icon:nil titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
    else
        [settingsViewController setSectionItems:sectionItems forCategory:uYouPlusSection title:@"uYouEnhanced" titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == uYouPlusSection) {
        [self updateTweakSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end
