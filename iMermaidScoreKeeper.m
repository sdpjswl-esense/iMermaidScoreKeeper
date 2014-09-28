//
//  iMermaidScoreKeeper.m
//  iMermaid
//
//  Created by Sudeep Jaiswal on 04/09/14.
//  Copyright (c) 2014 Sudeep Jaiswal. All rights reserved.
//

#import "iMermaidScoreKeeper.h"

#define LEVELS 8
#define SCORE_TYPES 9
#define PLIST_NAME @"score"
// set any file name (without extension)
// make sure a PList file with this name exists in the bundle

@implementation iMermaidScoreKeeper


#pragma mark - Public getter methods

+(NSDictionary *)getCurrentScores {
    
    NSString *pListPath = [iMermaidScoreKeeper getPListPath];
    NSDictionary *currentScores = [NSDictionary dictionaryWithContentsOfFile:pListPath];
    return currentScores;
}

+(NSInteger)getPearlScoreForLevel:(iMermaidLevel)level {
    
    NSString *levelKey = [iMermaidScoreKeeper getLevelNameKeyForLevel:level];
    NSString *pearlKey = [iMermaidScoreKeeper getScoreTypeKeyForScore:iMermaidScoreTypePearl];
    
    NSDictionary *currentScores = [iMermaidScoreKeeper getCurrentScores];
    NSNumber *pearlScore = [[currentScores valueForKey:levelKey] valueForKey:pearlKey];
    
    return [pearlScore integerValue];
}

+(NSInteger)getHighScoreForLevel:(iMermaidLevel)level {
    
    NSString *levelKey = [iMermaidScoreKeeper getLevelNameKeyForLevel:level];
    NSString *highScoreKey = [iMermaidScoreKeeper getScoreTypeKeyForScore:iMermaidScoreTypeHighScore];
    
    NSDictionary *currentScores = [iMermaidScoreKeeper getCurrentScores];
    NSNumber *highScore = [[currentScores valueForKey:levelKey] valueForKey:highScoreKey];
    
    return [highScore integerValue];
}


#pragma mark - Public setter methods

+(void)updateScore:(NSInteger)score forScoreType:(iMermaidScoreType)scoreType AndLevel:(iMermaidLevel)level {
    
    NSString *scoreTypeKey = [iMermaidScoreKeeper getScoreTypeKeyForScore:scoreType];
    NSString *levelKey = [iMermaidScoreKeeper getLevelNameKeyForLevel:level];
    NSMutableDictionary *scoreData = [iMermaidScoreKeeper getCurrentScoresInMutableForm];
    
    NSNumber *previousScore = [[scoreData valueForKey:levelKey] valueForKey:scoreTypeKey];
    NSNumber *newScore = [NSNumber numberWithInteger:([previousScore integerValue] + score)];
    
    // updating dictionary according to new score
    [[scoreData valueForKey:levelKey] setObject:newScore forKey:scoreTypeKey];
    [iMermaidScoreKeeper saveScoresToPList:scoreData];
}

+(void)updateScores:(NSArray *)scores forLevel:(iMermaidLevel)level {
    
    NSString *crashString = [NSString stringWithFormat:@"Array count must be equal to total number of score types, i.e.: %d. Make sure you are not sending scores for number of games played an high score.", SCORE_TYPES-2];
    NSAssert([scores count] == SCORE_TYPES-2, crashString);
    
    NSString *levelKey = [iMermaidScoreKeeper getLevelNameKeyForLevel:level];
    NSMutableDictionary *scoreData = [iMermaidScoreKeeper getCurrentScoresInMutableForm];
    
    for (NSNumber *score in scores) {
        
        NSInteger index = [scores indexOfObject:score];
        NSString *scoreTypeKey = [iMermaidScoreKeeper getScoreTypeKeyForScore:index+1];
        
        NSNumber *previousScore = [[scoreData valueForKey:levelKey] valueForKey:scoreTypeKey];
        NSNumber *newScore = [NSNumber numberWithInteger:([previousScore integerValue] + [score integerValue])];
        
        // updating dictionary according to new score
        [[scoreData valueForKey:levelKey] setObject:newScore forKey:scoreTypeKey];
    }
    
    // no. of games played
    NSString *noOfGamesPlayedKey = [iMermaidScoreKeeper getScoreTypeKeyForScore:iMermaidScoreTypeNumberOfGamesPlayed];
    NSNumber *previousGamesCount = [[scoreData valueForKey:levelKey] valueForKey:noOfGamesPlayedKey];
    NSNumber *newGamesCount = [NSNumber numberWithInteger:([previousGamesCount integerValue]+1)];
    
    // updating dictionary according to games played
    [[scoreData valueForKey:levelKey] setObject:newGamesCount forKey:noOfGamesPlayedKey];
    
    // high score
    NSString *highScoreKey = [iMermaidScoreKeeper getScoreTypeKeyForScore:iMermaidScoreTypeHighScore];
    NSNumber *previousHighScore = [[scoreData valueForKey:levelKey] valueForKey:highScoreKey];
    NSNumber *currentPearlScore = [scores firstObject];
    
    if ([currentPearlScore integerValue] > [previousHighScore integerValue]) {
        // updating dictionary according to new score
        [[scoreData valueForKey:levelKey] setObject:currentPearlScore forKey:highScoreKey];
    }
    
    [iMermaidScoreKeeper saveScoresToPList:scoreData];
}


