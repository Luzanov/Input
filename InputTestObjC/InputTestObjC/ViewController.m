//
//  ViewController.m
//  InputTestObjC
//
//  Created by LuzanovRoman on 24.01.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

#import "ViewController.h"
@import Input;

@interface ViewController () <InputDelegate>
@property (nonatomic, weak) IBOutlet UIView * mainView;
@property (nonatomic, assign) BOOL isMainViewSelected;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Input enable];
    [Input addDelegate:self];
}

- (void)dealloc {
    [Input removeDelegate:self];
}

// MARK: - InputDelegate
- (void)didMoveMouseWithOffset:(CGPoint)offset {
    if (self.isMainViewSelected) {
        self.mainView.frame = CGRectOffset(self.mainView.frame, offset.x, offset.y);
    }
}

- (void)didPressMouseButton:(enum SwiftEnum)button {
    if (button == SwiftEnumMbLeft) {
        self.isMainViewSelected = CGRectContainsPoint(self.mainView.frame, Input.mousePosition);
    }
}

- (void)didReleaseMouseButton:(enum SwiftEnum)button {
    self.isMainViewSelected = false;
}
@end
