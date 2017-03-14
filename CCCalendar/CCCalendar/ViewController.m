//
//  ViewController.m
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "ViewController.h"
#import "CCCalendarView.h"

@interface ViewController ()<CCCalendarViewDelegate>

@property(nonatomic, strong)CCCalendarView *calendarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightNaviBarButtonclick:)];
    
    self.calendarView = [[CCCalendarView alloc]initWithFrame:self.view.frame];
    self.calendarView.delegate = self;
    self.calendarView.allowsMultipleSelection = YES;
    [self.view addSubview:self.calendarView];
}

-(void)rightNaviBarButtonclick:(UIButton *)btn{
    NSMutableString *message = [NSMutableString stringWithFormat:@"公历:\n"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    for (int i = 0; i<self.calendarView.selectedDates.count ; i ++) {
        [message appendFormat:@"%@\n",[formatter stringFromDate:self.calendarView.selectedDates[i]]];
    }
    [message appendString:@"农历:\n"];
    for (int i = 0; i<self.calendarView.selectedLunarDates.count; i++) {
        CCChineseCalendarModel *model = self.calendarView.selectedLunarDates[i];
        [message appendFormat:@"%@ %@ %@\n",model.year,model.month,model.day];
    }
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"你当前选中的日期" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

-(void)calendarDidScrollToYear:(NSUInteger)year lunarYear:(NSString *)lunarYear{
    self.title = [NSString stringWithFormat:@"%ld(%@)",year,lunarYear];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
