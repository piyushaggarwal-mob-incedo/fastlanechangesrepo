//
//  ApptentiveSurvey.m
//  CVSurvey
//
//  Created by Frank Schmitt on 2/26/16.
//  Copyright © 2016 Apptentive, Inc. All rights reserved.
//

#import "ApptentiveSurvey.h"
#import "ApptentiveSafeCollections.h"
#import "ApptentiveSurveyQuestion.h"

NS_ASSUME_NONNULL_BEGIN


@implementation ApptentiveSurvey

- (nullable instancetype)initWithJSON:(NSDictionary *)JSON {
	self = [super init];

	if (self) {
		_title = JSON[@"title"];
		_name = JSON[@"name"];
		_surveyDescription = JSON[@"description"];
		_showSuccessMessage = [JSON[@"show_success_message"] boolValue];
		_successMessage = JSON[@"success_message"];
		_viewPeriod = [JSON[@"view_period"] doubleValue];
		_submitText = JSON[@"submit_text"];
		_requiredText = JSON[@"required_text"];
		_validationErrorText = JSON[@"validation_error"];

		NSMutableArray *mutableQuestions = [NSMutableArray array];

		for (NSDictionary *questionJSON in JSON[@"questions"]) {
			ApptentiveSurveyQuestion *question = [[ApptentiveSurveyQuestion alloc] initWithJSON:questionJSON];
			ApptentiveArrayAddObject(mutableQuestions, question);
		}

		_questions = [mutableQuestions copy];
	}

	return self;
}

@end

NS_ASSUME_NONNULL_END
