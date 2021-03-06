//
//  Game.h
//  StarterGame
//
//  Created by Rodrigo A. Obando on 3/7/12.
//  Copyright 2012 Columbus State University. All rights reserved.
//
//  Modified by Rodrigo A. Obando on 3/7/13.

#import <Cocoa/Cocoa.h>
#import "Parser.h"
#import "Player.h"
#import "GameIO.h"
#import "SoundServer.h"



@interface Game : NSObject {
    BOOL playing;
    int wrongCommands;
    SoundServer* sndServer;
}

@property (retain, nonatomic)Parser* parser;
@property (retain, nonatomic)Player* player;
@property (nonatomic)int wrongCommands;
@property (retain, nonatomic)SoundServer* sndServer;

-(id)initWithGameIO:(GameIO *)theIO;
-(NSArray *)createWorld;
-(void)start;
-(void)end;
-(BOOL)execute:(NSString *)commandString;
-(NSString *)welcome;
-(NSString *)goodbye;

-(void)registerForNotifications;
-(void)didEnterRoom:(NSNotification*)notification;

-(void)dealloc;

@end
