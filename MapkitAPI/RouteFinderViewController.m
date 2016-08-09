//
//  RouteFinderViewController.m
//  MapkitAPI
//
//  Created by Thabresh on 8/9/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import "RouteFinderViewController.h"
#import "TYPlaceSearchViewController.h"
#define BACK_LOGO [UIImage imageNamed:@"back"]

@interface RouteFinderViewController ()<TYPlaceSearchViewControllerDelegate>
{
    BOOL shownRoute;
    BOOL fromClicked;
    NSMutableArray *addArray;
    NSDictionary *dictRouteInfo;
}

@end
@interface UITextView(HTML)
- (void)setContentToHTMLString:(id)fp8;
@end
@implementation RouteFinderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Find Direction";
    addArray = [NSMutableArray arrayWithObjects:@"0",@"1", nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:BACK_LOGO style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    [self.popupDirect setFrame:self.view.frame];
    [self.view addSubview:self.popupDirect];
    [self.popupDirect setHidden:YES];
     [self.btnDirection setEnabled:NO];
    // Do any additional setup after loading the view.
}
-(void) backButtonAction:(id)sender {
    if (shownRoute) {
        TYGooglePlace *myPlace = [addArray objectAtIndex:0];
        TYGooglePlace *myPlace1 = [addArray objectAtIndex:1];
        self.navigationItem.title =[NSString stringWithFormat:@"To : %f , %f",myPlace1.location.coordinate.latitude, myPlace1.location.coordinate.longitude];
        self.navigationItem.prompt = [NSString stringWithFormat:@"From : %f , %f",myPlace.location.coordinate.latitude, myPlace.location.coordinate.longitude];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        
        shownRoute = NO;
        [self.popupDirect setHidden:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnGo:(id)sender {
    if ([self CheckValidation]) {
        [self.mapShow removeAnnotations:self.mapShow.annotations];
        [self.mapShow removeOverlays: self.mapShow.overlays];
        TYGooglePlace *myPlace = [addArray objectAtIndex:0];
        TYGooglePlace *myPlace1 = [addArray objectAtIndex:1];
        [self LoadMapRoute:myPlace.name andDestinationAddress:myPlace1.name];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag==0) {
        fromClicked = YES;
    }else{
        fromClicked = NO;
    }
    [textField resignFirstResponder];
    TYPlaceSearchViewController *searchViewController = [[TYPlaceSearchViewController alloc] init];
    [searchViewController setDelegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark - ABCGooglePlacesSearchViewControllerDelegate Methods

-(void)searchViewController:(TYPlaceSearchViewController *)controller didReturnPlace:(TYGooglePlace *)place {
    if (fromClicked) {
        [addArray replaceObjectAtIndex:0 withObject:place];
        self.txtFrom.text = place.formatted_address;
        self.navigationItem.prompt =[NSString stringWithFormat:@"From : %f , %f",place.location.coordinate.latitude, place.location.coordinate.longitude];
    }else{
        [addArray replaceObjectAtIndex:1 withObject:place];
        self.txtTo.text = place.formatted_address;
        self.navigationItem.title =[NSString stringWithFormat:@"To : %f , %f",place.location.coordinate.latitude, place.location.coordinate.longitude];
    }
 
}
-(BOOL)CheckValidation
{
    if(self.txtFrom.text.length==0 && self.txtTo.text.length==0){
        [self ShowAlert:@"Please Enter Source & Destination address"];
        return FALSE;
    }else if (self.txtFrom.text.length==0) {
        [self ShowAlert:@"Please Enter Source address"];
        return FALSE;
    }else if(self.txtTo.text.length==0){
        [self ShowAlert:@"Please Enter Destination address"];
        return FALSE;
    }
    return TRUE;
}
-(void)LoadMapRoute:(NSString*)SourceAddress andDestinationAddress:(NSString*)DestinationAdds
{
    NSString *strUrl;
    strUrl= [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=true",SourceAddress,DestinationAdds];
    strUrl=[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *data =[NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
    NSError* error;
    if (data) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data //1
                              options:kNilOptions
                              error:&error];
        NSArray *arrRouts=[json objectForKey:@"routes"];
        if ([arrRouts isKindOfClass:[NSArray class]]&&arrRouts.count==0) {
            [self ShowAlert:@"didn't find direction"];
            return;
        }
        NSArray *arrDistance =[[[json valueForKeyPath:@"routes.legs.steps.distance.text"] objectAtIndex:0]objectAtIndex:0];
        NSString *totalDuration = [[[json valueForKeyPath:@"routes.legs.duration.text"] objectAtIndex:0]objectAtIndex:0];
        NSString *totalDistance = [[[json valueForKeyPath:@"routes.legs.distance.text"] objectAtIndex:0]objectAtIndex:0];
        NSArray *arrDescription =[[[json valueForKeyPath:@"routes.legs.steps.html_instructions"] objectAtIndex:0] objectAtIndex:0];
        dictRouteInfo=[NSDictionary dictionaryWithObjectsAndKeys:totalDistance,@"totalDistance",totalDuration,@"totalDuration",arrDistance ,@"distance",arrDescription,@"description", nil];
        [self.btnDirection setEnabled:NO];
        if (dictRouteInfo) {
            [self.btnDirection setEnabled:YES];
        }
        NSArray* arrpolyline = [[[json valueForKeyPath:@"routes.legs.steps.polyline.points"] objectAtIndex:0] objectAtIndex:0]; //2
        double srcLat=[[[[json valueForKeyPath:@"routes.legs.start_location.lat"] objectAtIndex:0] objectAtIndex:0] doubleValue];
        double srcLong=[[[[json valueForKeyPath:@"routes.legs.start_location.lng"] objectAtIndex:0] objectAtIndex:0] doubleValue];
        double destLat=[[[[json valueForKeyPath:@"routes.legs.end_location.lat"] objectAtIndex:0] objectAtIndex:0] doubleValue];
        double destLong=[[[[json valueForKeyPath:@"routes.legs.end_location.lng"] objectAtIndex:0] objectAtIndex:0] doubleValue];
        CLLocationCoordinate2D sourceCordinate = CLLocationCoordinate2DMake(srcLat, srcLong);
        CLLocationCoordinate2D destCordinate = CLLocationCoordinate2DMake(destLat, destLong);
        
        [self addAnnotationSrcAndDestination:sourceCordinate :destCordinate andAdds:SourceAddress andDestinationAddress:DestinationAdds];
        //    NSArray *steps=[[aary objectAtIndex:0]valueForKey:@"steps"];
        
        //    replace lines with this may work
        
        NSMutableArray *polyLinesArray =[[NSMutableArray alloc]initWithCapacity:0];
        
        for (int i = 0; i < [arrpolyline count]; i++)
        {
            NSString* encodedPoints = [arrpolyline objectAtIndex:i] ;
            MKPolyline *route = [self polylineWithEncodedString:encodedPoints];
            [polyLinesArray addObject:route];
        }
        [self.mapShow addOverlays:polyLinesArray];
        self.mapShow.delegate = self;
        [self zoomToFitMapAnnotations:self.mapShow];
    }else{
        [self.btnDirection setEnabled:NO];
        [self ShowAlert:@"didn't find direction"];
    }
}
#pragma mark - add annotation on source and destination

-(void)addAnnotationSrcAndDestination :(CLLocationCoordinate2D )srcCord :(CLLocationCoordinate2D)destCord andAdds:(NSString*)SourceAddress andDestinationAddress:(NSString*)DestinationAdds
{
    MKPointAnnotation *sourceAnnotation = [[MKPointAnnotation alloc]init];
    MKPointAnnotation *destAnnotation = [[MKPointAnnotation alloc]init];
    sourceAnnotation.coordinate=srcCord;
    destAnnotation.coordinate=destCord;
    sourceAnnotation.title=SourceAddress;
    destAnnotation.title=DestinationAdds;
    [self.mapShow addAnnotation:sourceAnnotation];
    [self.mapShow addAnnotation:destAnnotation];
}

#pragma mark - decode map polyline

- (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString {
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
    free(coords);
    
    return polyline;
}
#pragma mark - map overlay
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor colorWithRed:155.0/255.0 green:89.0/255.0 blue:182.0/255.0 alpha:1.0];
    renderer.lineWidth = 5.0;
    return renderer;
}
- (IBAction)clickDirection:(id)sender {
    self.navigationItem.title = @"Route Directions";
    self.navigationItem.prompt = nil;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    shownRoute = YES;
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    float targetHeight = self.navigationController.navigationBar.frame.size.height;
    float statusHeight = statusBarFrame.size.height;
    float addValue = statusHeight+targetHeight;
    [self.directionTbl setFrame:CGRectMake(0,addValue, self.view.frame.size.width, self.view.frame.size.height-addValue)];
    [self.directionTbl reloadData];
    [self.popupDirect setHidden:NO];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"identifier"];
        // create a disclosure button for map kit
    UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [disclosure addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disclosureTapped)]];
    view.rightCalloutAccessoryView = disclosure;
    view.enabled = YES;
    view.image = [UIImage imageNamed:@"user"];
    // create a proper annotation view, be lazy and don't use the reuse identifier
    return view;
}
-(void)disclosureTapped
{
    NSLog(@"Tapped");
}
-(void)ShowAlert:(NSString*)AlertMessage
{
    [[[UIAlertView alloc]initWithTitle:AlertMessage message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}
- (void)zoomToFitMapAnnotations:(MKMapView *)mapView {
    if ([mapView.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    
    // Add a little extra space on the sides
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}
#pragma mark - table view data source and delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    else
    {
        if (dictRouteInfo) {
            return [[dictRouteInfo objectForKey:@"distance"] count];
        }
        return 0;
    }
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Driving directions Summary", nil);
    } else
        return NSLocalizedString(@"Driving directions Detail", nil);
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCellIdentifier1=@"cellIdentifire1";
    static NSString *strCellIdentifier2=@"cellIdentifire2";
    
    UITableViewCell *cell =nil;
    if (indexPath.section==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:strCellIdentifier1];
    }
    else if(indexPath.section==1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:strCellIdentifier2];
    }
    if (cell==nil) {
        if (indexPath.section==0) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellIdentifier1];
        }
        else
        {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellIdentifier2];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if (indexPath.section==0&&indexPath.row==0) {
            UILabel *lblSrcDest = [[UILabel alloc]init];
            lblSrcDest.tag=100000;
            
            lblSrcDest.backgroundColor=[UIColor clearColor];
            lblSrcDest.font=[UIFont fontWithName:@"helvetica" size:15];
            lblSrcDest.lineBreakMode=NSLineBreakByWordWrapping;
            
            lblSrcDest.frame=CGRectMake(20, 2, 290, 100);
            lblSrcDest.numberOfLines=5;
            
            [cell addSubview:lblSrcDest];
            
        }
        else if(indexPath.section==1)
        {
            UILabel *lblDistance = [[UILabel alloc]initWithFrame:CGRectMake(30, 2, 260, 20)];
            lblDistance.backgroundColor=[UIColor clearColor];
            [cell addSubview:lblDistance];
            lblDistance.tag=1;
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 30.0f, 280.0f, 56.0f)];
            textView.editable = NO;
            textView.scrollEnabled = NO;
            textView.opaque = YES;
            textView.backgroundColor = [UIColor clearColor];
            textView.tag = 2;
            [cell addSubview:textView];
        }
    }
    if (indexPath.section==0&&indexPath.row==0) {
        UILabel *lblSrcDest=(UILabel*)[cell viewWithTag:100000];
        if (![addArray containsObject:@"0"]) {
            TYGooglePlace *myPlace = [addArray objectAtIndex:0];
            TYGooglePlace *myPlace1 = [addArray objectAtIndex:1];
            
            lblSrcDest.text=[NSString stringWithFormat:@"Driving directions from %@ to %@  \ntotal Distace = %@ \ntotal Duration = %@",myPlace.name,myPlace1.name,[dictRouteInfo objectForKey:@"totalDistance"],[dictRouteInfo objectForKey:@"totalDuration"]];
        }
        
    }
    else if(indexPath.section==1){
        if (![addArray containsObject:@"0"]) {
        UILabel *lblDist = (UILabel *)[cell viewWithTag:1];
        lblDist.text=[[dictRouteInfo objectForKey:@"distance"]objectAtIndex:indexPath.row];
        UITextView *textView = (UITextView *)[cell viewWithTag:2];
        [textView setContentToHTMLString:[[dictRouteInfo objectForKey:@"description"]objectAtIndex:indexPath.row]];
        }
        //        NSLog(@"index row==%i ,%@ , %@",indexPath.row,lblDist.text , [[dictRouteInfo objectForKey:@"distance"]objectAtIndex:indexPath.row]);
        
    }
    
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
