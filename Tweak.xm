NSString *const PREF_PATH = @"/var/mobile/Library/Preferences/com.cabralcole.appswitcher7.plist";
CFStringRef const PreferencesNotification = CFSTR("com.cabralcole.appswitcher7.prefs");


static BOOL tweakEnabled;

%hook SBAppSwitcherSettings

- (void)setSwitcherStyle:(NSInteger)arg1
{
	if (tweakEnabled) {
		arg1 = 0; // iOS 7/8 style
	}
	%orig;
}
%end

BOOL is_springboard() // Thanks PoomSmart, not sure if needed but just incase
{
	NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
	NSUInteger count = args.count;
	if (count != 0) {
		NSString *executablePath = args[0];
		return [[executablePath lastPathComponent] isEqualToString:@"springboard"];
	}
	return NO;
}

static void AppSwitcherPrefs()
{
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	tweakEnabled = [prefs[@"AppSwitcherEnabled"] boolValue];
}

static void PostNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	system("killall -9 SpringBoard");
	AppSwitcherPrefs();
}

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (!is_springboard())
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PostNotification, PreferencesNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
		AppSwitcherPrefs();
		%init;
	[pool drain];
}