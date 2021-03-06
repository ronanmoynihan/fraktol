//
//  BrowserViewController.m
//  Browser
//
//  Created by Ronan Moynihan on 10/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BrowserViewController.h"
#import "TabItemViewController.h"
#import "QuartzCore/QuartzCore.h"



@implementation BrowserViewController

@synthesize popoverController;
@synthesize bookmarkPopoverController;
@synthesize detailItem;




/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	   
	return YES;
}
	



// Alert the user as the page failed to load
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	
	[spinnerView stopAnimating];
	
	
	if ([error code] != -999){
		
		NSString *urlString = [addressBar text];
		
		if ( [urlString rangeOfString:@"http://www."].location == NSNotFound ) {
			/*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error loading web page" 
																message:@"Could not load the web page requested. Try adding add 'wwww' to the URL and try again."
															   delegate:nil
													  cancelButtonTitle:nil
													  otherButtonTitles:@"OK", nil];
			
			
			
			[alertView show];
			[alertView release];*/
			
			urlString = [urlString stringByReplacingOccurrencesOfString:@"http://" withString:@"http://www."];
			addressBar.text = urlString;
			[self loadWebPageWithString:urlString];
						
			
		}
		else{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error loading web page" 
														message:[error localizedDescription]
												delegate:nil
											    cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		
			
			
			[alertView show];
			[alertView release];
		}
		
	
	
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	
	[self SetAutoResizeMaskForWebViews];
	
		
}


- (void)ShowHistoryPopover
{
	
	//if(addressBar.editing == YES)
	{
		if([popoverController isPopoverVisible] == NO)
		{
			
			if([historyList count] > 0)
			{
				HistoryViewController *movies = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:[NSBundle mainBundle]]; 
				
				UIPopoverController *popover = 
				[[UIPopoverController alloc] initWithContentViewController:movies]; 
				
				
				popover.delegate = self;
				[movies release];
				
				self.popoverController = popover;
				[popover release];
				
				
				CGRect popoverRect = [self.view convertRect:[addressBar frame] 
												   fromView:[addressBar superview]];
				
				popoverRect.size.width = MIN(popoverRect.size.width, 100); 
				[self.popoverController 
				 presentPopoverFromRect:popoverRect 
				 inView:self.view 
				 permittedArrowDirections:UIPopoverArrowDirectionAny 
				 animated:YES];
			}
			
			//[addressBar resignFirstResponder];
		}
		
	}
	
	[addressBar becomeFirstResponder];
}


- (void)textFieldDidChange:(id)sender
{
	@try{
		
		[self ShowHistoryPopover];
	}
	
	@catch (NSException* ex) {
		
	}
	
	
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	@try{
					
		[[bookmarkPageButton layer] setCornerRadius:8.0f];
		[[bookmarkView layer] setCornerRadius:4.0f];
		//bookmarkPageButton.backgroundColor = [UIColor colorWithRed:0.132016 green:0.60205 blue:0.88579 alpha:1].CGColor;

				
		
	
		[addressBar addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];


		[favIconView.layer setCornerRadius:4.0f];
		
			
		tabList = [[NSMutableDictionary alloc] init];
		
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		bookmarkList = [prefs dictionaryForKey:@"fraktol_bookmark_list"];
		if(bookmarkList== nil)
		{
			bookmarkList = [[NSMutableDictionary alloc] init];	
		}
		
		
		
		historyList = [prefs dictionaryForKey:@"fraktol_history_list"];
		
		if(historyList== nil)
		{
			historyList = [[NSMutableDictionary alloc] init];	
		}
		
		
		tabCount = 100;
		
		NSString *startPage = [prefs stringForKey:@"fraktol_startpage"];
		
		
		if(startPage == nil)
		{
			addressBar.text = @"Enter Web Address";
			startPage = @"http://www.google.com";
			
			[prefs setValue:startPage forKey:@"fraktol_startpage"];
			[self CreateNewWebView:startPage];
		}
		else{
			startPage = [self fixUrl:startPage];
			
			[self CreateNewWebView:startPage];
		}
		

		
		[self UpdateRefreshStopButttons];
		
		
	}
	
	@catch (NSException* ex) {
		
	}
	
	
    [super viewDidLoad];
	
		
}


	/*
	/Add http to the URL if it does not already have http or https
	*/
