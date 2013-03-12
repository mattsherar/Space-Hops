//
//  Game.m
//  Jumpy
//
//  Created by Matthew Sherar on 2012-12-14.
//  Copyright 2012 Matthew Sherar. All rights reserved.
//

#import "Game.h"
#import "Highscores.h"
#import "iAdSingleton.h"
#import "SimpleAudioEngine.h"

@implementation Game
@synthesize guy = _guy;
@synthesize walkAction = _walkAction;
@synthesize walkLeft = _walkLeft;
@synthesize jumpLeft = _jumpLeft;
@synthesize jumpAction = _jumpAction;
+(CCScene *) scene
{
  // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Game *layer = [Game node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
-(id)init{
    if ((self = [super init]))
	{
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
        
        batch = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png"];
        [self addChild:batch z:0 tag:0];
        

        CCSprite * sprite = [CCSprite spriteWithFile:@"sprite.png"];
        
        scoreLabel = [[CCLabelAtlas alloc]  initWithString:@"0" charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
        bonusLabel = [CCLabelTTF labelWithString:@"+100" fontName:@"RBNo2-Light-Alternative" fontSize:35];
        bonusLabel.position = ccp([CCDirector sharedDirector].winSize.width/2, 350);
        [self addChild: bonusLabel z:100 tag:1];
        bonusLabel.visible = NO;
        
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = YES;
        [self start];
        
    }
    return self;
}
-(void)start{
    [self addChild:scoreLabel z:100 tag:1];
    [self initVariables];
    [self setPlatforms];
    [self addGuy];
    [self resetPlatforms];
    [self scheduleUpdate];
    start = NO;
    startLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Ready? Tap to Start!"] fontName:@"RBNo2-Light-Alternative" fontSize:35 ];
    startLabel.position = ccp([CCDirector sharedDirector].winSize.width/2, 200);
    startLabel.visible = YES;
    
    multiplierLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"x%d", globalMultiplier*bonusMultiplier] fontName:@"RBNo2-Light-Alternative" fontSize:20];
    multiplierLabel.position = ccp(29, [CCDirector sharedDirector].winSize.height-10);
    multiplierLabel.visible = YES;
    [self addChild:multiplierLabel z:200 tag:1];
    
    CCSprite *topBar = [CCSprite spriteWithSpriteFrameName:@"topBar.png"];
    topBar.position = ccp([CCDirector sharedDirector].winSize.width/2, [CCDirector sharedDirector].winSize.height-12);
        
    
    CCSprite *bottomBar = [CCSprite spriteWithSpriteFrameName:@"bottomBar.png"];
    bottomBar.position = ccp([CCDirector sharedDirector].winSize.width/2, 12);
    bottomBar.scaleY = 1.5;
    [batch addChild:bottomBar z:100 tag:permanantDisplayTag];
    [batch addChild:topBar z:100 tag:permanantDisplayTag];
    
    CCLabelTTF *inFrontOfBar = [CCLabelTTF labelWithString:@"Food: " fontName:@"RBNo2-Light-Alternative" fontSize:15];
    inFrontOfBar.position = ccp(175, scoreLabel.position.y+8);
    inFrontOfBar.visible = YES;
  
    CCSprite* bar = [CCSprite spriteWithSpriteFrameName:@"progress.png"];
    
    progressTimer = [CCProgressTimer progressWithSprite:bar];
    
    progressTimer.type = kCCProgressTimerTypeBar;
    progressTimer.midpoint = ccp(0,0); // starts from left
    progressTimer.barChangeRate = ccp(1,0);
    
    progressTimer.percentage = 0;
    
    progressTimer.position = ccp([CCDirector sharedDirector].winSize.width/2-27, [CCDirector sharedDirector].winSize.height-12);
    
    [self addChild:progressTimer z:5000 tag:1];
    _guy.position = ccp([CCDirector sharedDirector].winSize.width/2, 105);
    onPlatform = NO;
    [_guy stopAllActions];
    
    endLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Game Over"] fontName:@"RBNo2-Light-Alternative" fontSize:35 ];
    endLabel.position = ccp([CCDirector sharedDirector].winSize.width/2, 200);
    [self addChild:startLabel z:100 tag:1];
    [self addChild:endLabel z:100 tag:1];

    endLabel.visible=NO;
    [self schedule:@selector(updateAd:) interval:0.2];
    
}
-(void)restart{
    [self unscheduleUpdate];
    startLabel.visible = YES;
    endLabel.visible = NO;
    [self clearAllItems];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    [_guy stopAllActions];
    [self initVariables];
    [self resetPlatforms];
    start = NO;
    progressTimer.percentage=4;
    [multiplierLabel setString:[NSString stringWithFormat:@"x%d", globalMultiplier*bonusMultiplier]];
    restart = YES;
    progressTimer.percentage = 0;

    _guy.position = ccp(winSize.width/2, 105);
    _guy.visible = YES;
    [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JumpRight-006.tif"]];
    
    [self scheduleUpdate];
    [self schedule:@selector(updateAd:) interval:2.0];
}
-(void)initVariables{
    firstJump = NO;
    secondJump = NO;
    jumpAgain = YES;
    changeDirectionToRight = NO;
    changeDirectionToLeft = NO;
    
    endGameFinished = NO;
    enemyTag = 13;
    oldVelX = 0;
    score = 1.0f;
    
    globalMultiplier = 1;
    bonusMultiplier = 1;
    
    platformXPosition = 0;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    scoreLabel.position = ccp(winSize.width-110, winSize.height-scoreLabel.contentSize.height+14);
    
    onPlatformType = 0;
    platformVerticalVel = 35.0f;
    animationWalkingSpeed = 0.1f;
    platformOneHorizontalVel = -30.0f;
    platformFourHorizontalVel = 10.0f;
    platformThreeHorizontalVel = -5.0f;
    platformTwoHorizontalVel = -40.0f;
    
    oldMultiplier = 1;
    
    guyWalkingLeft = NO;
    guyWalkingRight = NO;
    
    oldPlatformFourHorizontal = 0;
    oldPlatformTwoHorizontal = 0;
    oldPlatformOneHorizontal = 0;
    oldPlatformThreeHorizontal = 0;
    oldPlatformVeticalVel = 0;
    
    lifeOn = NO;
    boostOn = NO;
    magnetOn = NO;
    inifinityOn = NO;
    asteroidSpeed = 300.0f;
    
    firstStart = 0;
    
    permanantDisplayTag = 200;
    
    ballTagPlatform1 = 9;
    ballTagPlatform2 = 10;
    ballTagPlatform3 = 11;
    ballTagPlatform4 = 12;
    foodTagPlatform1 = 30;
    foodTagPlatform2 = 31;
    foodTagPlatform3 = 32;
    foodTagPlatform4 = 33;
    
    bonusMultiplier = 1;
    
    halfGravityTag = 35;
    twiceGravityTag = 36;
    twoTimesMultiplierTag = 37;
    threeTimesMultiplierTag = 38;
    fourTimeMultiplierTag = 39;
    
    fireParticleEffectsTag = 50;
    endGameFinished = NO;
    halfGravityDisplayTag = 40;
    twiceGravityDisplayTag = 41;
    twoTimesMultiplierDisplayTag = 42;
    threeTimesMultiplierDisplayTag = 43;
    fourTimeMultiplierDisplayTag = 44;
    rainTag=55;
    infinityTag = 45;
    boostTag = 46;
    lifeTag = 47;
    magnetTag = 48;
    
    infinityDisplayTag = 51;
    magnetDisplayTag = 52;
    lifeDisplayTag = 53;
    
    backgroundTag = 20;
    swapBackgroundTag = 21;
    jumping =  NO;
    particleTag = 25;
    
    doNothing = YES;
    
    platform1 = 5;
    platform2 = 6;
    platform3 = 7;
    platform4 = 8;
    onPlatform = YES;
    onPlatformType = platform1;
    gravity = -800.0f;
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{

    if(start == NO && restart == NO){
        start = YES;
        doNothing = NO;
        startLabel.visible = NO;
                
    }
    else if(restart == YES){
        
        restart = NO;
        start = YES;
        endLabel.visible = NO;
        startLabel.visible = NO;
        
        
    }
    else{
        [self jump];
        CCLOG(@"changnes");
    }
}
-(void)killAsteroid:(ccTime)delta{
    for(CCNode *child in self.children){
        if (child.tag == particleTag && child.visible == YES){
            int num;
            num = [child numberOfRunningActions];
            if(num == 0){
                child.visible = NO;
            }
        }
    }
}
-(void)updateAd:(ccTime)delta{
    [[iAdSingleton sharedInstance] moveBannerOffScreen];
}
-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    
    accelerationX = acceleration.x*805;
}
-(void)jump{
    [_guy stopAllActions];
    if(firstJump == NO && secondJump == NO){
        [_guy stopAction:_walkAction];
        [_guy stopAction:_jumpAction];
        _guy.position = ccpAdd(_guy.position, ccp(0,-6));
        if(guyWalkingRight){
            [_guy runAction:_jumpAction];
        }
        else{
            [_guy runAction:_jumpLeft];
        }
        firstJump = YES;
        jumping = YES;
    }
    else if(secondJump == YES && firstJump == YES && jumpAgain == YES){
        velY = 400 + (progressTimer.percentage);
        progressTimer.percentage-=5;
        jumpAgain = NO;
    }
    
}
-(void)addGuy{
    self.guy = [CCSprite spriteWithSpriteFrameName:@"FrameRight-008.tif"];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _guy.position = ccp(winSize.width/2, 70);
    [batch addChild:_guy z:10 tag:0];
    walkingFrames = [[NSMutableArray alloc] init];
    for(int i =1; i<10; i++){
        
        [walkingFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"FrameRight-00%d.tif", i]]];
        
    }
    NSMutableArray *walkLeftFrames = [[NSMutableArray alloc] init];
    for(int i =1; i<10; i++){
        
        [walkLeftFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"FrameLeft-00%d.tif", i]]];
        
    }
    CCLOG(@"fail");
    CCAnimation *walkLeftRepeat = [CCAnimation animationWithSpriteFrames:walkLeftFrames delay:0.01f];
    CCAnimate *temp = [CCAnimate actionWithAnimation:walkLeftRepeat];
    CCAnimate *temp2 = [CCRepeatForever actionWithAction:temp];
    self.walkLeft = [CCSpeed actionWithAction:temp2 speed:animationWalkingSpeed];
    [_guy runAction:_walkLeft];
    CCLOG(@"fasil");
    CCAnimation *walkingAnimation = [CCAnimation animationWithSpriteFrames:walkingFrames delay:0.01f];
    CCAnimate *temp3 = [CCAnimate actionWithAnimation:walkingAnimation];
    CCAnimate *temp4 = [CCRepeatForever actionWithAction:temp3];
    self.walkAction = [CCSpeed actionWithAction:temp4 speed:animationWalkingSpeed];
    
    jumpingFrames = [[NSMutableArray alloc] init];
    for(int i =1; i<7; i++){
        
        [jumpingFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"JumpRight-00%d.tif", i]]];
    }
    CCAnimation *jumpingAnimation = [CCAnimation animationWithSpriteFrames:jumpingFrames delay:0.04f];
    self.jumpAction = [CCAnimate actionWithAnimation:jumpingAnimation];
    
    NSMutableArray *jumpingFramesLeft = [[NSMutableArray alloc] init];
    for(int i =1; i<7; i++){
        
        [jumpingFramesLeft addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"JumpLeft-00%d.tif", i]]];
    }
    CCAnimation *jumpingLeftAnimation = [CCAnimation animationWithSpriteFrames:jumpingFramesLeft delay:0.04f];
    self.jumpLeft = [CCAnimate actionWithAnimation:jumpingLeftAnimation];
    
    
}


