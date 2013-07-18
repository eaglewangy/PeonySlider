//
//  PeonyViewController.m
//  PeonySlider
//
//  Created by ying wang on 7/18/13.
//
//

#import "PeonyViewController.h"
#import "PeonySlider.h"

@interface PeonyViewController ()

@end

@implementation PeonyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	slider = [[PeonySlider alloc] initWithFrame:CGRectMake(10, 100, 300, 30)]; // the slider enforces a height of 30, although I'm not sure that this is necessary
	
	slider.minimumRangeLength = .06; // this property enforces a minimum range size. By default it is set to 0.0
	
	[slider setMinThumbImage:[UIImage imageNamed:@"rangethumb.png"]]; // the two thumb controls are given custom images
	[slider setMaxThumbImage:[UIImage imageNamed:@"rangethumb.png"]];
	
	
	UIImage *image; // there are two track images, one for the range "track", and one for the filled in region of the track between the slider thumbs
	
	[slider setTrackImage:[[UIImage imageNamed:@"fullrange.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
	
	image = [UIImage imageNamed:@"fillrange.png"];
	[slider setInRangeTrackImage:image];
    
	[slider setScaleFactor:10000];
    [slider setMin:0.25];
    [slider setMax:0.75];
    [slider setPopupViewPrefix:@"¥"];
	[slider addTarget:self action:@selector(report:) forControlEvents:UIControlEventValueChanged]; // The slider sends actions when the value of the minimum or maximum changes
	
	
	reportLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, 310, 30)]; // a label to see the values of the slider in this demo
	reportLabel.adjustsFontSizeToFitWidth = YES;
	reportLabel.textAlignment = NSTextAlignmentCenter;
	NSString *report = [NSString stringWithFormat:@"current slider range is %f to %f", slider.min, slider.max];
	reportLabel.text = report;
    
    [self.view addSubview:slider];
    [self.view addSubview:reportLabel];
}

- (void)report:(PeonySlider *)sender {
	NSString *report = [NSString stringWithFormat:@"current slider range is %f to %f", sender.min, sender.max];
	reportLabel.text = report;
	NSLog(@"%@",report);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