- (NSString*)fixUrl:(NSString *)url 
{
	if ( [url rangeOfString:@"https://"].location == NSNotFound ) {
		
		if ( [url rangeOfString:@"http://"].location == NSNotFound ) {
			url = [NSString stringWithFormat:@"%@%@",@"http://",url];
		}
	}
	
	return url;
}


// Start loading a new web page
- (void)loadWebPageWithString:(NSString *)urlString
{
	urlString = [self fixUrl:urlString];

	for (UIWebView *webView in mainView.subviews)
    {
		if (webView.tag == currentWebViewTag) {
			NSURL	*url = [NSURL URLWithString:urlString];
			NSURLRequest *request = [NSURLRequest requestWithURL:url];
		
			
			[webView loadRequest:request];
 		}
      
    }
	if(addressBar.editing == NO)
	{
		addressBar.text = urlString;
	}
}	

- (void)EnableBackForwardButtons
{
	for (UIWebView *webView in mainView.subviews)
    {
		if (webView.tag == currentWebViewTag) {
			
			if(webView.canGoBack == YES)
			{
				[backButton setEnabled: YES];
			}
			else {
				[backButton setEnabled: NO];
			}
			
			if(webView.canGoForward == YES)
			{
				[forwardButton setEnabled: YES];
			}
			else {
				[forwardButton setEnabled: NO];
			}

 		}
		
    }
}

- (NSString*)TabNibName{
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		return @"TabItemViewController";
	}
	else{
		return @"TabItemViewController-iPhone";

	}
	
}

- (int)DistanceBetweenTabs{
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		return 185;
	}
	else{
		return 105;
		
	}
	
}
		

- (void)RefreshTabListView
{
	@try{
		
	
	for (UIView *subview in tabScrollView.subviews) {
		[subview removeFromSuperview];
	}
		
	int c = [tabList count];
	[tabCountLabel setText:[NSString stringWithFormat:@"%i",c]];
	if(c == 9)
	{
		[newTabButton setEnabled:NO];
	}
	else {
		[newTabButton setEnabled:YES];
	}
		
	
	NSInteger x = 0;

		
	NSArray *keys = [tabList allKeys];
	NSArray *sortedArray = [keys sortedArrayUsingSelector:@selector(compare:)];
		
	for(NSString *key in sortedArray)
	{
		Tab *tab = [tabList valueForKey:key];	
		TabItemViewController *viewController = [[TabItemViewController alloc] initWithNibName:[self TabNibName] bundle:[NSBundle mainBundle]];

		
		BOOL isFirstView = NO;
		for (UIView *sub in [viewController.view subviews]) {
			sub.frame = CGRectMake(x,0,sub.frame.size.width,sub.frame.size.height);
			
			
			if(tab.tag == currentWebViewTag)
			{
				sub.layer.borderColor = [UIColor colorWithRed:0.132016 green:0.60205 blue:0.88579 alpha:1].CGColor;
				sub.layer.borderWidth = 1.0f;
				
				if(addressBar.editing == NO)
				{
					addressBar.text = tab.url;
				}
				webPageTitle.text = tab.title;
				mainFavIcon.image = tab.favIcon;
				
				[self EnableBackForwardButtons];
				
			}
			
			if(isFirstView == NO)
			{
				
				[[sub layer] setCornerRadius:4.0f];
				isFirstView == YES;
			}	
		
			for(UIView *b in sub.subviews){
						 
								
				if([b isKindOfClass:[UIButton class]]) {
				
					UIButton *btn = (UIButton *)b;
					if(btn.tag == 5)
					{
						if(tab.pageScreenShot==nil){
							b.backgroundColor = [UIColor whiteColor];  //nil;
							[b.layer setCornerRadius:4.0f];
						}
						else{
							[b setBackgroundImage:tab.pageScreenShot forState:UIControlStateNormal];
							[b.layer setCornerRadius:4.0f];

						}
					}
					if(btn.tag == 11)
					{
						[btn addTarget:self action:@selector(tabCloseButtonTapped:) forControlEvents:UIControlEventTouchDown];
						btn.superview.tag =tab.tag;
					}
					else if(btn.tag!=11){
						
						btn.superview.tag =tab.tag;

						[btn addTarget:self action:@selector(tabPageItemTapped:) forControlEvents:UIControlEventTouchDown];
						
					}			  
				}
				else if([b isKindOfClass:[UILabel class]]) {
					UILabel *l = (UILabel *)b;
					if(tab.title == NULL)
					{
						l.text = tab.url;
					}
					else{
						l.text = tab.title;
					}
				}
	
				[tabScrollView addSubview:sub];	
			}	
			
		}
		
		[viewController release];
		x += [self DistanceBetweenTabs];
	
	}

	[tabScrollView setContentSize:CGSizeMake(x,tabScrollView.bounds.size.height)];
		
	}

    @catch (NSException* ex) {
	
    }
 

}