-(void) setPlatforms{
    
    
    //scrolling background stuff
    background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
    swapBackground = [CCSprite spriteWithSpriteFrameName:@"background.png"];
    
    parallax = [CCParallaxScrollNode makeWithBatchFile:@"sprites"];
    
    [parallax addInfiniteScrollYWithZ:0 Ratio:ccp(0.5,0.5) Pos:ccp(0,0) Objects:background, swapBackground, nil];
    
    [self addChild:parallax z:-1000 tag:1];
    
    //Adding enemy
    
    for(int i = 0; i<10; i++) {
        CCSprite* enemy = [CCSprite spriteWithSpriteFrameName:@"asteroid_sm.png"];
        enemy.visible = NO;
        [batch addChild:enemy z:1 tag:enemyTag];
    }
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"rocket.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"explode.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"coin.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"bonus.wav"];
    CCSprite *halfGravity = [CCSprite spriteWithSpriteFrameName:@"0.5g.png"];
    CCSprite *twiceGravity = [CCSprite spriteWithSpriteFrameName:@"2g.png"];
    CCSprite *twoMultiplier = [CCSprite spriteWithSpriteFrameName:@"2x.png"];
    CCSprite *threeMultiplier = [CCSprite spriteWithSpriteFrameName:@"3x.png"];
    CCSprite *fourMultiplier = [CCSprite spriteWithSpriteFrameName:@"4x.png"];
    CCSprite *magnet = [CCSprite spriteWithSpriteFrameName:@"magnet.png"];
    CCSprite *life = [CCSprite spriteWithSpriteFrameName:@"life.png"];
    CCSprite *infinity = [CCSprite spriteWithSpriteFrameName:@"infinity.png"];
    CCSprite *boost = [CCSprite spriteWithSpriteFrameName:@"jetpack.png"];
    
    halfGravity.visible = NO;
    twiceGravity.visible = NO;
    twoMultiplier.visible = NO;
    threeMultiplier.visible = NO;
    fourMultiplier.visible = NO;
    magnet.visible = NO;
    life.visible = NO;
    infinity.visible= NO;
    boost.visible = NO;
    
    CCSprite *halfGravityDisplay = [CCSprite spriteWithSpriteFrameName:@"0.5g.png"];
    CCSprite *twiceGravityDisplay = [CCSprite spriteWithSpriteFrameName:@"2g.png"];
    CCSprite *twoMultiplierDisplay = [CCSprite spriteWithSpriteFrameName:@"2x.png"];
    CCSprite *threeMultiplierDisplay = [CCSprite spriteWithSpriteFrameName:@"3x.png"];
    CCSprite *fourMultiplierDisplay = [CCSprite spriteWithSpriteFrameName:@"4x.png"];
    CCSprite *magnetDisplay = [CCSprite spriteWithSpriteFrameName:@"magnet.png"];
    CCSprite *lifeDisplay = [CCSprite spriteWithSpriteFrameName:@"life.png"];
    CCSprite *infinityDisplay = [CCSprite spriteWithSpriteFrameName:@"infinity.png"];
    
    halfGravityDisplay.position = ccp(20, halfGravity.contentSize.height/2 + 1);
    twiceGravityDisplay.position = ccp(20,halfGravity.contentSize.height/2 + 1);
    twoMultiplierDisplay.position = ccp(65,halfGravity.contentSize.height/2 + 1);
    threeMultiplierDisplay.position = ccp(110,halfGravity.contentSize.height/2 + 1);
    fourMultiplierDisplay.position = ccp(155,halfGravity.contentSize.height/2 + 1);
    magnetDisplay.position = ccp(200,halfGravity.contentSize.height/2 + 1);
    lifeDisplay.position = ccp(245,halfGravity.contentSize.height/2 + 1);
    infinityDisplay.position = ccp(290,halfGravity.contentSize.height/2 + 1);
    
    
    halfGravityDisplay.visible = NO;
    twiceGravityDisplay.visible = NO;
    twoMultiplierDisplay.visible = NO;
    threeMultiplierDisplay.visible = NO;
    magnetDisplay.visible = NO;
    lifeDisplay.visible = NO;
    infinityDisplay.visible = NO;
    fourMultiplierDisplay.visible = NO;
    
    [batch addChild:halfGravityDisplay z:500 tag:halfGravityDisplayTag];
    [batch addChild:twiceGravityDisplay z:500 tag:twiceGravityDisplayTag];
    [batch addChild:twoMultiplierDisplay z:500 tag:twoTimesMultiplierDisplayTag];
    [batch addChild:threeMultiplierDisplay z:500 tag:threeTimesMultiplierDisplayTag];
    [batch addChild:fourMultiplierDisplay z:500 tag:fourTimeMultiplierDisplayTag];
    [batch addChild:lifeDisplay z:500 tag:lifeDisplayTag];
    [batch addChild:infinityDisplay z:500 tag:infinityDisplayTag];
    [batch addChild:magnetDisplay z:500 tag:magnetDisplayTag];
    
    [batch addChild:halfGravity z:20 tag:halfGravityTag];
    [batch addChild:twiceGravity z:20 tag:twiceGravityTag];
    [batch addChild:twoMultiplier z:20 tag:twoTimesMultiplierTag];
    [batch addChild:threeMultiplier z:20 tag:threeTimesMultiplierTag];
    [batch addChild:fourMultiplier z:20 tag:fourTimeMultiplierTag];
    [batch addChild:magnet z:20 tag:magnetTag];
    [batch addChild:boost z:20 tag:boostTag];
    [batch addChild:life z:20 tag:lifeTag];
    [batch addChild:infinity z:20 tag:infinityTag];
    
    
    for(int i = 0; i<5; i++){
        CCSprite* ball = [CCSprite spriteWithSpriteFrameName:@"goldcoin.png"];
        ball.visible = NO;
        [batch addChild:ball z:1 tag:ballTagPlatform1];
    }
    
    for(int i = 0; i<5; i++){
        CCSprite* ball = [CCSprite spriteWithSpriteFrameName:@"goldcoin.png"];
        ball.visible = NO;
        [batch addChild:ball z:1 tag:ballTagPlatform2];
    }
    for(int i = 0; i<5; i++){
        CCSprite* ball = [CCSprite spriteWithSpriteFrameName:@"goldcoin.png"];
        ball.visible = NO;
        [batch addChild:ball z:1 tag:ballTagPlatform3];
    }
    for(int i = 0; i<5; i++){
        CCSprite* ball = [CCSprite spriteWithSpriteFrameName:@"goldcoin.png"];
        ball.visible = NO;
        [batch addChild:ball z:1 tag:ballTagPlatform4];
    }
    //adding platforms
    for(int i =0; i<8; i++)
    {
        CCSprite* platform = [CCSprite spriteWithSpriteFrameName:@"platform1.png"];
        platform.visible = NO;
        platformHeight = platform.contentSize.height;
        platformWidth = platform.contentSize.width;
        [batch addChild:platform z:1 tag:platform1];
        
        
    }
    
    for(int i =0; i<8; i++)
    {
        CCSprite *platform = [CCSprite spriteWithSpriteFrameName:@"platform2.png"];
        platform.visible = NO;
        [batch addChild:platform z:1 tag:platform2];
    }
    
    
    for(int i =0; i<8; i++)
    {
        CCSprite *platform = [CCSprite spriteWithSpriteFrameName:@"platform3.png"];
        platform.visible = NO;
        [batch addChild:platform z:1 tag:platform3];
        
    }
    
    
    
    for(int i =0; i<8; i++)
    {
        CCSprite *platform = [CCSprite spriteWithSpriteFrameName:@"platform4.png"];
        platform.visible = NO;
        CCParticleFire *fire = [[CCParticleFire alloc]init];
        [fire stopSystem];
        [batch addChild:platform z:1 tag:platform4];
        [self addChild:fire z:-200 tag:particleTag];
        
    }
}
-(CGPoint)setPlatformStartingPosition:(int)platformType{
    float lastPlatformHeight = [self platformHeight];
    
    if(platformType == platform4){
        CGFloat y = abs((CGFloat)(arc4random()%10));
        CGFloat x = (CGFloat)(arc4random()%40);
        CGPoint place = CGPointMake(-(60+x), lastPlatformHeight+y+70);
        return place;
    }
    else if(platformType == platform3){
        CGFloat x = (CGFloat)(arc4random()%40);
        CGFloat y = abs((CGFloat)(arc4random()%10));
        CGPoint place = CGPointMake(260+x, y+lastPlatformHeight+70);
        return place;
    }
    else if(platformType == platform2){
        CGFloat x = (CGFloat)(arc4random()%40);
        CGFloat y = abs((CGFloat)(arc4random()%10));
        CGPoint place = CGPointMake(x+500, y+lastPlatformHeight+70);
        return place;
    }
    else{
        CGFloat x = (CGFloat)(arc4random()%40);
        CGFloat y = abs((CGFloat)(arc4random()%10));
        CGPoint place = CGPointMake(x+420, y+lastPlatformHeight+70);
        
        return place;
    }
    
}
-(void)launchEnemy{
    for(CCNode *child in batch.children){
        if(child.tag == enemyTag && child.visible == NO){
            child.visible = YES;
            float x = arc4random()%320;
            child.position = ccp(x, [CCDirector sharedDirector].winSize.height+15);
            CCParticleFire *fire = [[CCParticleFire alloc]init];
            fire.position = ccp(child.position.x, child.position.y+10);
            fire.life=0.5;
            [fire setEmissionRate:300];
            [fire setScaleX:0.3];
            fire.autoRemoveOnFinish = YES;
            CCMoveTo *action = [CCMoveTo actionWithDuration:3.35 position:ccp(child.position.x, -400)];
            [fire runAction:action];
            [self addChild:fire z:-50 tag:particleTag];
            
            
            break;
        }
    }
}

