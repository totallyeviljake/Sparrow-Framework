//
//  SPTweenerTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "SPEventDispatcher.h"
#import "SPEvent.h"
#import "SPQuad.h"
#import "SPTween.h"
#import "SPMakros.h"

#define E 0.0001f

// -------------------------------------------------------------------------------------------------

@interface SPTweenTest : SenTestCase 
{
  @private
    int mStartedCount;
    int mUpdatedCount;
    int mCompletedCount;
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPTweenTest

- (void) setUp
{
    mStartedCount = mUpdatedCount = mCompletedCount = 0;
}

- (void)testBasicTween
{    
    float startX = 10.0f;
    float startY = 20.0f;
    float endX = 100.0f;
    float endY = 200.0f;
    float startAlpha = 1.0f;
    float endAlpha = 0.0f;
    float totalTime = 2.0f;
    
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    quad.x = startX;
    quad.y = startY;
    quad.alpha = startAlpha;
    
    SPTween *tween = [SPTween tweenWithTarget:quad time:totalTime transition:SP_TRANSITION_LINEAR];
    [tween animateProperty:@"x" targetValue:endX];
    [tween animateProperty:@"y" targetValue:endY];
    [tween animateProperty:@"alpha" targetValue:endAlpha];    
    [tween addEventListener:@selector(onTweenStarted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_STARTED];
    [tween addEventListener:@selector(onTweenUpdated:) atObject:self forType:SP_EVENT_TYPE_TWEEN_UPDATED];    
    [tween addEventListener:@selector(onTweenCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];    
    
    STAssertEqualsWithAccuracy(startX, quad.x, E, @"wrong x");
    STAssertEqualsWithAccuracy(startY, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(startAlpha, quad.alpha, E, @"wrong alpha");        
    STAssertEquals(0, mStartedCount, @"start event dispatched too soon");
    
    [tween advanceTime: totalTime/3.0];   
    STAssertEqualsWithAccuracy(startX + (endX-startX)/3.0f, quad.x, E, @"wrong x: %f", quad.x);
    STAssertEqualsWithAccuracy(startY + (endY-startY)/3.0f, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(startAlpha + (endAlpha-startAlpha)/3.0f, quad.alpha, E, @"wrong alpha");
    STAssertEquals(1, mStartedCount, @"missing start event");
    STAssertEquals(1, mUpdatedCount, @"missing update event");
    STAssertEquals(0, mCompletedCount, @"completed event dispatched too soon");
    
    [tween advanceTime: totalTime/3.0];   
    STAssertEqualsWithAccuracy(startX + 2.0f*(endX-startX)/3.0f, quad.x, E, @"wrong x: %f", quad.x);
    STAssertEqualsWithAccuracy(startY + 2.0f*(endY-startY)/3.0f, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(startAlpha + 2.0f*(endAlpha-startAlpha)/3.0f, quad.alpha, E, @"wrong alpha");
    STAssertEquals(1, mStartedCount, @"too many start events dipatched");
    STAssertEquals(2, mUpdatedCount, @"missing update event");
    STAssertEquals(0, mCompletedCount, @"completed event dispatched too soon");
    
    [tween advanceTime: totalTime/3.0];
    STAssertEqualsWithAccuracy(endX, quad.x, E, @"wrong x: %f", quad.x);
    STAssertEqualsWithAccuracy(endY, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(endAlpha, quad.alpha, E, @"wrong alpha");
    STAssertEquals(1, mStartedCount, @"too many start events dispatched");
    STAssertEquals(3, mUpdatedCount, @"missing update event");
    STAssertEquals(1, mCompletedCount, @"missing completed event");
    
    [tween removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TWEEN_STARTED];
    [tween removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TWEEN_UPDATED];    
    [tween removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];    
}

- (void)onTweenStarted:(SPEvent*)event
{
    mStartedCount++;
}

- (void)onTweenUpdated:(SPEvent*)event
{
    mUpdatedCount++;
}

- (void)onTweenCompleted:(SPEvent*)event
{
    mCompletedCount++;
}

- (void)testSequentialTweens
{
    float startPos = 0.0f;
    float targetPos = 50.0f;
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    
    // 2 tweens should move object up, then down
    SPTween *tween1 = [SPTween tweenWithTarget:quad time:1];
    [tween1 animateProperty:@"y" targetValue:targetPos];
    
    SPTween *tween2 = [SPTween tweenWithTarget:quad time:1];
    [tween2 animateProperty:@"y" targetValue:startPos];
    tween2.delay = 1;
    
    [tween1 advanceTime:1];
    STAssertEquals(targetPos, quad.y, @"wrong y value");
    
    [tween2 advanceTime:1];
    STAssertEquals(targetPos, quad.y, @"second tween changed y value on start");
                   
    [tween2 advanceTime:0.5];
    STAssertEqualsWithAccuracy((targetPos - startPos)/2.0f, quad.y, E, 
                 @"second tween moves object the wrong way");
    
    [tween2 advanceTime:0.5];
    STAssertEquals(startPos, quad.y, @"second tween moved to wrong y position");
}

- (void)makeTweenWithTime:(double)time andAdvanceBy:(double)advanceTime
{
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    SPTween *tween = [SPTween tweenWithTarget:quad time:time];
    [tween animateProperty:@"x" targetValue:100.0f];
    [tween addEventListener:@selector(onTweenStarted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_STARTED];
    [tween addEventListener:@selector(onTweenUpdated:) atObject:self forType:SP_EVENT_TYPE_TWEEN_UPDATED];    
    [tween addEventListener:@selector(onTweenCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED]; 
    
    [tween advanceTime:advanceTime];
    
    STAssertEquals(1, mUpdatedCount, @"short tween did not call onUpdate");
    STAssertEquals(1, mStartedCount, @"short tween did not call onStarted");
    STAssertEquals(1, mCompletedCount, @"short tween did not call onCompleted");
    
    [tween removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TWEEN_STARTED];
    [tween removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TWEEN_UPDATED];    
    [tween removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED]; 
}

- (void)testShortTween
{
    [self makeTweenWithTime:0.1f andAdvanceBy:0.1f];
}

- (void)testZeroTween
{
    [self makeTweenWithTime:0.0f andAdvanceBy:0.1f];
}

@end