-(IBAction)showAddBookmarkPopup
{
	@try{
		
		Tab *tab = [tabList valueForKey:currentWebViewTag];
		// Add the Tab to the Dictionay of Tabs
		if([bookmarkList objectForKey:tab.title] == nil)
		{
			[bookmarkList setValue:tab.url forKey:tab.title];
		}
		
		
		
		
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:bookmarkList forKey:@"fraktol_bookmark_list"];
	
	}
	@catch (NSException* ex) {
		
	}
	
}
		
		
		


 // TODO *********************************************************************
 // When a close button is pressed - set the first Tab to be the currrent one.
 // This is a mess the way it is.
 // TODO *********************************************************************
-(IBAction)tabCloseButtonTapped:sender
{
	@try{
		
		int c = [tabList count];
		if(c==1)
		{
				// Do not close last tab.
		}
		else {
						
			UIButton *b = (UIButton *)sender;
			
			// Adjust number of webviews loading in case closed tab was actually loading
					   
				NSString *key;
				for (id obj in [tabList allKeys])
				{
					if (b.superview.tag == obj)
					{
						key = obj;	
					}
					
				}
			
			Tab *tab = [tabList valueForKey:key];
			[tabList removeObjectForKey:key];
			
			[tab release];
			
			for (UIWebView *webView in mainView.subviews)
			{
				
				if (webView.tag == key) {
					[webView removeFromSuperview];
					
				}
			}
			
				// Set the new current Tab
				if(key==currentWebViewTag)
				{
					if([tabList count]==0)
					{
						// Set it to null as the last tab is being closed.
						currentWebViewTag = NULL;
						mainFavIcon.image = NULL;
						webPageTitle.text = @"";
						addressBar.text = @"";
						
					}
					else{
						
						NSArray *keys = [tabList allKeys];
						NSArray *sortedArray = [keys sortedArrayUsingSelector:@selector(compare:)];
						// set the tab to the first one

						NSString *nearestKey = [sortedArray objectAtIndex:0];
						
						
						currentWebViewTag = nearestKey;
						
						
						for (UIWebView *webView in mainView.subviews)
						{
							
								if (webView.tag == nearestKey) {
									
									[mainView bringSubviewToFront:webView];
									webView.hidden = NO;

								}
						}
						
					}
					
				}
					
			[self RefreshTabListView];
			
			[spinnerView stopAnimating];
			for(UIWebView *webView in mainView.subviews)
			{
				if(webView.loading == YES)
				{
				
					[spinnerView startAnimating];
				}	
			 
			 }
		}		
	
		
		[self SetAutoResizeMaskForWebViews];
	
	}
	@catch (NSException* ex) {
	
	}

	
	
 }
  