-(CGPoint)gameStart{
    CGFloat y = ((CGFloat)(arc4random()%10));
    CGFloat x = (CGFloat)(arc4random()%40);
    float height = [self platformHeight];
    CGPoint place = CGPointMake(x+200, y+height+100);
    return place;
}
-(float)platformHeight{
    float lastPlatformHeight=0;
    int childTag = 100;
    for(CCNode* child in batch.children){
        if(child.visible == YES){
            
            if((child.tag == platform1 || child.tag == platform2 || child.tag == platform3 || child.tag == platform4)){
                if(child.position.y > lastPlatformHeight){
                    lastPlatformHeight = child.position.y;
                    childTag = child.tag;
                }
            }
        }
    }
    return lastPlatformHeight;
}
-(void)setBonusAt:(CGPoint)where onPlatform:(int)platform{
    
    
    int decide = arc4random_uniform(30);
    if(firstStart == 1){
        return;
    }
    if(decide == 0){
        for(CCNode *child in batch.children){
            if(child.tag == twoTimesMultiplierTag){
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = ccp(arc4random_uniform(300), [CCDirector sharedDirector].winSize.height+15);
                    break;
                }
            }
        }
    }
    if(decide == 1){
        for(CCNode *child in batch.children){
            if(child.tag == halfGravityTag) {
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = ccp(arc4random_uniform(300), [CCDirector sharedDirector].winSize.height+15);
                    break;
                }
            }
        }
        
    }
    if(decide == 2){
        for(CCNode *child in batch.children){
            if(child.tag == twiceGravityTag) {
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = ccp(arc4random_uniform(300), [CCDirector sharedDirector].winSize.height+15);
                    break;
                }
            }
        }
        
    }
    if(decide == 3){
        for(CCNode *child in batch.children){
            if(child.tag == threeTimesMultiplierTag) {
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = ccp(arc4random_uniform(300), [CCDirector sharedDirector].winSize.height+15);
                    break;
                }
            }
        }
        
    }
    if(decide == 4){
        for(CCNode *child in batch.children){
            if(child.tag == fourTimeMultiplierTag) {
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = ccp(arc4random_uniform(300), [CCDirector sharedDirector].winSize.height+15);
                    break;
                }
            }
        }
        
    }
    if(decide == 5 && boostOn == NO){
        decide = arc4random_uniform(4);
        if(decide == 1){
            for(CCNode *child in batch.children){
                if(child.tag == boostTag) {
                    if(child.visible == NO){
                        child.visible = YES;
                        child.position = ccp(arc4random_uniform(300), -15);
                        break;
                    }
                }
            }
        }
        
    }
    
    if(decide == 6 && lifeOn == NO){
        for(CCNode *child in batch.children){
            if(child.tag == lifeTag) {
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = ccp(arc4random_uniform(300), [CCDirector sharedDirector].winSize.height+15);
                    break;
                }
            }
        }
        
    }
    if(decide == 7 ){
        for(CCNode *child in batch.children){
            if(child.tag == magnetTag) {
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = ccp(arc4random_uniform(300), [CCDirector sharedDirector].winSize.height+15);
                    break;
                }
            }
        }
        
    }
    if(decide == 8){
        for(CCNode *child in batch.children){
            if(child.tag == infinityTag) {
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = ccp(arc4random_uniform(300), [CCDirector sharedDirector].winSize.height+15);
                    break;
                }
            }
        }
        
    }
    
    for(CCNode *child in batch.children){
        if(child.tag == platform+4){
            if(child.visible == NO){
                child.visible = YES;
                child.position = ccp(where.x, where.y+15);
                break;
            }
        }
    }
    for(CCNode *child in batch.children){
        if(child.tag == platform+4){
            if(child.visible == NO){
                child.visible = YES;
                child.position = ccp(where.x+25, where.y+15);
                break;
            }
        }
    }
    for(CCNode *child in batch.children){
        if(child.tag == platform+4){
            if(child.visible == NO){
                child.visible = YES;
                child.position = ccp(where.x-25, where.y+15);
                break;
            }
        }
    }
}