#pragma mark - PList methods

+(NSString *)getPListPath {
    NSArray *directoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [directoryPath objectAtIndex:0];
    NSString *pListPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", PLIST_NAME]];
    return pListPath;
}

+(void)saveScoresToPList:(NSMutableDictionary *)scores {
    NSString *pListPath = [iMermaidScoreKeeper getPListPath];
    BOOL success = [scores writeToFile:pListPath atomically:YES];
    if (success) {
        NSLog(@"pList path:\n%@", pListPath);
    }
    else {
        NSLog(@"error saving data in pList");
    }
}


#pragma mark - Score methods

+(void)initPListWithZeroScores {
    
    NSMutableDictionary *dictionaryZero = [[NSMutableDictionary alloc] init];
    
    for (int i=1; i<=LEVELS; i++) {
        
        NSNumber *zeroScore = [NSNumber numberWithInteger:0];
        NSMutableDictionary *scoreTypeMutableDictionary = [[NSMutableDictionary alloc] init];
        
        for (int j=1; j<=SCORE_TYPES; j++) {
            [scoreTypeMutableDictionary setObject:zeroScore forKey:[iMermaidScoreKeeper getScoreTypeKeyForScore:j]];
        }
        
        [dictionaryZero setObject:scoreTypeMutableDictionary forKey:[iMermaidScoreKeeper getLevelNameKeyForLevel:i]];
    }
    
    [iMermaidScoreKeeper saveScoresToPList:dictionaryZero];
}

+(NSMutableDictionary *)getCurrentScoresInMutableForm {
    
    NSDictionary *currentScores = [iMermaidScoreKeeper getCurrentScores];
    
    if (currentScores == nil) {
        [iMermaidScoreKeeper initPListWithZeroScores];
        currentScores = [iMermaidScoreKeeper getCurrentScores];
    }
    
    NSMutableDictionary *mDictionary = [currentScores mutableCopy];
    return mDictionary;
}


#pragma mark - Dictionary keys getter methods

+(NSString *)getLevelNameKeyForLevel:(iMermaidLevel)level {
    
    switch(level) {
        case 1:
            return @"levelI";
            
        case 2:
            return @"levelII";
            
        case 3:
            return @"levelIII";
            
        case 4:
            return @"levelIV";
            
        case 5:
            return @"levelV";
            
        case 6:
            return @"levelVI";
            
        case 7:
            return @"levelVII";
            
        case 8:
            return @"levelVIII";
    }
}

+(NSString *)getScoreTypeKeyForScore:(iMermaidScoreType)scoreType {
    
    switch(scoreType) {
            
        case 1:
            return @"pearlScore";
            
        case 2:
            return @"mermaidScore";
            
        case 3:
            return @"jellyfishScore";
            
        case 4:
            return @"starfishScore";
            
        case 5:
            return @"octopusScore";
            
        case 6:
            return @"maleMermaidScore";
            
        case 7:
            return @"birdScore";
            
        case 8:
            return @"noOfGamesPlayedScore";
            
        case 9:
            return @"highScore";
    }
}

@end