-(IBAction)refreshStopClicked
{
	@try{	
		if(RefreshButton.tag == 0)
		{
			for (UIWebView *webView in mainView.subviews)
			{
				if (webView.tag == currentWebViewTag) {
					[webView reload];
					[RefreshButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
					
				}
			}		
		}
		else {
			
			for (UIWebView *webView in mainView.subviews)
			{
				if (webView.tag == currentWebViewTag) {
					
					[webView stopLoading]; 
					RefreshButton.tag = 0;
					[RefreshButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
					
				}
			}
		}
	}
	
    @catch (NSException* ex) {
		
    }
	
	
	//[self UpdateRefreshStopButttons];

	
}
	


-(IBAction)goBack:sender
{	
	@try{
		for (UIWebView *webView in mainView.subviews)
		{
			if (webView.tag == currentWebViewTag) {
				[webView goBack];
			}
			
		}
	}
	@catch (NSException* ex) {
	
	}

	
}

-(IBAction)goForward:sender
{	
	@try{
		for (UIWebView *webView in mainView.subviews)
		{
			if (webView.tag == currentWebViewTag) {
				[webView goForward];
			}
			
		}
	}	
    @catch (NSException* ex) {
		
    }
	
}

-(void)UpdateRefreshStopButttons
{
	for(UIWebView *webView in mainView.subviews)
	{
		if(webView.tag == currentWebViewTag)
		{
			if(webView.loading ==YES)
			{
				[RefreshButton setImage:[UIImage imageNamed:@"cross_17.png"] forState:UIControlStateNormal];
				RefreshButton.tag = 1;
				[spinnerView startAnimating];
				
			}
			else {
				[RefreshButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
				RefreshButton.tag = 0;
				//[spinnerView stopAnimating];
				
			}
		}
	}
	
}

-(IBAction)tabPageItemTapped:sender
{	
	[addressBar resignFirstResponder];

	
	UIButton *b = (UIButton *)sender;
	
	
	for (UIWebView *webView in mainView.subviews)
    {
		
		if (webView.tag == b.superview.tag) {
			[mainView bringSubviewToFront:webView];
			addressBar.text =webView.request.URL.absoluteString;
			webPageTitle.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
			
			// Set the address bat to addressBar.text = @"Enter Web Adress" if no web page
 		}
    }
	
	currentWebViewTag = b.superview.tag;	
	
	[self SetAutoResizeMaskForWebViews];
	[self RefreshTabListView];
	
	
	[self UpdateRefreshStopButttons];
	
	
}


- (IBAction)addressBarEditingDidEnd{
	@try{
		[addressBar resignFirstResponder];
		[popoverController dismissPopoverAnimated:NO];
		
	}
	
	@catch (NSException* ex) {
		
	}
	
}


- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {

	[addressBar resignFirstResponder];
	
    return YES;
	
}




- (IBAction)settingsTapped{
	
	
	@try{
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Settings"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Clear History",nil];
		[actionSheet showInView:mainView];
	

		[actionSheet release];
	
	}

	@catch (NSException* ex) {
	
	}

}



- (IBAction)goButtonClicked{
	
	@try{
		
		
	
		[popoverController dismissPopoverAnimated:YES];
		NSString *url = [addressBar text];
		
		[self loadWebPageWithString:url];
		
		[addressBar resignFirstResponder];
		[self RefreshTabListView];
		
		addressBar.text = url;
	
	}

	@catch (NSException* ex) {
	
	}

	
	
}


// Slide in or hide the list of current open Tabs
- (IBAction)showHideTabButtonTapped{
	
	
	if(showHideTabButton.tag == 1)
	{
		[self hideModal:tabView];
		showHideTabButton.tag = 0;
		[showHideTabButton setImage:[UIImage imageNamed:@"tabup_25.png"] forState:UIControlStateNormal];
	}
	else if(showHideTabButton.tag == 0)
	{
		[self showModal:tabView];
		showHideTabButton.tag = 1;
		[showHideTabButton setImage:[UIImage imageNamed:@"tabdown_25.png"] forState:UIControlStateNormal];
		
	}
	
	[self SetAutoResizeMaskForWebViews];
	
}


// Slide in or hide the list of current open Tabs
- (IBAction)showHideBookmarksButtonTapped{
	
	
	BookmarkViewController *bookmarks = [[BookmarkViewController alloc] initWithNibName:@"BookmarkViewController" bundle:[NSBundle mainBundle]]; 
	
	UIPopoverController *popover = 
	[[UIPopoverController alloc] initWithContentViewController:bookmarks]; 
	
	
	popover.delegate = self;
	[bookmarks release];
	
	self.popoverController = popover;
	[popover release];
	
	
	CGRect popoverRect = [self.view convertRect:[showHideBookmarksButton frame] 
									   fromView:[showHideBookmarksButton superview]];
	
	popoverRect.size.width = MIN(popoverRect.size.width, 100); 
	[self.popoverController 
	 presentPopoverFromRect:popoverRect 
	 inView:self.view
	 permittedArrowDirections:UIPopoverArrowDirectionUp
	 animated:YES];
	
}

- (IBAction)fraktolButtonTapped{
	
	[self CreateNewWebView:@"http://www.fraktol.com"];
	
}

- (IBAction)addressBarEditing:(id)sender{


	if([addressBar.text rangeOfString:@"Enter Web Address"].location != NSNotFound)
	{
		addressBar.text = @"";
	}	
	
}



- (void)setDetailItem:(id)newDetailItem {
	  
	@try{
		[detailItem release];
        detailItem = [newDetailItem retain];

        addressBar.text = [detailItem description];
		[addressBar resignFirstResponder];
	    [self loadWebPageWithString:addressBar.text];
    
        [popoverController dismissPopoverAnimated:YES];
	}
	@catch (NSException* ex) {
	
	}

	
}


- (IBAction)newTabButtonClicked{
	
	@try{
		
		[self CreateNewWebView:NULL];
		
		addressBar.text = @"Enter Web Address";
		[addressBar resignFirstResponder];
		
		[self UpdateRefreshStopButttons];
		
		[self ShowHistoryPopover];
		
		
	}
	
	@catch (NSException* ex) {
		
	}
	
	
}



- (IBAction)bookmarkButtonTapped{
	
	@try{
		
		Tab *tab = [tabList valueForKey:currentWebViewTag];
		// Add the Tab to the Dictionay of Tabs
		[bookmarkList setValue:tab.title forKey:tab.url];

		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:bookmarkList forKey:@"fraktol_bookmark_list"];
		
		//[self RefreshBookmarkListView];

	}

		@catch (NSException* ex) {
	
	}

		
}

-(void)SetAutoResizeMaskForWebViews
{
	
	for (UIWebView *webView in mainView.subviews)
    {
		if (webView.tag == currentWebViewTag) {
			webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			webView.contentMode = UIViewContentModeScaleToFill;
			webView.scalesPageToFit = YES;
			webView.hidden = NO;
			//webView.bounds = mainView.bounds;
			//mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			//mainView.autoresizesSubviews = YES;
			
			CGRect frame = webView.frame;
			frame.size.width = mainView.bounds.size.width;
			frame.size.height = mainView.bounds.size.height;
			webView.frame = frame;
			 
			
			
		}
		else{
			webView.autoresizingMask = UIViewAutoresizingNone;
			webView.hidden = YES;

		}
    }
	
}


-(void)CreateNewWebView:(NSString *)urlString
{
	for (UIWebView *webView in mainView.subviews)
    {
		webView.autoresizingMask = UIViewAutoresizingNone;
	}
	
	UIWebView *webViewTemp = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, mainView.bounds.size.width, mainView.bounds.size.height)];
	webViewTemp.delegate = self;
	webViewTemp.contentMode = UIViewContentModeScaleToFill;
	webViewTemp.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	
	/*UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TwoTouchTapEvent:)]; 
	tap1.numberOfTouchesRequired = 2;
	tap1.numberOfTapsRequired = 1; 
	tap1.delegate = self; 
	[webViewTemp addGestureRecognizer:tap1];
	[tap1 release];
	
	UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TwoTouchTapEvent:)]; 
	tap2.numberOfTouchesRequired = 3;
	tap2.numberOfTapsRequired = 1; 
	tap2.delegate = self; 
	[webViewTemp addGestureRecognizer:tap2];
	[tap2 release];*/
	
		//webViewTemp.bounds = mainView.bounds;
	
	
	
	// Create a new Tab object
	Tab *newTab = [[Tab alloc]init];
	
	
	newTab.url = urlString;
	
	if(urlString !=NULL)
	{
		NSURL	*url = [NSURL URLWithString:urlString];
		
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		[webViewTemp loadRequest:request];
		//newTab.url = url;
		//addressBar.text = url;
	}
	else {
		newTab.title = @"Untitled";
	}

	webViewTemp.scalesPageToFit = YES;
	
	
	
	//NSValue *webViewValue = [NSValue valueWithPointer:webViewTemp];
	//NSString *key  = [NSString stringWithFormat:@"%@",webViewValue];

	tabCount = tabCount + 1;
	//NSString *key  = [NSString stringWithFormat:@"%i",tabCount];
	NSString *key = [NSString stringWithFormat:@"%i",tabCount];
		
	webViewTemp.tag =key;
	
	[newTab setTag:key];
	currentWebViewTag = key;
	
	// Add the Tab to the Dictionay of Tabs
	[tabList setValue:newTab forKey:key];
	
	
	// Add the webview to the Main View
	[mainView addSubview:webViewTemp];  
	
	
	mainView.autoresizesSubviews = YES;
	//[mainView bringSubviewToFront:tabView];
	
	[webViewTemp release];

	[self RefreshTabListView];
	
}


