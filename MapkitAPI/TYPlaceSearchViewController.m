//
//  TYPlaceSearchViewController.m
//  MapkitAPI
//
//  Created by Thabresh on 8/9/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import "TYPlaceSearchViewController.h"
#import "TYGooglePlacesAPIClient.h"
#import "TYGoogleAutoCompleteResult.h"

@interface TYPlaceSearchViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UITableView *googleAutoCompleteTableView;
@property (strong, nonatomic) UIBarButtonItem *closeButton;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIActivityIndicatorView *searchLoadingActivityIndicator;


@end

@implementation TYPlaceSearchViewController{
    NSTimer *_autoCompleteTimer;
    NSString *_substring;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchBar becomeFirstResponder];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.googleAutoCompleteTableView];
    
    [self.navigationItem setTitleView:self.searchBar];
    [self.navigationItem setRightBarButtonItem:self.closeButton animated:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions

- (void)onCloseButtonPressed:(UIBarButtonItem *)sender {
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UISearchBarDelegate Methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [_autoCompleteTimer invalidate];
    [self searchAutocompleteLocationsWithSubstring];
    [searchBar resignFirstResponder];
    [self.googleAutoCompleteTableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    NSString *searchWordProtection = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (searchWordProtection.length != 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchLoadingActivityIndicator startAnimating];
        });
        
        [self runScript];
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchLoadingActivityIndicator stopAnimating];
        });
    }
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    _substring = [NSString stringWithString:searchBar.text];
    _substring= [_substring stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    _substring = [_substring stringByReplacingCharactersInRange:range withString:text];
    
    if ([_substring hasPrefix:@"+"] && _substring.length >1) {
        _substring  = [_substring substringFromIndex:1];
    }
    
    return YES;
}


#pragma mark - Auto Complete Helper Methods
- (void)runScript{
    
    [_autoCompleteTimer invalidate];
    _autoCompleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.65f
                                                          target:self
                                                        selector:@selector(searchAutocompleteLocationsWithSubstring)
                                                        userInfo:_substring
                                                         repeats:NO];
}


#pragma mark - Networking Methods

- (void)searchAutocompleteLocationsWithSubstring {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchLoadingActivityIndicator startAnimating];
    });
    
    [[TYGooglePlacesApiClient sharedInstance] retrieveGooglePlaceInformation:_substring withCompletion:^(BOOL isSuccess, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                [self showError:error];
            }
            
            [self.googleAutoCompleteTableView reloadData];
            [self.searchLoadingActivityIndicator stopAnimating];
        });
        
        
    }];
}



#pragma mark - Table View Data Source Methods

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [TYGooglePlacesApiClient sharedInstance].searchResults.count + 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [TYGooglePlacesApiClient sharedInstance].searchResults.count) {
        return [self locationSearchResultCellForIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
    
}


- (UITableViewCell *)locationSearchResultCellForIndexPath:(NSIndexPath *)indexPath {
    
    TYGoogleAutoCompleteResult *autoCompleteResult = [[TYGooglePlacesApiClient sharedInstance].searchResults objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [self.googleAutoCompleteTableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    [cell.textLabel setText:autoCompleteResult.name];
    [cell.detailTextLabel setText:autoCompleteResult.description];
    
    return cell;
}


#pragma mark - Table View Delegate Methods


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TYGoogleAutoCompleteResult *autoCompleteResult = [[TYGooglePlacesApiClient sharedInstance].searchResults objectAtIndex:indexPath.row];
    
    [[TYGooglePlacesApiClient sharedInstance] retrieveJSONDetailsAbout:autoCompleteResult.placeID withCompletion:^(NSDictionary *placeInformation, NSError *error) {
        if (error) {
            [self showError:error];
            return;
        }        
        TYGooglePlace *place = [[TYGooglePlace alloc] initWithJSONData:placeInformation];
        [self.delegate searchViewController:self didReturnPlace:place];
        [self dismissViewControllerAnimated:YES completion:nil];        
    }];
}

#pragma mark - Properties

- (UITableViewCell *)loadingCell {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.contentView addSubview:self.searchLoadingActivityIndicator ];
    
    return cell;
}

-(UIActivityIndicatorView *)searchLoadingActivityIndicator {
    if (!_searchLoadingActivityIndicator) {
        _searchLoadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_searchLoadingActivityIndicator setCenter:CGPointMake(self.view.center.x, 22)];
        [_searchLoadingActivityIndicator setHidesWhenStopped:YES];
    }
    return _searchLoadingActivityIndicator;
}

-(UITableView *)googleAutoCompleteTableView {
    if (!_googleAutoCompleteTableView) {
        _googleAutoCompleteTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_googleAutoCompleteTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_googleAutoCompleteTableView setDelegate:self];
        [_googleAutoCompleteTableView setDataSource:self];
    }
    return _googleAutoCompleteTableView;
}

-(UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        [_searchBar setDelegate:self];
        [_searchBar setPlaceholder:@"Search Location.."];
    }
    return _searchBar;
}

-(UIBarButtonItem *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(onCloseButtonPressed:)];
    }
    return _closeButton;
}


#pragma mark - Helper Methods

- (void) showError:(NSError *)error {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Error"
                                          message:error.localizedDescription
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - Lifetime

- (void)dealloc
{
    self.googleAutoCompleteTableView = nil;
}
@end