-(void)setNewPlatform{
    int platformType = arc4random()%4 +5;
    int bonus = arc4random()%3;
    bool placeBonus = NO;
    if(bonus==0 || bonus == 1){
        placeBonus = YES;
    }
    
    
    
    if(platformType == platform1){
        for(CCNode *child in batch.children){
            if(child.tag == platform1){
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = [self setPlatformStartingPosition:platform1];
                    if(placeBonus == YES) [self setBonusAt:CGPointMake(child.position.x, child.position.y + child.contentSize.height/2) onPlatform:platform1];
                    break;
                }
            }
        }
    }
    else if(platformType == platform2){
        for(CCNode *child in batch.children){
            if(child.tag == platform2){
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = [self setPlatformStartingPosition:platform2];
                    if(placeBonus == YES) [self setBonusAt:CGPointMake(child.position.x, child.position.y + child.contentSize.height/2) onPlatform:platform2];
                    break;
                }
            }
        }
    }
    else if(platformType == platform3){
        for(CCNode *child in batch.children){
            if(child.tag == platform3){
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = [self setPlatformStartingPosition:platform3];
                    if(placeBonus == YES) [self setBonusAt:CGPointMake(child.position.x, child.position.y + child.contentSize.height/2) onPlatform:platform3];
                    break;
                }
            }
        }
    }
    
    else if(platformType == platform4){
        for(CCNode *child in batch.children){
            if(child.tag == platform4){
                if(child.visible == NO){
                    child.visible = YES;
                    child.position = [self setPlatformStartingPosition:platform4];
                    if(placeBonus == YES) [self setBonusAt:CGPointMake(child.position.x, child.position.y + child.contentSize.height/2) onPlatform:platform4];
                    break;
                }
            }
        }
    }
}