- (void) TwoTouchTapEvent:(UILongPressGestureRecognizer *)sender { //Do Stuff }
	
	
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	return YES;
}

- (UIImage*)screenshot:(UIWebView*) webView 
{
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	webView.contentMode = UIViewContentModeScaleToFill;
	webView.scalesPageToFit = YES;
	webView.hidden = NO;
	//webView.bounds = mainView.bounds;
	//mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	//mainView.autoresizesSubviews = YES;
	
	CGRect frame = webView.frame;
	frame.size.width = mainView.bounds.size.width;
	frame.size.height = mainView.bounds.size.height;
	webView.frame = frame;
	
	
	
	int width = 146;//117;//146;
	int height = 87;//70;// 87;
	if(webView.hidden == YES){
		webView.hidden == NO;
	}
	CGSize pageSize = CGSizeMake(self.view.bounds.size.width,self.view.bounds.size.height);
	//CGSize pageSize = CGSizeMake(600, 250);

    UIGraphicsBeginImageContext(pageSize);
	
	[webView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();
	
	CGRect subFrame = CGRectMake(120, 50, width * 2,height * 2); 
	CGImageRef subImageRef = CGImageCreateWithImageInRect(viewImage.CGImage, subFrame);
	UIImage *subViewImage = [UIImage imageWithCGImage:subImageRef];
	
	[subImageRef release];
	[self SetAutoResizeMaskForWebViews];
	
	return subViewImage;
}


-(void) showBookmarks:(UIView*) modalView { 
	
	CGPoint middleCenter = bookmarkView.center;  
	middleCenter.x = middleCenter.x - bookmarkView.bounds.size.width;
	
	
	// Show it with a transition effect    
	[UIView beginAnimations:nil context:nil];  
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.7]; 
	// animation duration in seconds   
	bookmarkView.center = middleCenter;
	
	
	[UIView commitAnimations]; 
	
}

