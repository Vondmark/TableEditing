//
//  Student.h
//  TableEditingTest
//
//  Created by Mark on 4/30/19.
//  Copyright © 2019 Mark. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Student : NSObject

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (assign, nonatomic) float averageGrade;

+ (Student*) randomStudent;

@end

NS_ASSUME_NONNULL_END
