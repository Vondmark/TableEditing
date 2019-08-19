//
//  ViewController.m
//  TableEditingTest
//
//  Created by Mark on 4/5/19.
//  Copyright © 2019 Mark. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import "Group.h"


@interface ViewController () <UITableViewDelegate,  UITableViewDataSource>

@property (weak, nonatomic) UITableView* tableView;
@property (strong,nonatomic) NSMutableArray* groupsArray;
@end

@implementation ViewController

-(void) loadView{
    [super loadView];
    
    CGRect frame = self.view.bounds;
    frame.origin = CGPointZero;
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    self.tableView.allowsSelectionDuringEditing = NO;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.groupsArray = [NSMutableArray array];
    
    for (int i = 0; i < ((arc4random() % 6) + 5); i++) {
        Group * group = [[Group alloc] init];
        group.name = [NSString stringWithFormat:@"Group №%d", i];
        
        NSMutableArray* array =[NSMutableArray array];
        
        for (int j = 0; j < ((arc4random() % 11) + 15); j++) {
            [array addObject:[Student randomStudent]];
        }
        group.students = array;
        
        [self.groupsArray addObject:group];
    }
    [self.tableView reloadData];
    
    self.navigationItem.title = @"Students";
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(actionEdit:)];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                target:self
                                                                                action:@selector(actionAddSection:)];
    
    self.navigationItem.leftBarButtonItem = addButton;
    
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
    
    
}

#pragma mark - Actions
-(void) actionEdit:(UIBarButtonItem*) sender {
    
    BOOL isEditing = self.tableView.editing;
    
    [self.tableView setEditing:!isEditing animated:YES];
     
     UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    if (self.tableView.editing) {
        item = UIBarButtonSystemItemDone;
    }
     UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item
                                                                                 target:self
                                                                                 action:@selector(actionEdit:)];
     
     self.navigationItem.rightBarButtonItem = editButton;
    
}

-(void) actionAddSection:(UIBarButtonItem*) sender {
    
    Group * group = [[Group alloc] init];
    group.name = [NSString stringWithFormat:@"Group №%lu", [self.groupsArray count]+ 1];
    
    group.students = @[[Student randomStudent], [Student randomStudent]];
    
    NSInteger newSectionIndex = 0;
    
    [_groupsArray insertObject:group atIndex:newSectionIndex];
    
    [self.tableView beginUpdates];
    
    NSIndexSet *insertSections = [NSIndexSet indexSetWithIndex:newSectionIndex];
    
    [self.tableView insertSections:insertSections
                  withRowAnimation:[_groupsArray count] % 2 ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight];
    
    [self.tableView endUpdates];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
        
    });
    
}

#pragma mark - DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.groupsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    Group* group = [self.groupsArray objectAtIndex:section];
    
    return [group.students count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        static NSString* addStudent = @"AddStudentCell";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:addStudent];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addStudent];
            cell.textLabel.textColor = [UIColor blueColor];
            cell.textLabel.text = @"Add Student";
        }
        return cell;
        
    }else{
        static NSString* studentIdentifier = @"StudentCell";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:studentIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:studentIdentifier];
        }
        
        Group* group = [self.groupsArray objectAtIndex:indexPath.section];
        Student* student = [group.students objectAtIndex:(int)indexPath.row - 1];
        
        cell.textLabel.text = [NSString stringWithFormat:@" %@ %@" , student.firstName, student.lastName];
        if (student.averageGrade >= 4.0) {
            cell.detailTextLabel.textColor = [UIColor greenColor];
        } else if (student.averageGrade >= 3.0){
            cell.detailTextLabel.textColor = [UIColor orangeColor];
        } else {
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.2f" , student.averageGrade];
        
        return cell;
    }
    
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [[self.groupsArray objectAtIndex:section] name];
}



- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return  indexPath.row > 0;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    Group* souceGroup = [self.groupsArray objectAtIndex:sourceIndexPath.section];
    Student* student = [souceGroup.students objectAtIndex:sourceIndexPath.row - 1];
    
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:souceGroup.students];
    
    if (sourceIndexPath.section == destinationIndexPath.section) {
        
        [tempArray exchangeObjectAtIndex:sourceIndexPath.row - 1 withObjectAtIndex:destinationIndexPath.row - 1];
        souceGroup.students = tempArray;
        
    } else{
        
        [tempArray removeObject:student];
        souceGroup.students = tempArray;
        
        Group* destinationGroup = [self.groupsArray objectAtIndex:destinationIndexPath.section];
        tempArray = [NSMutableArray arrayWithArray:destinationGroup.students];
        [tempArray insertObject:student atIndex:destinationIndexPath.row - 1];
        destinationGroup.students = tempArray;
        
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Group* souceGroup = [self.groupsArray objectAtIndex:indexPath.section];
        Student* student = [souceGroup.students objectAtIndex:indexPath.row - 1];
        
        NSMutableArray* tempArray = [NSMutableArray arrayWithArray:souceGroup.students];
        [tempArray removeObject:student];
        souceGroup.students = tempArray;
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [tableView endUpdates];
    }
}


#pragma mark - UiTableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row == 0 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    if (proposedDestinationIndexPath.row == 0) {
        return sourceIndexPath;
    }else{
        return proposedDestinationIndexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        Group* group = [self.groupsArray objectAtIndex:indexPath.section];
        
        NSMutableArray* tempArray = nil;
        
        if (group.students) {
            tempArray = [NSMutableArray arrayWithArray:group.students];
        }else{
            tempArray = [NSMutableArray array];
        }
        
        NSInteger newStudentIndex = 0;
        
        [tempArray insertObject:[Student randomStudent] atIndex:newStudentIndex];
        group.students = tempArray;
        
        [self.tableView beginUpdates];
        
        NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:newStudentIndex + 1 inSection:indexPath.section];
        
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [self.tableView endUpdates];
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
            
        });
        
    }
}





@end