- (void) hideBookmarks:(UIView*) modalView
{  
	
	
	CGPoint offScreenCenter = bookmarkView.center;    
	offScreenCenter.x = offScreenCenter.x  + bookmarkView.bounds.size.width;
	
	// Show it with a transition effect    
	[UIView beginAnimations:nil context:nil]; 
	
	
	[UIView setAnimationDuration:0.7]; 
	[UIView setAnimationDelegate:self];
	// animation duration in seconds   
	bookmarkView.center = offScreenCenter;
	
	[UIView commitAnimations]; 
	
} 



-(void) showModal:(UIView*) modalView { 

	CGPoint middleCenter = mainView.center;  
	middleCenter.y = middleCenter.y - 115;
	
	
	// Show it with a transition effect    
	[UIView beginAnimations:nil context:nil];  
	[UIView setAnimationDidStopSelector:@selector(showModalEnded:finished:context:)];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.7]; 
	// animation duration in seconds   
	mainView.center = middleCenter;
		

	[UIView commitAnimations]; 
	
}

- (void) showModalEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{  

	CGSize newSize = mainView.bounds.size;
	newSize.height += 115;
	
	[mainView setFrame:CGRectMake(mainView.frame.origin.x, 
								  mainView.frame.origin.y,newSize.width,newSize.height)];	
}

 - (void) hideModal:(UIView*) modalView
{  
 
	
	CGPoint offScreenCenter = mainView.center;    
	offScreenCenter.y = offScreenCenter.y  + 115;
	
	// Show it with a transition effect    
	[UIView beginAnimations:nil context:nil]; 

	
	[UIView setAnimationDuration:0.7]; 
	[UIView setAnimationDidStopSelector:@selector(hideModalEnded:finished:context:)];
	[UIView setAnimationDelegate:self];
	// animation duration in seconds   
	mainView.center = offScreenCenter;

	[UIView commitAnimations]; 
	
} 


