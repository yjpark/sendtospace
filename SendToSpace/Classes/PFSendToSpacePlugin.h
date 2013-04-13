//  Created by YJ Park on 10/5/10.
//  Copyright 2010 PettyFun.com All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define PFSendToSpaceDelay1 0.8f
#define PFSendToSpaceDelay2 0.5f

@interface NSWindow(PFSendToSpace)
- (void)pf_sendToSpace:(id)sender;
@end

@interface PFSendToSpacePlugin : NSObject {

}

+ (void)load;
+ (PFSendToSpacePlugin*)sharedInstance;

- (BOOL)setupMenu;

@end
