//
//  iMermaidScoreKeeper.h
//  iMermaid
//
//  Created by Sudeep Jaiswal on 04/09/14.
//  Copyright (c) 2014 Sudeep Jaiswal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, iMermaidScoreType) {
    iMermaidScoreTypePearl = 1,
    iMermaidScoreTypeMermaid,
    iMermaidScoreTypeJellyfish,
    iMermaidScoreTypeStarfish,
    iMermaidScoreTypeOctopus,
    iMermaidScoreTypeMaleMermaid,
    iMermaidScoreTypeBird,
    iMermaidScoreTypeNumberOfGamesPlayed,
    iMermaidScoreTypeHighScore
};

typedef NS_ENUM(NSInteger, iMermaidLevel) {
    iMermaidLevelI = 1,
    iMermaidLevelII,
    iMermaidLevelIII,
    iMermaidLevelIV,
    iMermaidLevelV,
    iMermaidLevelVI,
    iMermaidLevelVII,
    iMermaidLevelVIII
};

@interface iMermaidScoreKeeper : NSObject

// get a dictionary with current game scores
+(NSDictionary *)getCurrentScores;

// get the pearl score for a particular level
+(NSInteger)getPearlScoreForLevel:(iMermaidLevel)level;

// get the high score for a particular level
+(NSInteger)getHighScoreForLevel:(iMermaidLevel)level;

// provide the score for the type of score and level it was achieved on
+(void)updateScore:(NSInteger)score forScoreType:(iMermaidScoreType)scoreType AndLevel:(iMermaidLevel)level;

// provide an array of scores for a particular level
// array must have NSNumbers of NSIntegers in the order specified in the enum "iMermaidScoreType"
// do not include "no. of games played" and "high score". those will be calculated and updated internally
+(void)updateScores:(NSArray *)scores forLevel:(iMermaidLevel)level;

@end