- (void) hideModalEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{  


	CGSize newSize = mainView.bounds.size;
	newSize.height -= 115;
	
	[mainView setFrame:CGRectMake(mainView.frame.origin.x, 
								  mainView.frame.origin.y,newSize.width,newSize.height)];
	
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex :(NSInteger)buttonIndex
{
	@try{
		if(buttonIndex ==0)
		{
			[self CleanUpHistoryList];
			
			[historyList removeAllObjects];
			
			NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			[prefs setObject:historyList forKey:@"fraktol_history_list" ];	
		}
	}
	
	@catch (NSException* ex) {
		
	}	
	
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	@try{
	
		if(webView.loading == NO)
		{
			// Modify any links with target set to _blank
			// *** This appears to be resolved in 4.2 -link just opens in same window
			//NSString *path = [[NSBundle mainBundle] pathForResource:@"ModifyLinkTargets" ofType:@"js"];
			//NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
			
			//[webView stringByEvaluatingJavaScriptFromString:jsCode];
			
			//[webView stringByEvaluatingJavaScriptFromString:@"MyIPhoneApp_ModifyLinkTargets()"];
			
		
			
			NSURL *url1 = webView.request.URL;
			NSString *string = [NSString stringWithFormat:@"%@%@%@",@"http://", url1.host, @"/favicon.ico"];
			
			NSURL *url = [NSURL URLWithString:string];
			NSData *data = [NSData dataWithContentsOfURL:url];
			UIImage *img = [[UIImage alloc] initWithData:data];
			
			
			NSString *key  = [NSString stringWithFormat:@"%@",webView.tag];
			
			Tab *t = [tabList valueForKey:key];
			t.url = webView.request.URL.absoluteString;
			t.title =[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
			t.favIcon = img;
			[img release];
		
			t.pageScreenShot = [self screenshot:webView];

			
			if(t.tag == currentWebViewTag)
			{ 
				webPageTitle.text = t.title;
				mainFavIcon.image = t.favIcon;
				
				if(addressBar.editing == NO)
				{
					addressBar.text =webView.request.URL.absoluteString;
				}
				
			}

		
			[self RefreshTabListView];
			 
			
			NSDate *urlHost = [historyList objectForKey:webView.request.URL.host];
			
			
			if(urlHost==nil)
			{
				[historyList setValue:[NSDate date] forKey:webView.request.URL.host];
			}
			else{
				[historyList setValue:[NSDate date] forKey:webView.request.URL.host];
			}
			

			
			NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			
			[prefs setObject:historyList forKey:@"fraktol_history_list"];
			

			[spinnerView stopAnimating];
			for(UIWebView *webView in mainView.subviews)
			{
				if(webView.loading == YES)
				{
					[spinnerView startAnimating];
				}
			}
			
			

		}
		else {
			[spinnerView startAnimating];
		
		}
		
		[self UpdateRefreshStopButttons];
		
	}
	
	@catch (NSException* ex) {
		
	}
	
	
}

-(void)CleanUpHistoryList
{
	NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(compare:)];
	
	
	NSArray *dates = [historyList  allValues];
	NSArray *sortedArray = [dates sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor] ];
	
	NSMutableArray *keysToDelete = [[NSMutableArray alloc] init];
	
	NSInteger index = 0;
	for(NSDate *date in sortedArray)
	{
		if(index > 9)
		{
			[keysToDelete addObject:[self getKeyForDate:date]];
		}
		else{
			for(NSString *key in historyList)
			{
				
				
				NSDate *tempDate = [historyList valueForKey:key];
				if(date == tempDate)
				{
					index= index +1;
				}

			}
		}
		
	}
	
	for(NSDate *key in keysToDelete)
	 {
		 [historyList removeObjectForKey:key];
	 }
	
	[keysToDelete release];
}


