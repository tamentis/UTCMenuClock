//
//  UTCMenuClockAppDelegate.m
//  UTCMenuClock
//
//  Created by John Adams on 11/14/11.
//
// Copyright 2011 John Adams
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "UTCMenuClockAppDelegate.h"
#import "LaunchAtLoginController.h"

@implementation UTCMenuClockAppDelegate

@synthesize window;
@synthesize mainMenu;

NSStatusItem *ourStatus;
NSMenuItem *dateMenuItem;
NSMenuItem *showTimeZoneItem;

- (void) quitProgram:(id)sender {
    // Cleanup here if necessary...
    [[NSApplication sharedApplication] terminate:nil];
}

- (void) toggleLaunch:(id)sender {
    NSInteger state = [sender state];
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];

    if (state == NSOffState) {
        [sender setState:NSOnState];
        [launchController setLaunchAtLogin:YES];
    } else {
        [sender setState:NSOffState];
        [launchController setLaunchAtLogin:NO];
    }

    [launchController release];
}

- (BOOL) fetchBooleanPreference:(NSString *)preference {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [standardUserDefaults boolForKey:preference];
    return value;
}

- (void) togglePreference:(id)sender {
    NSInteger state = [sender state];
    NSString *preference = [sender title];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    preference = [preference stringByReplacingOccurrencesOfString:@" "
                                                withString:@""];
    if (state == NSOffState) {
        [sender setState:NSOnState];
        [standardUserDefaults setBool:TRUE forKey:preference];
    } else {
        [sender setState:NSOffState];
        [standardUserDefaults setBool:FALSE forKey:preference];
    }

}


- (void) doDateUpdate {

    NSDate* date1 = [NSDate date];
    NSDate* date2 = [NSDate date];
    NSDateFormatter* df1 = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* df2 = [[[NSDateFormatter alloc] init] autorelease];

    NSTimeZone* tz1 = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* tz2 = [NSTimeZone timeZoneWithName:@"Europe/Paris"];

    [df1 setTimeZone: tz1];
    [df1 setDateFormat: @"HH:mm"];
    [df2 setTimeZone: tz2];
    [df2 setDateFormat: @"HH:mm"];

    NSString* UTCtimepart1 = [df1 stringFromDate: date1];
    NSString* UTCtimepart2 = [df2 stringFromDate: date2];

    [ourStatus setTitle:[NSString stringWithFormat:@"%@ UTC  %@ CET", UTCtimepart1, UTCtimepart2]];
}

// this is the main work loop, fired on 60s intervals.
- (void) fireTimer:(NSTimer*)theTimer {
    [self doDateUpdate];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // set our default preferences if they've never been set before.
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *dateKey    = @"dateKey";
    NSDate *lastRead    = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:dateKey];
    if (lastRead == nil)     // App first run: set up user defaults.
    {
        NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], dateKey, nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateKey];

        [standardUserDefaults setBool:TRUE forKey:@"ShowTimeZone"];
        [showTimeZoneItem setState:NSOnState];
    }    
    [self doDateUpdate];

}

- (void)awakeFromNib
{
    mainMenu = [[NSMenu alloc] init];

    //Create Image for menu item
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    NSStatusItem *theItem;
    theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [theItem retain];
    // retain a reference to the item so we don't have to find it again
    ourStatus = theItem;

    //Set Image
    //[theItem setImage:(NSImage *)menuicon];
    [theItem setTitle:@""];

    //Make it turn blue when you click on it
    [theItem setHighlightMode:YES];
    [theItem setEnabled: YES];

    // build the menu
    NSMenuItem *mainItem = [[NSMenuItem alloc] init];
    dateMenuItem = mainItem;

    NSMenuItem *quitItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *launchItem = [[[NSMenuItem alloc] init] autorelease];

    showTimeZoneItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *sepItem = [NSMenuItem separatorItem];

    [mainItem setTitle:@""];

    [launchItem setTitle:@"Open at Login"];
    [launchItem setEnabled:TRUE];
    [launchItem setAction:@selector(toggleLaunch:)];

    [quitItem setTitle:@"Quit"];
    [quitItem setEnabled:TRUE];
    [quitItem setAction:@selector(quitProgram:)];

    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launch = [launchController launchAtLogin];
    [launchController release];

    if (launch) {
        [launchItem setState:NSOnState];
    } else {
        [launchItem setState:NSOffState];
    }

    [mainMenu addItem:launchItem];
    [mainMenu addItem:sepItem];
    [mainMenu addItem:quitItem];

    [theItem setMenu:(NSMenu *)mainMenu];

    // Update the date immediately after setup so that there is no timer lag
    [self doDateUpdate];

    NSNumber *myInt = [NSNumber numberWithInt:1];
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(fireTimer:) userInfo:myInt repeats:YES];


}

@end
