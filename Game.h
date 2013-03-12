//
//  Game.h
//  Jumpy
//
//  Created by Matthew Sherar on 2012-12-14.
//  Copyright 2012 Matthew Sherar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCParallaxScrollNode.h"

@interface Game : CCLayer {
    
    CCSpriteBatchNode *batch;
    CCParticleBatchNode *particleBatch;

    CCSprite *_guy;
    CCLabelTTF *startLabel;
    CCLabelTTF *bonusLabel;
    CCLabelTTF *endLabel;
    float score;
    bool firstJump;
    bool secondJump;
    bool jumpAgain;
    bool restart;
    bool start;
    bool endGameFinished;
    bool jumping;
    bool doNothing;
    
    CCParallaxScrollNode *parallax;
    
    float platformXPosition;
    
    float platformWidth;
    float platformHeight;
    
    float accelerationX;
    
    CCSprite* background;
    CCSprite* swapBackground;
    int oldMultiplier; 
    float animationWalkingSpeed;
   // CCSprite *platformSize;
    NSMutableArray* walkingFrames;
    NSMutableArray* jumpingFrames;
    int platform1;
    int platform2;
    int platform3;
    int platform4;
    float oldVelX;
    int backgroundTag;
    int swapBackgroundTag;
    
    CCProgressTimer* progressTimer;
    
    CCLabelTTF *multiplierLabel;
    
    float asteroidSpeed; 
    
    int particleTag;
    int foodTagPlatform1;
    int foodTagPlatform2;
    int foodTagPlatform3;
    int foodTagPlatform4;
    int enemyTag;
    int halfGravityTag;
    int twiceGravityTag;
    int twoTimesMultiplierTag;
    int threeTimesMultiplierTag;
    int fourTimeMultiplierTag;
    
    int infinityTag;
    int boostTag;
    int lifeTag;
    int magnetTag;
    
    int lifeDisplayTag;
    int infinityDisplayTag;
    int magnetDisplayTag;
    
    int fireParticleEffectsTag;
    
    int halfGravityDisplayTag;
    int twiceGravityDisplayTag;
    int twoTimesMultiplierDisplayTag;
    int threeTimesMultiplierDisplayTag;
    int fourTimeMultiplierDisplayTag;
    
    int permanantDisplayTag;
    
    int bonusMultiplier;
    int globalMultiplier;
    
    bool guyWalkingRight;
    bool guyWalkingLeft;
    bool changeDirectionToRight;
    bool changeDirectionToLeft;

    bool temporarySpeedUp;
    int rainTag;
    
    int ballTagPlatform1;
    int ballTagPlatform2;
    int ballTagPlatform3;
    int ballTagPlatform4;
    
    CCParticleSystemQuad *emitter;
    CCParticleFlower *rain;
    
    CCLabelAtlas *scoreLabel;
    int firstStart;
    
    float restorePlatformVelToThis;
    float platformVerticalVel;
    float oldPlatformVeticalVel;
    float oldPlatformOneHorizontal;
    float oldPlatformTwoHorizontal;
    float oldPlatformThreeHorizontal;
    float oldPlatformFourHorizontal;
    
    float platformOneHorizontalVel;
    float platformTwoHorizontalVel;
    float platformThreeHorizontalVel;
    float platformFourHorizontalVel;
    
    float accelY, accelX, velX, velY;
    bool walking;
    bool onPlatform;
    int onPlatformType;
    bool inifinityOn;
    bool magnetOn;
    bool lifeOn;
    bool boostOn;
    float gravity;
    
}
+(CCScene *) scene;
@property (nonatomic, retain) CCSprite *guy;
@property (nonatomic, retain) CCSpeed *walkAction;
@property (nonatomic, retain) CCSpeed *walkLeft;
@property (nonatomic, retain) CCAction *jumpAction;
@property (nonatomic, retain) CCAction *jumpLeft;
@end