- (NSString*)getKeyForDate:(NSDate *) date 
{
	NSString *output = @"";
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSMutableDictionary *historyList = [prefs dictionaryForKey:@"fraktol_history_list"];
	
	for(NSString *key in historyList)
	{
		NSDate *tempDate = [historyList valueForKey:key];
		if(date == tempDate)
		{
			output = key;
		}
	}
	
	return output;
}



- (void)webViewDidStartLoad:(UIWebView *)webView
{
	@try{
		[spinnerView startAnimating];
		[self UpdateRefreshStopButttons];
	}
	
	@catch (NSException* ex) {
		
	}

}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	
	
	// Close one webview and remove from Tab collection
	// to free up memory
	/*@try{
		int c = [tabList count];
		if(c==1)
		{
			// Do not close last tab.
		}
		else {
			
			NSArray *keys = [tabList allKeys];
			NSArray *sortedArray = [keys sortedArrayUsingSelector:@selector(compare:)];
			
			for(NSString *key in sortedArray)
			{
				if(key!= currentWebViewTag)
				{
					Tab *tab = [tabList valueForKey:key];		
					
					[tabList removeObjectForKey:key];
				
					[tab release];
				
					for (UIWebView *webView in mainView.subviews)
					{
					
						if (webView.tag == key) {
							[webView removeFromSuperview];
						
						}
					}
					
					[self RefreshTabListView];
					return;
				}
			}
		}
	}

	@catch (NSException* ex) {
	
	}*/
			
	
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	//[tabList release];
}


- (void)dealloc {
	
	//[spinnerView release];
	//[tabScrollView release];
	//[currentWebViewTag release];
	[tabList release];

	
	[popoverController release];
	[bookmarkPopoverController release];
	[detailItem release];

		
    [super dealloc];
}



@end
