//
//  Tab.m
//  Browser
//
//  Created by Ronan Moynihan on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Tab.h"


@implementation Tab

@synthesize favIcon;
@synthesize tag;
@synthesize pageScreenShot;
@synthesize url;
@synthesize title;

- (id)init
{
		if(self = [super init])
		{
			
			
		}
	
	return self;
	
}

-(void)dealloc
{
	[pageScreenShot release];
	[favIcon release];
	[url release];
	[title release];

	[super dealloc];
}

@end
