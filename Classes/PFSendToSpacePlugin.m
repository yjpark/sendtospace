//  Created by YJ Park on 10/5/10.
//  Copyright 2010 PettyFun.com All rights reserved.
//

#import <ApplicationServices/ApplicationServices.h>

#import "PFSendToSpacePlugin.h"

static BOOL pf_send_to_space_in_progress;

@implementation NSWindow(PFSendToSpace)

- (void)pf_sendToSpace:(id)sender {
    if (pf_send_to_space_in_progress) return;
    pf_send_to_space_in_progress = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:PFSendToSpaceDelay1
                                     target:self
                                   selector:@selector(pf_sendToSpace2:)
                                   userInfo:((NSMenuItem *)sender).title
                                    repeats:NO];
}
    
- (void)pf_sendToSpace2:(NSTimer *)timer {
    NSWindowCollectionBehavior pf_saved_behavior = [self collectionBehavior];
    [self setCollectionBehavior:pf_saved_behavior | NSWindowCollectionBehaviorCanJoinAllSpaces];
    //move to target space
    NSString *title = (NSString *)timer.userInfo;
    NSString *ch = [title substringFromIndex:title.length - 1];

    int pf_target_space = 1;
    for (int i = 2; i <= 9; i++) {
        if ([ch isEqualToString:[NSString stringWithFormat:@"%d", i]]) {
            pf_target_space = i;
            break;
        }
    }
    
    NSLog(@"pf_PFSendToSpacePlugin pf_sendToSpace2: %d", pf_target_space);
    
    int keycode = 17;
    if (pf_target_space <= 4) {
        keycode = 17 + pf_target_space;
    } else if (pf_target_space == 5) {
        keycode = 23;
    } else if (pf_target_space == 6) {
        keycode = 22;
    } else if (pf_target_space == 7) {
        keycode = 26;
    } else if (pf_target_space == 8) {
        keycode = 28;
    } else if (pf_target_space == 9) {
        keycode = 25;
    }
    
    CGEventRef event1, event2;
    event1 = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)(keycode), true);
    event2 = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)(keycode), false);
    
    CGEventSetFlags(event1, kCGEventFlagMaskControl);
    //CGEventSetFlags(event2, kCGEventFlagMaskControl);
    
    CGEventPost(kCGHIDEventTap, event1);
    CGEventPost(kCGHIDEventTap, event2);
    [NSTimer scheduledTimerWithTimeInterval:PFSendToSpaceDelay2
                                     target:self
                                   selector:@selector(pf_sendToSpace3:)
                                   userInfo:[NSNumber numberWithInt:pf_saved_behavior]
                                    repeats:NO];
    NSLog(@"pf_PFSendToSpacePlugin pf_sendToSpace2: %d, %d", pf_target_space, pf_saved_behavior);
}

- (void)pf_sendToSpace3:(NSTimer *)timer {
    //restore states;
    int pf_saved_behavior = [(NSNumber *)timer.userInfo intValue];
    [self setCollectionBehavior:pf_saved_behavior];
    [self orderFront:nil];
    NSLog(@"pf_PFSendToSpacePlugin pf_sendToSpace3: %d", pf_saved_behavior);
    pf_send_to_space_in_progress = NO;
}

@end

@implementation PFSendToSpacePlugin

/**
 * A special method called by SIMBL once the application has started and all classes are initialized.
 */
+ (void)load {
	PFSendToSpacePlugin* plugin = [PFSendToSpacePlugin sharedInstance];

	NSLog(@"pf_PFSendToSpacePlugin loaded");

	NSError* err = nil;
        BOOL result = [plugin setupMenu];
	if (!result) {// we want this to be visible to end users, too :)
		NSLog(@"pf_PFSendToSpacePlugin install failed (error: %@).", err);
	} else {
		NSLog(@"pf_PFSendToSpacePlugin installed");
	}
}

/**
 * @return the single static instance of the plugin object
 */
+ (PFSendToSpacePlugin *)sharedInstance {
	static PFSendToSpacePlugin* plugin = nil;
	
	if (plugin == nil)
		plugin = [[PFSendToSpacePlugin alloc] init];
	
	return plugin;
}

#pragma mark - setup menu
- (NSUInteger) indexForInstallingInMenu:(NSMenu*) m {
	NSUInteger i = 0, lastSeparator = -1;
	for (NSMenuItem* item in [m itemArray]) {
		if ([item isSeparatorItem])
			lastSeparator = i;
		else if ([item action] == @selector(arrangeInFront:))
			return i + 1;
		
		i++;
	}
	
	if (lastSeparator != -1)
		return lastSeparator + 1;
	else
		return 0;
}

- (int)spaceNum {
    NSDictionary *dockPrefs = [[NSUserDefaults standardUserDefaults]
                               persistentDomainForName:@"com.apple.dock"];
    
    int rows = [[dockPrefs objectForKey:@"workspaces-rows"] intValue];
    int cols = [[dockPrefs objectForKey:@"workspaces-cols"] intValue];
    int result = MIN(9, rows * cols);
    result = MAX(result, 1);
    return result;
}

- (BOOL)setupMenu {
	NSMenu* menu = [NSApp windowsMenu];
	if (!menu) {
		NSLog(@"pf_PFSendToSpacePlugin setupMenu: %@ found no Window menu in NSApp %@", self, NSApp);
		return NO;
	}
	
	NSUInteger index = [self indexForInstallingInMenu:menu];
	
	if (index < [menu numberOfItems] && ![[menu itemAtIndex:index] isSeparatorItem])
		[menu insertItem:[NSMenuItem separatorItem] atIndex:index];
    
    int spaceNum = [self spaceNum];
    if (spaceNum <= 1) {
		NSLog(@"pf_PFSendToSpacePlugin setupMenu: %@ seems spaces is not enabled %d", self, spaceNum);
		return NO;
    }
    
	for (int i = spaceNum; i > 0; i--) {
        NSString *title = [NSString stringWithFormat:@"Send to Space %d", i];
        NSString *shortcut = [NSString stringWithFormat:@"%d", i];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(pf_sendToSpace:) keyEquivalent:shortcut];
        [item setKeyEquivalentModifierMask:NSControlKeyMask | NSShiftKeyMask];
        [item setEnabled:YES];
        
		[menu insertItem:item atIndex:index];
	}
    
	if (index < [menu numberOfItems] && ![[menu itemAtIndex:index] isSeparatorItem])
		[menu insertItem:[NSMenuItem separatorItem] atIndex:index];
    
    return YES;
}

@end
