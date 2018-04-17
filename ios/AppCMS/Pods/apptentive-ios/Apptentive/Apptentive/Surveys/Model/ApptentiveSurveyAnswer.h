//
//  ApptentiveSurveyAnswer.h
//  CVSurvey
//
//  Created by Frank Schmitt on 2/29/16.
//  Copyright © 2016 Apptentive, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ApptentiveSurveyAnswerType) {
	ApptentiveSurveyAnswerTypeChoice,
	ApptentiveSurveyAnswerTypeOther
};


@interface ApptentiveSurveyAnswer : NSObject

- (nullable instancetype)initWithJSON:(NSDictionary *)JSON;
- (instancetype)initWithValue:(NSString *)value;

@property (readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) NSString *value;
@property (readonly, nonatomic) NSString *placeholder;
@property (readonly, nonatomic) ApptentiveSurveyAnswerType type;

@end

NS_ASSUME_NONNULL_END
