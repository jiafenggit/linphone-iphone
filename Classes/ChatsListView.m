/* ChatViewController.m
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import "ChatsListView.h"
#import "PhoneMainView.h"

@implementation ChatsListView

#pragma mark - Lifecycle Functions

- (id)init {
	return [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle mainBundle]];
}

#pragma mark - ViewController Functions

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textReceivedEvent:)
												 name:kLinphoneMessageReceived
											   object:nil];
	[self setEditing:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:kLinphoneMessageReceived object:nil];
}

#pragma mark - Event Functions

- (void)textReceivedEvent:(NSNotification *)notif {
	[_tableController loadData];
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
	if (compositeDescription == nil) {
		compositeDescription = [[UICompositeViewDescription alloc] init:self.class
															  statusBar:StatusBarView.class
																 tabBar:TabBarView.class
															 fullscreen:false
														  landscapeMode:LinphoneManager.runningOnIpad
														   portraitMode:true];
	}
	return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
	return self.class.compositeViewDescription;
}

#pragma mark - Action Functions

- (IBAction)onAddClick:(id)event {
	ChatConversationView *view = VIEW(ChatConversationView);
	[PhoneMainView.instance changeCurrentView:view.compositeViewDescription push:TRUE];
	[view setChatRoom:NULL];
}

- (IBAction)onEditionChangeClick:(id)sender {
	_addButton.hidden = self.tableController.isEditing;
}

- (IBAction)onDeleteClick:(id)sender {
	NSString *msg =
		[NSString stringWithFormat:NSLocalizedString(@"Are you sure that you want to delete %d conversations?", nil),
								   _tableController.selectedItems.count];
	[UIConfirmationDialog ShowWithMessage:msg
		onCancelClick:^() {
		  [self onEditionChangeClick:nil];
		}
		onConfirmationClick:^() {
		  [_tableController removeSelection];
		  [_tableController loadData];
		  [self onEditionChangeClick:nil];
		}];
}


@end
