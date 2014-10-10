//
//  BrowserViewController.h
//  Browser
//
//  Created by Ronan Moynihan on 10/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tab.h"
#import "HistoryViewController.h"
#import "BookmarkViewController.h"

@interface BrowserViewController : UIViewController<UIWebViewDelegate, UIActionSheetDelegate,UIGestureRecognizerDelegate,UIPopoverControllerDelegate>{
	
	NSMutableDictionary *tabList;
	NSMutableDictionary *bookmarkList;
	NSMutableDictionary *historyList;
	NSInteger *currentWebViewTag;
	NSInteger tabCount;
	
	UIPopoverController *popoverController;
	UIPopoverController *bookmarkPopoverController;
	id detailItem; 
	
	IBOutlet UIView *mainView;
	IBOutlet UIView *bookmarkView;
	IBOutlet UIView *tabView;
	IBOutlet UIView *controlsView;
	IBOutlet UIImageView *tabImage;
	IBOutlet UIScrollView *tabScrollView;
	IBOutlet UIScrollView *bookmarkScrollView;
	IBOutlet UILabel *tabCountLabel;
	IBOutlet UILabel *webPageTitle;
	IBOutlet UIButton *backButton;
	IBOutlet UIButton *forwardButton;
	IBOutlet UIButton *RefreshButton;
	IBOutlet UIView *favIconView;
	IBOutlet UIButton *showHideTabButton;
	IBOutlet UIButton *showHideBookmarksButton;
	IBOutlet UIButton *bookmarkPageButton;
	
	IBOutlet UIActivityIndicatorView *spinnerView;
	IBOutlet UITextField *addressBar;
	IBOutlet UIButton *autoRefresh;
	IBOutlet UIButton *newTabButton;
	IBOutlet UIButton *fractolButton;
	IBOutlet UITextField *searchBox;
	IBOutlet UIImageView *mainFavIcon;
	
	

}

@property (nonatomic, retain) UIPopoverController *popoverController; 
@property (nonatomic, retain) UIPopoverController *bookmarkPopoverController; 
@property (nonatomic, retain) id detailItem;



- (IBAction)loadWebPageWithString:(NSString *)urlString;

- (IBAction)settingsTapped;
- (IBAction)addressBarEditingDidEnd;

- (IBAction)goButtonClicked;
- (IBAction)refreshStopClicked;

- (IBAction)showHideTabButtonTapped;
- (IBAction)showHideBookmarksButtonTapped;


- (IBAction)newTabButtonClicked;
- (IBAction)bookmarkButtonTapped;
- (IBAction)showAddBookmarkPopup;

- (IBAction)tabPageItemTapped:sender;
- (IBAction)tabCloseButtonTapped;
- (IBAction)fraktolButtonTapped;
- (IBAction)goBack:sender;
- (IBAction)goForward:sender;
- (IBAction)addressBarEditing:(id) sender;



@end

