//
//  SoundServer.m
//  The Return

#import "SoundServer.h"


@implementation SoundServer

@synthesize ambient;

static NSSound* ambient;
static NSSound* gameMusic;
static NSMutableArray* transitionRequests;

+(id)sharedInstance {
    static SoundServer* sndServer = nil;
    if (!sndServer) {
        sndServer = [[[self class] alloc] init];
        ambient = nil;
        gameMusic = nil;
        transitionRequests = [[NSMutableArray alloc] initWithCapacity:10];
        [self registerForNotifications];
    } else {
        fprintf(stderr,"SoundServer: already running\n");
    }

    //we will let a background thread handle changing the ambient sounds
    [NSThread detachNewThreadSelector:@selector(T_ambientSoundManager) toTarget:self withObject:nil];

    return sndServer;
}

+(void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameStarted) name:@"gameStarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pathBlocked) name:@"pathBlocked" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pathLocked) name:@"pathLocked" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pathUnlocked) name:@"pathUnlocked" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerTookItem) name:@"playerTookItem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterRoom:) name:@"playerDidEnterRoom" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerUsedItem:) name:@"playerUsedItem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRoomTransition:) name:@"playerDidRoomTransition" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDroppedItem) name:@"playerDroppedItem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedGame) name:@"playerFinishedGame" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidExit) name:@"playerDidExit" object:nil];

}


/***********************
 *
 *  Notification methods
 *
 ***********************/

+(void)gameStarted {
    //how about some moody music
    gameMusic = [NSSound soundNamed:@"dark.mp3"];
    [gameMusic retain];
    [gameMusic setLoops: YES];
    [gameMusic setVolume:.2];
    [gameMusic play];
}

+(void)didEnterRoom:(NSNotification*)notification {
    Room* theRoom = (Room*)[notification object];
    
    //if the room has a special request for ambient sound then we use that, else
    //+ use the generic sound for each envornment
    if ([theRoom preferedAmbient]) {
        [self changeAmbientSound: [theRoom preferedAmbient]];
    } else {
        if ([[theRoom type] isEqualToString:@"outside"] ) {
            [self changeAmbientSound:@"wind.mp3"];
        } else if ([[theRoom type] isEqualToString:@"cave"]) {
            [self changeAmbientSound:@"cave.mp3"];
        } else if ([[theRoom type] isEqualToString:@"attic"]) {
            [self changeAmbientSound:nil];
        } else if ([[theRoom type] isEqualToString:@"ground"]) {
            [self changeAmbientSound:nil];
        } else if ([[theRoom type] isEqualToString:@"upstairs"]) {
            [self changeAmbientSound:nil];
        } else {
            fprintf(stderr, "SoundServer:didEnterRoom: room is of an unknown type, this is probably a bug.\n");
            [self changeAmbientSound:nil];
        }
    }
}


+(void)didRoomTransition:(NSNotification*)notification {
    //this stub could be used to play a transition effect (footsteps, creaking rope, stairs)
}

+(void)playerUsedItem:(NSNotification*) notification {
    NSString* itemName = (NSString*)[notification object];
    
    if ([itemName isEqualToString:@"lantern"]) {
        [self playSingle:@"match.mp3"];
    } else if ([itemName isEqualToString:@"axe"]) {
        [self playSingle:@"chop.mp3"];
    } else if ([itemName isEqualToString:@"key"]) {
        [self playSingle:@"unlock.mp3"];
    }  else if ([itemName isEqualToString:@"coal"]) {
        [self playSingle:@"coal.mp3"];
    }
}

+(void)playerTookItem {
    NSArray* sounds = [NSArray arrayWithObjects: @"backpack.mp3", @"backpack2.mp3", nil];
    int rand = arc4random() % [sounds count];
    [self playSingle:[sounds objectAtIndex:rand]];
}

+(void)playerDroppedItem {
    NSArray* sounds = [NSArray arrayWithObjects: @"drop1.mp3", @"drop2.mp3", nil];
    int rand = arc4random() % [sounds count];
    [self playSingle:[sounds objectAtIndex:rand]];
}

+(void)pathBlocked {
   //NSLog(@"SoundServer: path blocked unimplemented\n");
}

+(void)pathLocked {
    [self playSingle:@"locked.mp3"];
}

+(void)pathUnlocked {
    [self playSingle:@"creak.mp3"];
}

+(void)playerDidExit {
    [gameMusic setVolume:0.0];
    //[self changeAmbientSound: @"end.mp3"];
}

/***********************
 *
 *  Helper methods
 *
 ***********************/

//changeAmbientSound should be used when changing environments
+(void)changeAmbientSound:(NSString*)theSoundName {
    //nil can not be directly inserted into an NSMutableArray, so we wrap it in NSNull if needed
    [transitionRequests addObject:theSoundName ? theSoundName : [NSNull null]];
}

+(void)T_ambientSoundManager {
    while (true) {
        if ([transitionRequests count] != 0) {
            NSString* requestedFileName = [transitionRequests objectAtIndex:0];
            [transitionRequests removeObjectAtIndex:0];

            //only do the transition if the new sound is different
            if (!([[ambient name] isEqualToString:requestedFileName]) || ambient == nil) {
                //It's possible that the ambient sound isn't playing at full volume, or that it is nill
                //+ so we check each iteration then break.
                for(int i = 1; i < 100; i++) {
                    [ambient setVolume: (1.0 / i)];
                    usleep(60000);
                    
                    if ([ambient volume] < 0.1 || ambient == nil) {
                        [ambient stop];
                        [ambient release];
                        ambient = nil;
                        
                        if ([requestedFileName isKindOfClass:[NSNull class]]) {
                            //NSLog(@"SoundServer:T_ambientSoundManager: trying to change to a null ambient sound");
                        } else {
                            //it's possible that the requested file does not exist
                            @try {
                                ambient = [NSSound soundNamed:requestedFileName];
                                [ambient retain];
                                [ambient setName:requestedFileName];
                                [ambient setVolume:1.0];
                                [ambient play];
                            } @catch (NSException* exception) {
                                fprintf(stderr, "SoundServer:T_ambientSoundManager: error opening new sound\n");
                                ambient = nil;
                            }                            
                        }
                        break;
                    }
                }
                usleep(10000);
            } else {
                //NSLog(@"SoundServer: transitioning to a room with the same ambient sound, not changing\n");
            }
        } else {
            //wait a bit before we check again
            usleep(10000);
        }
    }
}

//Play a sound effect once then exit
+(void)playSingle:(NSString*)theSoundName {
    if (theSoundName) {
         //it would be better to also check if the file is in the bundle, but for now
        //+ we will just let the exception catch all errors
        @try {
            NSSound* theSound = [NSSound soundNamed:theSoundName];
            [theSound retain];
            [theSound setLoops: NO];
            [theSound setVolume:1.0];
            [theSound play];
            [theSound release];
        } @catch (NSException* e) {
            fprintf(stderr, "SoundServer:playSingle: error trying to play requested file");
        }
    } else {
        //NSLog(@"SoundServer:playSingle given nil filename\n");
    }
}

@end