-(bool)checkGameOver{
    CGSize size = [CCDirector sharedDirector].winSize;

    if(inifinityOn == NO && lifeOn == NO){
        if(_guy.position.x<(-_guy.contentSize.width/2) || _guy.position.x>size.width+_guy.contentSize.width/2 ||  _guy.position.y<0){
            endLabel.visible = YES;
            return true;
        }
    }
    else if(inifinityOn == YES && lifeOn == YES){
        if(_guy.position.x<(-1*_guy.contentSize.width)){
            _guy.position = ccpAdd(_guy.position, ccp(size.width+_guy.contentSize.width, 0));
        }
        if(_guy.position.x>size.width+_guy.contentSize.width){
            _guy.position = ccp((-1*_guy.contentSize.width),_guy.position.y);
        }
        if(_guy.position.y<0){
            velY = 800;
            lifeOn = NO;
            CCNode *temp = [batch getChildByTag:lifeDisplayTag];
            temp.visible = NO;
        }
    }
    else if(inifinityOn == YES){
        if(_guy.position.x<(-1*_guy.contentSize.width)){
            _guy.position = ccpAdd(_guy.position, ccp(size.width+_guy.contentSize.width, 0));
        }
        if(_guy.position.x>size.width+_guy.contentSize.width){
            _guy.position = ccp((-1*_guy.contentSize.width),_guy.position.y);
        }
        if(_guy.position.y<-_guy.contentSize.height){
            endLabel.visible = YES;
            return true;
            
        }
    }
    else if(lifeOn == YES){
        if(_guy.position.y<0){
            velY = 800;
            lifeOn = NO;
            CCNode *temp = [batch getChildByTag:lifeDisplayTag];
            temp.visible = NO;
        }
    }
    
    
    
    return false;
}
-(void)clearAllItems{
    for(CCNode* child in batch.children){
        if(child.tag != permanantDisplayTag){
            child.visible = NO;
        }
        else{
            continue;
        }
        if(child.tag != twoTimesMultiplierDisplayTag && child.tag != threeTimesMultiplierDisplayTag && child.tag != fourTimeMultiplierDisplayTag && child.tag != twiceGravityDisplayTag && child.tag != halfGravityDisplayTag && child.tag != magnetDisplayTag && child.tag != infinityDisplayTag && child.tag != lifeDisplayTag ){
            child.position = ccp(0,0);
        }
    }
    for(CCNode *child in self.children){
        CCLOG(@"child tag: %d: ", child.tag);
        if(child.tag == particleTag){
            CCLOG(@"fireFound");
            child.visible = NO;
        }
    }
    bonusLabel.visible = NO;
    [self unscheduleAllSelectors];
    
}
-(void)resetPlatforms{
    
    
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    for(CCNode *child in batch.children){
        if(child.tag == platform1){
            child.visible = YES;
            child.position = CGPointMake(size.width/2, 100-child.contentSize.height/2-_guy.contentSize.height/2);
            
            break;
        }
    }
    for(int i = 0; i<6; i++){
        int bonus = arc4random()%2;
        bool placeBonus = NO;
        if(bonus==0){
            placeBonus = YES;
        }
        int x = arc4random()%4 +5;
        if(x==platform1){
            for(CCNode *child in batch.children){
                if(child.tag == platform1){
                    if(child.visible == NO){
                        child.visible = YES;
                        
                        child.position = [self gameStart];
                        if(placeBonus == YES) [self setBonusAt:CGPointMake(child.position.x, child.position.y + child.contentSize.height/2) onPlatform:platform1];
                        firstStart = 1;
                        
                        break;
                    }
                }
            }
        }
        if(x==platform2){
            for(CCNode *child in batch.children){
                if(child.tag == platform2){
                    if(child.visible == NO){
                        child.visible = YES;
                        child.position = [self gameStart];
                        if(placeBonus == YES) [self setBonusAt:CGPointMake(child.position.x, child.position.y + child.contentSize.height/2) onPlatform:platform2];
                        firstStart = 1;
                        break;
                    }
                }
            }
        }
        if(x==platform3){
            for(CCNode *child in batch.children){
                if(child.tag == platform3){
                    if(child.visible == NO){
                        child.visible = YES;
                        child.position = [self gameStart];
                        if(placeBonus == YES) [self setBonusAt:CGPointMake(child.position.x, child.position.y + child.contentSize.height/2) onPlatform:platform3];
                        firstStart = 1;
                        break;
                    }
                }
            }
        }
        if(x==platform4){
            for(CCNode *child in batch.children){
                if(child.tag == platform4){
                    if(child.visible == NO){
                        child.visible = YES;
                        child.position = [self gameStart];
                        if(placeBonus == YES) [self setBonusAt:CGPointMake(child.position.x, child.position.y + child.contentSize.height/2) onPlatform:platform4];
                        firstStart = 1;
                        break;
                    }
                }
            }
        }
        
        
    }
    
    firstStart = 0;
}
-(void)updateGuy:(ccTime)delta{
    
    CGPoint newPosition;
    CGPoint oldPostion = _guy.position;
    if(boostOn == YES){
   
        newPosition.x = oldPostion.x + accelerationX*delta;
        _guy.position = ccp(newPosition.x, _guy.position.y);
        velX = (newPosition.x - oldPostion.x)/delta;
        if(velX<0){
            [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"leftBoost.png"]];
        }
        else{
            [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"rightBoost.png"]];
        }
    }
    else{
        if(_guy.numberOfRunningActions == 0){
            if(velX>0){
                [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JumpRight-006.tif"]];
                
            }
            if(velX<0){
                [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JumpLeft-006.tif"]];
                
            }
            if(firstJump == YES && secondJump == NO){
                velY = 350 + (progressTimer.percentage);
                progressTimer.percentage-=5;
                onPlatform = NO;
                secondJump = YES;
                jumping = NO;
                
                
            }
            
        }
        
        if(jumping == NO){
            if(onPlatform == NO){
                newPosition.y = oldPostion.y + velY*delta + 0.5*gravity*delta*delta;
                newPosition.x = oldPostion.x + accelerationX*delta;
                _guy.position = ccp(newPosition.x, newPosition.y);
                velY +=  gravity*delta;
                velX = (newPosition.x - oldPostion.x)/delta;
            }
            else if(onPlatformType == platform1){
                newPosition.y = oldPostion.y - platformVerticalVel*delta;
                newPosition.x = oldPostion.x + accelerationX*delta;
                _guy.position = newPosition;
                velY = platformVerticalVel;
                
                platformXPosition += platformOneHorizontalVel*delta;
                if((abs(_guy.position.x-platformXPosition)>platformWidth/2)){
                    onPlatform = NO;
                    firstJump = YES;
                    secondJump = YES;
                    jumpAgain = YES;
                    [_guy stopAllActions];
                    
                    if(velX>0){
                        [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JumpRight-006.tif"]];
                    }
                    if(velX<0){
                        [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JumpLeft-006.tif"]];
                    }
                    
                }
            }
            else if(onPlatformType == platform2){
                newPosition.y = oldPostion.y - platformVerticalVel*delta;
                newPosition.x = oldPostion.x +  accelerationX*delta;
                _guy.position = newPosition;
                velY = platformVerticalVel;
                platformXPosition += platformTwoHorizontalVel*delta;
                
                if((abs(_guy.position.x-platformXPosition)>platformWidth/2)){
                    onPlatform = NO;
                    firstJump = YES;
                    secondJump = YES;
                    jumpAgain = YES;
                    [_guy stopAllActions];
                    if(velX>0){
                        [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JumpRight-006.tif"]];
                    }
                    if(velX<0){
                        [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JumpLeft-006.tif"]];
                    }
                    
                }
            }
            else if(onPlatformType == platform3){
                newPosition.y = oldPostion.y - platformVerticalVel*delta;
                newPosition.x = oldPostion.x +  accelerationX*delta;
                _guy.position = newPosition;
                velY = platformVerticalVel;
                platformXPosition += platformThreeHorizontalVel*delta;
                if((abs(_guy.position.x-platformXPosition)>platformWidth/2)){
                    onPlatform = NO;
                    firstJump = YES;
                    secondJump = YES;
                    jumpAgain = YES;
                    [_guy stopAllActions];
                    if(velX>0){
                        [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JumpRight-006.tif"]];
                    }
                    if(velX<0){
                        [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JumpLeft-006.tif"]];
                    }
                    
                }
            }
            else if(onPlatformType == platform4){
                newPosition.y = oldPostion.y - platformVerticalVel*delta;
                newPosition.x = oldPostion.x +  accelerationX*delta;
                _guy.position = newPosition;
                velY = platformVerticalVel;
                platformXPosition += platformFourHorizontalVel*delta;
                if((abs(_guy.position.x-platformXPosition)>platformWidth/2)){
                    onPlatform = NO;
                    firstJump = YES;
                    secondJump = YES;
                    jumpAgain = YES;
                    [_guy stopAllActions];
                    if(velX>0){
                        [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JumpRight-006.tif"]];
                    }
                    if(velX<0){
                        [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JumpLeft-006.tif"]];
                    }
                    
                }
            }
            if(changeDirectionToRight == YES && onPlatform == YES){
                [_guy stopAllActions];
                [_guy runAction:_walkAction];
                changeDirectionToLeft = NO;
                changeDirectionToRight = NO;
            }
            if(changeDirectionToLeft == YES && onPlatform == YES){
                [_guy stopAllActions];
                [_guy runAction:_walkLeft];
                changeDirectionToLeft = NO;
                changeDirectionToRight = NO;
            }
            
            velX = (newPosition.x - oldPostion.x)/delta;
            
            switch(onPlatformType){
                case 5: oldVelX = platformOneHorizontalVel;
                    break;
                case 6: oldVelX = platformTwoHorizontalVel;
                    break;
                case 7: oldVelX = platformThreeHorizontalVel;
                    break;
                case 8: oldVelX = platformFourHorizontalVel;
                    break;
            }
            
            if(oldVelX - velX<0){
                if(guyWalkingRight == NO){
                    changeDirectionToRight = YES;
                    changeDirectionToLeft = NO;
                    guyWalkingRight = YES;
                    guyWalkingLeft = NO;
                }
            }
            if(oldVelX-velX>0){
                if(guyWalkingLeft == NO){
                    changeDirectionToLeft = YES;
                    changeDirectionToRight = NO;
                    guyWalkingLeft = YES;
                    guyWalkingRight = NO;
                }
            }
        }
    }

    
}
- (void)timerForGravity:(ccTime) delta {
    
    gravity = -800.0f;
    [self unschedule:@selector(timerForGravity:)];
    CCNode *temp = [batch getChildByTag:twiceGravityDisplayTag];
    CCNode *temp2 = [batch getChildByTag:halfGravityDisplayTag];
    temp.visible = NO;
    temp2.visible = NO;
    
    
    
}
- (void)timerForHighscoreTwo:(ccTime) delta {
    
    bonusMultiplier -= 2;
    CCNode *temp = [batch getChildByTag:twoTimesMultiplierDisplayTag];
    temp.visible = NO;
    [self unschedule:@selector(timerForHighscoreTwo:)];
    
    
}
- (void)timerForInfinity:(ccTime) delta {
    
  
    CCNode *temp = [batch getChildByTag:infinityDisplayTag];
    temp.visible = NO;
    inifinityOn = NO;
    [self unschedule:@selector(timerForInfinity:)];
    
    
}
- (void)timerForMagnet:(ccTime) delta {
    
   
    CCNode *temp = [batch getChildByTag:magnetDisplayTag];
    temp.visible = NO;
    [self unschedule:@selector(timerForMagnet:)];
    magnetOn = NO;
    
    
}
- (void)timerForBoost:(ccTime) delta {
    boostOn = NO;
    onPlatform = NO;
    [self unschedule:@selector(timerForBoost:)];
    velY += 600;
    CCLOG(@"timer");
    platformVerticalVel = oldPlatformVeticalVel;
    platformFourHorizontalVel = oldPlatformFourHorizontal;
    platformOneHorizontalVel = oldPlatformOneHorizontal;
    platformThreeHorizontalVel = oldPlatformThreeHorizontal;
    platformTwoHorizontalVel = oldPlatformTwoHorizontal;
    
    
}
- (void)timerForHighscoreThree:(ccTime) delta {
    
    bonusMultiplier -= 3;
    CCNode *temp = [batch getChildByTag:threeTimesMultiplierDisplayTag];
    temp.visible = NO;
    [self unschedule:@selector(timerForHighscoreThree:)];
    
    
}
- (void)timerForHighscoreFour:(ccTime) delta {
    
    bonusMultiplier -= 4;
    CCNode *temp = [batch getChildByTag:fourTimeMultiplierDisplayTag];
    temp.visible = NO;
    [self unschedule:@selector(timerForHighscoreFour:)];
    
    
}
-(void)updateBatch:(ccTime)delta{
    if(boostOn){
        CCLOG(@"platformVel: %f", platformVerticalVel);
    }

    for(CCNode* child in batch.children){
        if(child.visible == YES){
            if(child.tag == enemyTag){
                child.position = ccp(child.position.x, child.position.y-(asteroidSpeed)*delta);
                CGRect enemy = child.boundingBox;
                
                if(CGRectContainsPoint(enemy, _guy.position)){
                    start = NO;
                    NSLog(@"died");
                    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
                    [self unscheduleUpdate];
                    [self schedule:@selector(endGame:) interval:0.1f];
                }
                if(child.position.y<-15){
                    child.visible = NO;
                }
                continue;
            }
            
            if(child.tag == twiceGravityTag){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.wav"];
                    float delay = 5.0; // Number of seconds between each call of myTimedMethod:
                    CCNode *temp = [batch getChildByTag:twiceGravityDisplayTag];
                    CCLOG(@"temp visible: %d", temp.visible);
                    if(temp.visible == YES){
                        [self unschedule:@selector(timerForGravity:)];
                    }
                    else{
                        gravity = -1400.0f;
                        temp.visible = YES;
                        CCLOG(@"temp visible: %d", temp.visible);
                    }
                    [self schedule:@selector(timerForGravity:) interval:delay];
                    
                    child.visible = NO;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x, child.position.y-delta*platformVerticalVel*1.5);
                    continue;
                }
            }
            if(child.tag == halfGravityTag){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    float delay = 5.0; // Number of seconds between each call of myTimedMethod:
                    [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.wav"];
                    CCNode *temp = [batch getChildByTag:halfGravityDisplayTag];
                    CCLOG(@"temp visible: %d", temp.visible);
                    if(temp.visible == YES){
                        [self unschedule:@selector(timerForGravity:)];
                    }
                    else{
                        gravity = -400.0f;
                        
                        temp.visible = YES;
                        CCLOG(@"temp visible: %d", temp.visible);
                    }
                    [self scheduleOnce:@selector(timerForGravity:) delay:delay];
                    child.visible = NO;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x, child.position.y-delta*platformVerticalVel*1.5);
                    continue;
                }
            }
            if(child.tag == twoTimesMultiplierTag){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    float delay = 10.0; // Number of seconds between each call of myTimedMethod:
                    [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.wav"];
                    CCNode *temp = [batch getChildByTag:twoTimesMultiplierDisplayTag];
                    CCLOG(@"temp visible: %d", temp.visible);
                    if(temp.visible == YES){
                        [self unschedule:@selector(timerForHighscoreTwo:)];
                    }
                    else{
                        bonusMultiplier += 2;
                        temp.visible = YES;
                        CCLOG(@"temp visible: %d", temp.visible);
                    }
                    [multiplierLabel setString:[NSString stringWithFormat:@"x%d", bonusMultiplier*globalMultiplier]];
                    [self schedule:@selector(timerForHighscoreTwo:) interval:delay];
                    child.visible = NO;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x, child.position.y-delta*platformVerticalVel*1.5);
                    continue;
                }
            }
            if(child.tag == threeTimesMultiplierTag){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    float delay = 10.0; // Number of seconds between each call of myTimedMethod:
                    [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.wav"];
                    CCNode *temp = [batch getChildByTag:threeTimesMultiplierDisplayTag];
                    CCLOG(@"temp visible: %d", temp.visible);
                    if(temp.visible == YES){
                        [self unschedule:@selector(timerForHighscoreThree:)];
                    }
                    else{
                        bonusMultiplier += 3;
                        temp.visible = YES;
                        CCLOG(@"temp visible: %d", temp.visible);
                    }
                    [multiplierLabel setString:[NSString stringWithFormat:@"x%d", bonusMultiplier*globalMultiplier]];
                    [self schedule:@selector(timerForHighscoreThree:) interval:delay];
                    child.visible = NO;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x, child.position.y-delta*platformVerticalVel*1.5);
                    continue;
                }
            }
            if(child.tag == fourTimeMultiplierTag){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    float delay = 10.0; // Number of seconds between each call of myTimedMethod:
                    [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.wav"];
                    CCNode *temp = [batch getChildByTag:fourTimeMultiplierDisplayTag];
                
                    if(temp.visible == YES){
                        [self unschedule:@selector(timerForHighscoreFour:)];
                    }
                    else{
                        bonusMultiplier += 4;
                        temp.visible = YES;
                        CCLOG(@"temp visible: %d", temp.visible);
                    }
                    [multiplierLabel setString:[NSString stringWithFormat:@"x%d", bonusMultiplier*globalMultiplier]];
                    [self schedule:@selector(timerForHighscoreFour:) interval:delay];
                    
                    child.visible = NO;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x, child.position.y-delta*platformVerticalVel*1.5);
                    continue;
                }
            }
            if(child.tag == lifeTag){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.wav"];
                    CCNode *temp = [batch getChildByTag:lifeDisplayTag];
                  
                    temp.visible = YES;
                    child.visible = NO;
                    lifeOn = YES;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x, child.position.y-delta*platformVerticalVel*1.5);
                    continue;
                }
                
            }
            if(child.tag == infinityTag){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    float delay = 10.0; // Number of seconds between each call of myTimedMethod:
                    [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.wav"];
                    CCNode *temp = [batch getChildByTag:infinityDisplayTag];
                  
                    child.visible = NO;
                    inifinityOn = YES;
                    if(temp.visible == YES){
                        [self unschedule:@selector(timerForInfinity:)];
                    }
                    else{
                       
                        temp.visible = YES;
                        
                    }
                    ;
                    [self schedule:@selector(timerForInfinity:) interval:delay];
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x, child.position.y-delta*platformVerticalVel*1.5);
                    continue;
                }
                
            }
            if(child.tag == magnetTag){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    float delay = 10.0; // Number of seconds between each call of myTimedMethod:
                    [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.wav"];
                    CCNode *temp = [batch getChildByTag:magnetDisplayTag];
                   
                    child.visible = NO;
                    magnetOn = YES;
                    if(temp.visible == YES){
                        [self unschedule:@selector(timerForMagnet:)];
                    }
                    else{
                        temp.visible = YES;
                    }
                    ;
                    [self schedule:@selector(timerForMagnet:) interval:delay];
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x, child.position.y-delta*platformVerticalVel*1.5);
                    continue;
                }
                
            }
            if(child.tag == boostTag){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    float delay = 10;
                    if(boostOn == NO){
                        [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.wav"];
                        [[SimpleAudioEngine sharedEngine] playEffect:@"rocket.wav"];
                        boostOn = YES;
                        [_guy stopAllActions];
                        if(velX<0){
                            [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"leftBoost.png"]];
                        }
                        else{
                            [_guy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"rightBoost.png"]];
                        }
                        
                        oldPlatformVeticalVel = platformVerticalVel;
                      
                        oldPlatformOneHorizontal = platformOneHorizontalVel;
                        oldPlatformTwoHorizontal = platformTwoHorizontalVel;
                        oldPlatformThreeHorizontal = platformThreeHorizontalVel;
                        oldPlatformFourHorizontal = platformFourHorizontalVel;
                        platformFourHorizontalVel += 200;
                        platformOneHorizontalVel -=200;
                        platformThreeHorizontalVel -=200;
                        platformFourHorizontalVel -=200;
                        
                        platformVerticalVel += 400;
                  
                        
                    } else{
                        [self unschedule:@selector(timerForBoost:)];
                    }
                    [self schedule:@selector(timerForBoost:) interval:delay];
                    child.visible = NO;
                }
                if(child.position.y>600){
                    child.visible = NO;
                    continue;
                }
                else{
                    child.position = ccpAdd(child.position, ccp(0, delta*80));
                }
                
            }
            
            if(child.tag == foodTagPlatform1){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    progressTimer.percentage+=10;
                    child.visible = NO;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x+delta*platformOneHorizontalVel, child.position.y-delta*platformVerticalVel);
                    continue;
                }
            }
            if(child.tag == foodTagPlatform2){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    progressTimer.percentage+=10;
                    child.visible = NO;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x+delta*platformTwoHorizontalVel, child.position.y-delta*platformVerticalVel);
                    continue;
                }
            }
            if(child.tag == foodTagPlatform3){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    progressTimer.percentage+=10;
                    child.visible = NO;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x+delta*platformThreeHorizontalVel, child.position.y-delta*platformVerticalVel);
                    continue;
                }
            }
            if(child.tag == foodTagPlatform4){
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    progressTimer.percentage+=10;
                    child.visible = NO;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x+delta*platformFourHorizontalVel, child.position.y-delta*platformVerticalVel);
                    continue;
                }
            }
            if(child.tag == ballTagPlatform1){
                if(abs(_guy.position.x-child.position.x)<200 && abs(_guy.position.y-child.position.y)<200 && magnetOn == YES){
                    if(child.numberOfRunningActions == 0){
                        CCAction *move = [CCMoveTo actionWithDuration:0.3 position:_guy.position];
                        [child runAction:move];
                    }
                }
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    child.visible = NO;
                    [[SimpleAudioEngine sharedEngine] playEffect:@"coin.wav"];
                    bonusLabel.visible = YES;
                    [bonusLabel stopAllActions];
                    
                    score += 100*globalMultiplier*bonusMultiplier;
                    [multiplierLabel setString:[NSString stringWithFormat:@"x%d", globalMultiplier*bonusMultiplier]];
                    [bonusLabel setString:[NSString stringWithFormat:@"+%d", 100*globalMultiplier*bonusMultiplier]];
                    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.3 scale:2];
                    CCScaleTo *scaleDown = [CCScaleTo actionWithDuration:0.3 scale:0.5];
                    CCSequence *sequence = [CCSequence actionOne:scaleUp two:scaleDown];
                    [bonusLabel runAction:sequence];
                    globalMultiplier++;
                    [rain resetSystem];
                    continue;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    globalMultiplier=1;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x+delta*platformOneHorizontalVel, child.position.y-delta*platformVerticalVel);
                    continue;
                }
            }
            if(child.tag == ballTagPlatform2){
                if(abs(_guy.position.x-child.position.x)<200 && abs(_guy.position.y-child.position.y)<200 && magnetOn == YES){
                    if(child.numberOfRunningActions == 0){
                        CCAction *move = [CCMoveTo actionWithDuration:0.3 position:_guy.position];
                        [child runAction:move];
                    }
                }
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    child.visible = NO;
                    [[SimpleAudioEngine sharedEngine] playEffect:@"coin.wav"];
                    bonusLabel.visible = YES;
                    [bonusLabel stopAllActions];
                    [multiplierLabel setString:[NSString stringWithFormat:@"x%d", globalMultiplier*bonusMultiplier]];
                    [bonusLabel setString:[NSString stringWithFormat:@"+%d", 100*globalMultiplier*bonusMultiplier]];
                    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.3 scale:2];
                    CCScaleTo *scaleDown = [CCScaleTo actionWithDuration:0.3 scale:0.5];
                    CCSequence *sequence = [CCSequence actionOne:scaleUp two:scaleDown];
                    [bonusLabel runAction:sequence];
                    score += 100*globalMultiplier*bonusMultiplier;
                    globalMultiplier++;
                    [rain resetSystem];
                    continue;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                    
                {
                    child.visible=NO;
                    globalMultiplier=1;
                    continue;
                    
                }
                else{
                    child.position = ccp(child.position.x+delta*platformTwoHorizontalVel, child.position.y-delta*platformVerticalVel);
                    
                    continue;
                }
                
                
            }
            if(child.tag == ballTagPlatform3){
                if(abs(_guy.position.x-child.position.x)<200 && abs(_guy.position.y-child.position.y)<200 && magnetOn == YES){
                    if(child.numberOfRunningActions == 0){
                        CCAction *move = [CCMoveTo actionWithDuration:0.3 position:_guy.position];
                        [child runAction:move];
                    }
                }
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    child.visible = NO;
                    [[SimpleAudioEngine sharedEngine] playEffect:@"coin.wav"];
                    bonusLabel.visible = YES;
                    [bonusLabel stopAllActions];
                    [multiplierLabel setString:[NSString stringWithFormat:@"x%d", globalMultiplier*bonusMultiplier]];
                    [bonusLabel setString:[NSString stringWithFormat:@"+%d", 100*globalMultiplier*bonusMultiplier]];
                    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.3 scale:2];
                    CCScaleTo *scaleDown = [CCScaleTo actionWithDuration:0.3 scale:0.5];
                    CCSequence *sequence = [CCSequence actionOne:scaleUp two:scaleDown];
                    [bonusLabel runAction:sequence];
                    score += 100*globalMultiplier*bonusMultiplier;
                    globalMultiplier++;
                    [rain resetSystem];
                    continue;
                }
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                    
                {
                    child.visible=NO;
                    globalMultiplier=1;
                    continue;
                    
                }
                else{
                    child.position = ccp(child.position.x+delta*platformThreeHorizontalVel, child.position.y-delta*platformVerticalVel);
                    continue;
                }
                
            }
            if(child.tag == ballTagPlatform4){
                if(abs(_guy.position.x-child.position.x)<200 && abs(_guy.position.y-child.position.y)<200 && magnetOn == YES){
                    if(child.numberOfRunningActions == 0){
                        CCAction *move = [CCMoveTo actionWithDuration:0.3 position:_guy.position];
                        [child runAction:move];
                    }
                }
                
                if(abs(_guy.position.x-child.position.x)<30 && abs(_guy.position.y-child.position.y)<30){
                    child.visible = NO;
                    score += 100*globalMultiplier*bonusMultiplier;
                    [[SimpleAudioEngine sharedEngine] playEffect:@"coin.wav"];
                    [multiplierLabel setString:[NSString stringWithFormat:@"x%d", globalMultiplier*bonusMultiplier]];
                    [bonusLabel setString:[NSString stringWithFormat:@"+%d", 100*globalMultiplier*bonusMultiplier]];
                    globalMultiplier++;
                    [rain resetSystem];
                    bonusLabel.visible = YES;
                    [bonusLabel stopAllActions];
                    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.3 scale:2];
                    CCScaleTo *scaleDown = [CCScaleTo actionWithDuration:0.3 scale:0.5];
                    CCSequence *sequence = [CCSequence actionOne:scaleUp two:scaleDown];
                    [bonusLabel runAction:sequence];
                    continue;
                }
                if(child.position.x>(320+child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    globalMultiplier=1;
                    continue;
                }else{
                    child.position = ccp(child.position.x+delta*platformFourHorizontalVel, child.position.y-delta*platformVerticalVel);
                    continue;
                }
            }
            
            
            if(velY<=0 && (child.tag == platform1 || child.tag == platform2 || child.tag == platform3 || child.tag==platform4) && boostOn == NO){
                
                if(_guy.position.x<child.position.x+child.contentSize.width/2 && _guy.position.x>child.position.x-child.contentSize.width/2){
                    
                    if(abs((_guy.position.y - _guy.contentSize.height/2+15) - (child.position.y+child.contentSize.height/2))<abs(5)){
                        
                        if((_guy.position.y - _guy.contentSize.height/2+25) - (child.position.y+child.contentSize.height/2)>0){
                            
                            onPlatform = true;
                            [_guy stopAllActions];
                            platformXPosition = child.position.x;
                            if(oldVelX - velX<0){
                                [_guy runAction:_walkAction];
                            }else{
                                [_guy runAction:_walkLeft];
                            }
                            secondJump = NO;
                            jumpAgain = YES;
                            firstJump = NO;
                            CGPoint newPosition;
                            CGPoint oldPostion = _guy.position;
                            newPosition.y = child.position.y + child.contentSize.height/2 + _guy.contentSize.height/2;
                            _guy.position = ccp(oldPostion.x, newPosition.y-4);
                            onPlatformType = child.tag;
                        }
                    }
                }
            }
            if(child.tag==platform1){
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }
                else{
                    child.position = ccp(child.position.x+delta*platformOneHorizontalVel, child.position.y-delta*platformVerticalVel);
                    continue;
                }
            }
            if(child.tag==platform2){
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                    
                {
                    child.visible=NO;
                    continue;
                    
                }
                else{
                    child.position = ccp(child.position.x+delta*platformTwoHorizontalVel, child.position.y-delta*platformVerticalVel);
                    
                    continue;
                }
                
            }
            if(child.tag==platform3){
                if(child.position.x<(-child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                    
                {
                    child.visible=NO;
                    continue;
                    
                }
                else{
                    child.position = ccp(child.position.x+delta*platformThreeHorizontalVel, child.position.y-delta*platformVerticalVel);
                    
                    continue;
                }
                
            }
            
            if(child.tag==platform4){
                if(child.position.x>(320+child.contentSize.width/2) || child.position.y<-(child.contentSize.height/2))
                {
                    child.visible=NO;
                    continue;
                }else{
                    child.position = ccp(child.position.x+delta*platformFourHorizontalVel, child.position.y-delta*platformVerticalVel);
                                        continue;
                }
            }
        }
    }
    
}
-(void) endGame:(ccTime)delta{
    [self unschedule:@selector(updateAd:)];
    for(CCNode* child in self.children){
        if(child.tag == particleTag){
            CCParticleFire *fire = (CCParticleFire*)child;
                [self removeChild:fire cleanup:YES];
            
        }
    }
    
    if(endLabel.numberOfRunningActions == 0 && endGameFinished == NO){
    [[SimpleAudioEngine sharedEngine] playEffect:@"over.wav"];
     endLabel.visible = YES;
    
        
   CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:2.0 scale:2.0];
    
    [endLabel runAction:scaleUp];
        [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:2.5 scene:[Highscores highscoreScene:score] withColor:ccWHITE]];
        endGameFinished = YES;
    }
    
        [self unschedule:@selector(endGame:)];
        [self restart];
        endLabel.scale =1; 
    
    
   
}
-(void) update:(ccTime)delta{
    if(start == NO) return;
    [self updateBatch:delta];
    [self updateGuy:delta];
    
    
    int launch = arc4random_uniform(600);
    if(launch == 5){
            [self launchEnemy];
    }
    
    if([self checkGameOver]==YES && start == YES){
        start = NO;
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        [self unscheduleUpdate];
        [self schedule:@selector(endGame:) interval:0.1f];
    }
    
    progressTimer.percentage = globalMultiplier*bonusMultiplier;
    
    if(oldMultiplier != globalMultiplier*bonusMultiplier){
        oldMultiplier = globalMultiplier*bonusMultiplier;
        [multiplierLabel setString:[NSString stringWithFormat:@"x%d", globalMultiplier*bonusMultiplier]];
    }
    gravity += 0.1*delta;
    platformVerticalVel += 2.5*delta;
    platformFourHorizontalVel += 1*delta;
    platformOneHorizontalVel -= 1*delta;
    platformTwoHorizontalVel -= 1*delta;
    platformThreeHorizontalVel -= 1*delta;
    
    
    [parallax updateWithVelocity:ccp(0, -platformVerticalVel/15) AndDelta:delta];
    if(bonusLabel.numberOfRunningActions == 0){
        bonusLabel.visible = NO;
    }
    score += 5*delta+delta*platformVerticalVel;
    [scoreLabel setString:[NSString stringWithFormat:@"%d", (int)score]];
    
    for(CCNode* child in self.children){
        if(child.tag == particleTag){
            CCParticleFire *fire = (CCParticleFire*)child;
            if(fire.position.y == -400){
                [self removeChild:fire cleanup:YES];
            }
        }
    }
    
    float height;
    height = [self platformHeight];
    
    if(height-550 < 0){
        [self setNewPlatform];
    }
    
}



@end
