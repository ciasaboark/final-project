//
//  Game.m
//  StarterGame
//
//  Created by Rodrigo A. Obando on 3/7/12.
//  Copyright 2012 Columbus State University. All rights reserved.
//
//  Modified by Rodrigo A. Obando on 3/7/13.

#import "Game.h"


@implementation Game

@synthesize parser;
@synthesize player;
@synthesize wrongCommands;
@synthesize sndServer;

-(id)initWithGameIO:(GameIO *)theIO {
	self = [super init];
	if (nil != self) {
        [self registerForNotifications];
		[self setSndServer: [SoundServer sharedInstance]];
        [self setParser:[[[Parser alloc] init] autorelease]];
		[self setPlayer:[[[Player alloc] initWithRoom:[self createWorld] andIO:theIO] autorelease]];
        playing = NO;
        [self setWrongCommands: 0];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gameStarted" object:self];

	}
	return self;
}

-(NSArray *)createWorld {
    //A special room to indicate that the path is blocked
    Room* blocked = [[[Room alloc] initWithTag:@"blocked"] autorelease];

    //A special room to indicate that a door is locked
    Room* locked = [[[Room alloc] initWithTag:@"locked"] autorelease];

    //A special room to indicate that the path is too dark to proceed
    Room* dark = [[[Room alloc] initWithTag:@"dark"] autorelease];

    
    //The downstairs rooms
	Room 	*hall1, *hall2, *hall3, *dining_room, *formal_room, *mast_bed, *sitting_room, *kitchen, *mast_bath;
    Room    *srvnt_dining_room, *well_house, *front_steps;

    hall1 = [[[Room alloc] initWithTag:@"the south of the downstairs hallway"] autorelease];
    hall2 = [[[Room alloc] initWithTag:@"the middle of the downstairs hallway"] autorelease];
    hall3 = [[[Room alloc] initWithTag:@"the north of the downstairs hallway"] autorelease];
    dining_room = [[[Room alloc] initWithTag:@"the dining room"] autorelease];
    formal_room = [[[Room alloc] initWithTag:@"the formal room"] autorelease];
    mast_bed = [[[Room alloc] initWithTag:@"the master bedroom"] autorelease];
    sitting_room = [[[Room alloc] initWithTag:@"the sitting room"] autorelease];
    kitchen = [[[Room alloc] initWithTag:@"the kitchen"] autorelease];
    mast_bath = [[[Room alloc] initWithTag:@"the master bathroom"] autorelease];
    srvnt_dining_room = [[[Room alloc] initWithTag:@"the servant's small dining room"] autorelease];
    well_house = [[[Room alloc] initWithTag:@"an attached well house"] autorelease];
    front_steps = [[[Room alloc] initWithTag:@"the front steps of the house"] autorelease];
    
    
    //The cave rooms
    Room 	*cave, *cave_hall, *cemetery;
    
    cave = [[[Room alloc] initWithTag:@"an underground cave"] autorelease];
    cave_hall = [[[Room alloc] initWithTag:@"a long underground tunnel" ] autorelease];
    cemetery = [[[Room alloc] initWithTag:@"a small family cemetery"] autorelease];
    [cave setType:@"cave"];
    [cave_hall setType:@"cave"];
    [cemetery setType:@"outside"];

    //The upstairs rooms
	Room 	*bed1, *workroom, *bed3, *bathroom, *upstairs_hall, *short_hall, *sewing_room, *srvnt_bed_room, *attic;

    bed1 = [[[Room alloc] initWithTag:@"a child's bedroom"] autorelease];
    workroom = [[[Room alloc] initWithTag:@"a workroom"] autorelease];
    bed3 = [[[Room alloc] initWithTag:@"an empty bedroom"] autorelease];
    bathroom = [[[Room alloc] initWithTag:@"the upstairs bath"] autorelease];
    upstairs_hall = [[[Room alloc] initWithTag:@"the upstairs hall"] autorelease];
    short_hall = [[[Room alloc] initWithTag:@"a short hall"] autorelease];
    sewing_room = [[[Room alloc] initWithTag:@"the sewing room"] autorelease];
    srvnt_bed_room = [[[Room alloc] initWithTag:@"the servant's bedroom"] autorelease];
    attic = [[[Room alloc] initWithTag:@"the attic"] autorelease];

    
    //Downstairs room connections
	[hall1 setExit:@"west" toRoom:dining_room];
    [hall1 setExit:@"east" toRoom:formal_room];
    [hall1 setExit:@"north" toRoom:hall2];
    //the path will be unblocked when the axe is used.
    [hall1 setExit:@"south" toRoom:blocked];
    [hall1 setExit:@"hidden" toRoom:front_steps];

    [hall2 setExit:@"west" toRoom:sitting_room];
    [hall2 setExit:@"east" toRoom:mast_bed];
    [hall2 setExit:@"north" toRoom:hall3];
    [hall2 setExit:@"south" toRoom:hall1];
    [hall2 setExit:@"up" toRoom:upstairs_hall];


    [hall3 setExit:@"west" toRoom:kitchen];
    [hall3 setExit:@"east" toRoom:srvnt_dining_room];
    [hall3 setExit:@"north" toRoom:well_house];
    [hall3 setExit:@"south" toRoom:hall2];


    [dining_room setExit:@"east" toRoom:hall1];


    [formal_room setExit:@"west" toRoom:hall1];


    [mast_bed setExit:@"west" toRoom:hall2];
    [mast_bed setExit:@"north" toRoom:mast_bath];


    [sitting_room setExit:@"east" toRoom:hall2];


    [kitchen setExit:@"east" toRoom:hall3];


    [mast_bath setExit:@"south" toRoom:mast_bed];


    [srvnt_dining_room setExit:@"west" toRoom:hall3];


    [well_house setExit:@"down" toRoom:cave];
    [well_house setExit:@"south" toRoom:hall3];
    
    [front_steps setExit:@"north" toRoom:hall1];

	
    //cave Connections
	//the cave it too dark initially to move anywhere but back up. The connections will be replaced when the lantern is used.
    [cave setExit:@"up" toRoom:well_house];
    [cave setExit:@"north" toRoom:dark];
    [cave setExit:@"south" toRoom:dark];
    [cave setExit:@"east" toRoom:dark];
    [cave setExit:@"west" toRoom:dark];
    [cave setExit:@"down" toRoom:dark];
    //a hidden path that will replace the north direction once the lantern is used
    [cave setExit:@"hidden" toRoom:cave_hall];
    
    [cave_hall setExit:@"south" toRoom:cave];
    [cave_hall setExit:@"west" toRoom:cemetery];
    
    [cemetery setExit:@"east" toRoom:cave_hall];

	//Upstairs Connections
    [bed1 setExit:@"west" toRoom:upstairs_hall];
    [bed1 setExit:@"north" toRoom:bathroom];

    [workroom setExit:@"south" toRoom:bed3];
    [workroom setExit:@"east" toRoom:short_hall];


    [bed3 setExit:@"north" toRoom:workroom];
    [bed3 setExit:@"east" toRoom:upstairs_hall];


    [bathroom setExit:@"south" toRoom:bed1];
    [bathroom setExit:@"west" toRoom:short_hall];


    [upstairs_hall setExit:@"down" toRoom:hall2];
    [upstairs_hall setExit:@"west" toRoom:bed3];
    //This will eventually go to the sewing room when the key is used
    [upstairs_hall setExit:@"south" toRoom:locked];
    [upstairs_hall setExit:@"end" toRoom:sewing_room];
    [upstairs_hall setExit:@"east" toRoom:bed1];
    [upstairs_hall setExit:@"up" toRoom:blocked];
    [upstairs_hall setExit:@"hidden" toRoom:attic];



    //[short_hall setExit:@"down" toRoom:hall2];
    [short_hall setExit:@"west" toRoom:workroom];
    [short_hall setExit:@"north" toRoom:srvnt_bed_room];
    [short_hall setExit:@"east" toRoom:bathroom];


    [sewing_room setExit:@"north" toRoom:upstairs_hall];


    [srvnt_bed_room setExit:@"south" toRoom:short_hall];

    [attic setExit:@"down" toRoom:upstairs_hall];

    
    /************************
    * Long Descriptions of the Rooms and Ambient Sounds
    ************************/

    //The Downstairs rooms
    [mast_bed setLongDescription: @"The room was dimly lit. The WINDOWS along the east of the room were curtained and shuttered, and let in no light from the street lamp. The overhead light was off, but small bulbs burned in sconces on both sides of the entrance, illuminating the room. To the north I noticed a bathroom. The entrance to the hall was west. Dust motes floated in the air."];
    
    [hall1 setLongDescription: @"The hallway was lit by two miniature chandeliers, one in this section of the hall and one somewhat farther down. The floor was bare wood, dark in color. The walls were white plaster, with molding that matched the floor. The front door was large and barricaded with a number of hastily placed boards. I wouldn't be able to remove the barrier with my bare hands. To the east there was a dining room. To the west there was a formal hall. The hallway continued north, where I could see additonal rooms."];

    [hall2 setLongDescription: @"The hallway was lit by a miniature chandelier overhead. The walls were white plaster with dark wood molding and the floor, a dark stained wood in the style of the molding, was covered by a long rug woven in some oriential style. The hallway continued north and south from here.  The southern end lead to the front door as well as two additional rooms.  To the north the hallway entered shadow. To the east there was a bedroom. To the west I saw some sort of library. There was a stairway here leading up to the second floor."];

    [hall3 setLongDescription: @"There wasn't much light at the northern end of the hallway. To the west I saw a kitchen. Light from within spilled into the hall, but the penumbra was large and the hall was draped in shadow. To the east there was a small room with a plain wooden table. To the north there was a plain door."];
    
    [dining_room setLongDescription: @"The light from the hallway illuminated an ornate and formal dining room. Nearly the entirity of the floor was covered by a single large rug, woven with a mozaic of birds in flight. A long table sat in the center of the room, with a number of elegantly carved chairs waiting in position. Each chair was fronted by a complete table set. Curiously the two on the southern end seemed to have been used recently."];
    [dining_room setPreferedAmbient:@"clock.mp3"];
    
    [formal_room setLongDescription: @"The floor was polished marble, white speckled with pink. A crystal chandaleer, old enough to have once held a multitude of candles, but now fitted with electric lights, hung from the ceiling."];
    
    [sitting_room setLongDescription: @"It was a library of some kind. The western wall was filled with bookcases from floor to ceiling, except for a small window in the center of the wall. Above the door there sat a marble bust of some long forgotten poet."];
    
    [kitchen setLongDescription: @"The northern and western walls of the kitchen were lined with counter-tops and cabinets. The southern wall had two sinks. One was deep enough to hold a number of lenins, the other smaller. The center of the room was dominated with a long counter over which there hung a number of pots, pans, and utensiles. A Franklin stove sat in the south eastern corner, next to the oven. A small fire in the oven shed enough light through the grating to cast shadows throughout the room."];
    
    [mast_bath setLongDescription: @"The master bathroom was spotless white tile. A window along the eastern wall let in light from a gas lamp by the street."];
    
    [srvnt_dining_room setLongDescription: @"There was no light source within this room, but the glow from the kitchen stretched far enough in to see by. The small room was dominated by a single square TABLE. A simple wooden chair sat pushed against the table. This looked to be where a servant might take their meal so as not to disturb the master of the house."];
    
    [well_house setLongDescription: @"It was a small rectangular room. The floor here was bare wood, unstained. A long window high on the northern wall let in enough light to see by. In the northeast corner of the room there was an uncovered WELL. It seemed as though this room had been added as an expansion sometime recently. A sturdy rope was strung through a pully connected to a large beam overhead."];
    
    [front_steps setLongDescription:@""];
    [front_steps setPreferedAmbient:@"end2.mp3"];

    //The Basement Rooms
    [cave setLongDescription: @"Light filtered down through the hole above, but not enough to see by. If only I had some source of light to illumine the way."];
    
    [cave_hall setLongDescription:@"The cave ended to the south in a small chamber and continued west in a twisted path. The light from the lantern did not reach far into the tunnel, but the walls and floor seemed to glow with a faint greenish light. It was not light enough to make out any details but I was confident I could find my way through."];
    
    [cemetery setLongDescription:@"The cemetery was a small family plot. There were no more than a dozen graves, most of which seemed to have been long neglected. A dense forest enclosed the whole opening, except for the rocky outcrop to the east from where I had emerged. The woods were cloaked in deep shadow, and the moon was just high enough that its light cast long shadows over the clearing."];

    //The Upstairs Rooms
    [bed1 setLongDescription: @"The walls were covered with a patterned wallpaper of muted pink and white flowers. A fireplace in the southern wall was capped and locked with a cast iron cover. A door to the north entered a bathroom, the door to the west opened to a hallway."];
    
    [workroom setLongDescription: @"Two flickering lights, one by either entrance, illuminated the room with fitful light. The door to the south opened to an empty bedroom, the door to the east opened to a short hall by the stairwell."];
    
    [bed3 setLongDescription: @"The bedroom was empty and bare of all but the most basic furnishings. A small bed had been pushed up against the western wall beneath a curtained window. A fireplace was set in the south wall, its opening covered in a decorative cast iron cover depicting a pastoral scene. The floor was bare, the the wood was discolored in a circular pattern in the center. A door in the northern wall connected to a workroom, the door to the east entered into a long hallway."];
    
    [bathroom setLongDescription: @"The tiled walls rose to meet a floral wallpaper at shoulder height. A door to the west opened to a short hallway, the door to the south connected to a bedroom."];
    [bathroom setPreferedAmbient:@"crickets.mp3"];
    
    [upstairs_hall setLongDescription: @"The hall ran south from the stairway. A door to the east led to a child's bedroom, a door to the west led to another bedroom. Light from both rooms flooded the northern end of the hall in light, but the southern end was wreathed in shadow. There was a closed door at the southern end of the hall and a small panel overhead that looked like it might lead to an attic."];
    
    [short_hall setLongDescription: @"The hall ran between the western workroom and the bathroom to the east. A door in the middle of the hall opened north to the servant's quarters."];
    
    [sewing_room setLongDescription: @"The southern wall was dominated by a set of large double doors, opening to a small terrace. Light from the open door to the north only let in a faint glow, but the open doors let in enough moonlight to illuminate the contents of the room. In the dim glow I beheld a grim sight. In the middle of the room there was a WOMAN. Pale golden hair hung loose covering her face. Her dress was a pale blue stiched with a floral pattern along the hem. The front of the dress was splashed in crimson. In front of her there lay an overturned chair. Her feet faintly trailed on the floor as her body gently swung from a noose. Beside her, on the ground, there was a small BODY. The vision so disturbed and overwhelmed me that I fell to my knees in dispair. I almosted missed seeing movement in the corner."];
    
    [srvnt_bed_room setLongDescription: @"The room was plain, but well kept. The room was paneled in wood, unlike the white plaster I had found in the rest of the house."];


    /*****************************
    * Items for the rooms
    *****************************/

    //Items in the Master Bedroom
        //fixed items
        Item* master_bedroom_bed = [[Item alloc] initWithName:@"bed" andDescription:@"The bed was large and seemed to be made entirely out of some glossy dark wood. The covers were unmade. For some reason this seemed to fill me with dispair." usedIn:nil andWeight:40 andRoomDescription:@"The little light that filtered through illuminated a large four post BED draped in what looked to be velvet."];
        Item* master_bedroom_windows = [[Item alloc] initWithName:@"windows" andDescription:@"The windows were curtained in heavy purple cloth. They seemed familiar, or, to be more precise, I felt as though they should feel familiar." usedIn:nil andWeight:60 andRoomDescription:@""];
        Item* master_bedroom_couch = [[Item alloc] initWithName:@"couch" andDescription:@"The couch was made from a dark wood, intricately carved on the legs and back. The cushions were uphostered in a red velvet." usedIn:nil andWeight:60 andRoomDescription:@"A COUCH shared the wall with the bathroom entrance."];
        Item* master_bedroom_picture = [[Item alloc] initWithName:@"picture" andDescription:@"The picture was of a man and woman at a wedding altar. The man wore a buttoned coat, and the woman a dress of lace. Memories stirred. I remembered being there, but not this view." usedIn:nil andWeight:2 andRoomDescription:@"There was a PICTURE of a smiling man and woman on the dresser." andPoints:8];
        
        //items with hidden items
        Item* master_bedroom_dresser = [[Item alloc] initWithName:@"dresser" andDescription:@"The dresser was large and made in the Victorian fashion." usedIn:nil andWeight:40 andRoomDescription:@"A heavy DRESSER sat along the western wall."];
            //Items on the dresser
            Item* key = [[Item alloc] initWithName:@"key" andDescription:@"A brass key. The shine was tarnished." usedIn:upstairs_hall andWeight:1 andRoomDescription:@"A brass KEY sat on top of the dresser."];
            [master_bedroom_dresser addHiddenItem: [key autorelease]];

        Item* master_bedroom_closet = [[Item alloc] initWithName:@"closet" andDescription:@"The closet was a mess. Clothes were scattered all over the floor. I searched through the mess for something that might be of use." usedIn:nil andWeight:-1 andRoomDescription:@"A CLOSET was to the south."];
            //Items in the closet
            Item* flashlight = [[Item alloc] initWithName:@"flashlight" andDescription:@"An old chrome flashlight. I couldn't see how to open the battery compartment, but it feelt heavy. I thought it might be of use later." usedIn:sewing_room andWeight:2 andRoomDescription: @"On the top shelf of the closet there was a FLASHLIGHT."];
            [master_bedroom_closet addHiddenItem: [flashlight autorelease]];

        //collectable items
        Item* hat = [[Item alloc] initWithName:@"hat" andDescription:@"A rumbled bowler hat. Tucked into the rim of the hat was a faded piece of paper with the numbers \"42\", \"28\", and \"16\"." usedIn:nil andWeight:2 andRoomDescription:@"A bowlers HAT rested on a hook by the door."];
    
        [mast_bed addItem: [master_bedroom_bed autorelease]];
        [mast_bed addItem: [master_bedroom_windows autorelease]];
        [mast_bed addItem: [master_bedroom_couch autorelease]];
        [mast_bed addItem: [master_bedroom_dresser autorelease]];
        [mast_bed addItem: [master_bedroom_closet autorelease]];
        [mast_bed addItem: [hat autorelease]];
   
   //Items in the Master Bath
        //Fixed Items
        Item* mast_bath_tub = [[Item alloc] initWithName:@"tub" andDescription:@"A glazed, cast iron, clawed-foot monstrosity. It had been re-fitted with copper pipes." usedIn:nil andWeight:-1 andRoomDescription:@"There was a TUB on a raised platform by the western wall."];
        
    
        Item* mast_bath_mirror = [[Item alloc] initWithName:@"mirror" andDescription:@"A broken mirror. I couldn't see any blood on the glass shards. The frame had spots of mud along the sides." usedIn:nil andWeight:6 andRoomDescription:@"The MIRROR that was once above the sink lied shattered on the floor."];

        //Items with hidden items
        Item* mast_bath_shelf = [[Item alloc] initWithName:@"shelf" andDescription:@"A shelf of white wood." usedIn:nil andWeight:-1 andRoomDescription:@"A SHELF above the sink held a few items."];
            //Items on the shelf
            Item* razor = [[Item alloc] initWithName:@"razor" andDescription:@"It was a straight razor. The handle was made in ivory. It seemed to be sharp, but there were small spots of rust on the blade." usedIn:nil andWeight:1 andRoomDescription:@"A RAZOR was on the shelf."];
            [mast_bath_shelf addHiddenItem: [razor autorelease]];

        [mast_bath addItem: [mast_bath_tub autorelease]];
        [mast_bath addItem: [mast_bath_mirror autorelease]];
        [mast_bath addItem: [mast_bath_shelf autorelease]];

    //Items for the dining room
        //Fixed Items
        Item* dining_room_table = [[Item alloc] initWithName:@"table" andDescription:@"A large TABLE. There were still platters of half eaten food on two of the settings. A bowl leaned at a angle, soup covered the tablecloth." usedIn:nil andWeight: 60 andRoomDescription:@"In the center of the room there was a large TABLE."];
            //Items beside the table
            Item* dining_room_doll = [[Item alloc] initWithName:@"doll" andDescription:@"A bisque doll. The paint was faded and the clothes have been mended." usedIn:nil andWeight:2 andRoomDescription:@"I noticed a doll laying beside the table."];
            [dining_room_table addHiddenItem: [dining_room_doll autorelease]];
        Item* dining_room_clock = [[Item alloc] initWithName:@"clock" andDescription:@"The grandfather CLOCK was large and stained dark." usedIn:nil andWeight: 60 andRoomDescription:@"Sitting against the wall by the door there was a grandfather CLOCK."];
        Item* dining_room_china = [[Item alloc] initWithName:@"cabinet" andDescription:@"The china CABINET was filled with dishes of fine porcelain and silverware that gleams even in the dim light." usedIn:nil andWeight:60 andRoomDescription:@"A large china CABINET has been placed along the center of the western wall, flanked on either side by serving trays."];
    
        [dining_room addItem: [dining_room_table autorelease]];
        [dining_room addItem: [dining_room_clock autorelease]];
        [dining_room addItem: [dining_room_china autorelease]];


    //Items in the library
        //Items with hidden items
        Item* library_book_stand = [[Item alloc] initWithName:@"stand" andDescription:@"A book STAND. On the stand there was an open book. The book appears to be some kind of journal. A page was open, weighted down by a carved raven. Though the dates on the page were ledgable, the text was mostly gibberish. A single passage stands out, written in a shakey hand:\n----\nJuly 23rd 1918:\n\tSounds from below again. The well. The boards wont't hold forever. Should have ended it." usedIn:nil andWeight:40 andRoomDescription:@"Against the south wall there was a book STAND with an open book on top."];
            //Items on the book stand
            Item* raven = [[Item alloc] initWithName:@"raven" andDescription:@"A small black onyx carving of a raven. The birds beak was open, as if caught in a moment of speech." usedIn:nil andWeight:3 andRoomDescription:@"" andPoints: 0 andSpecial:true];
            [library_book_stand addHiddenItem:[raven autorelease]];
        
         Item* library_book_stack = [[Item alloc] initWithName:@"stack" andDescription:@"A large STACK of book. You look through the titles and notice some obscure subjects:" usedIn:nil andWeight:-1 andRoomDescription:@"On a table beside the chairs there was a large STACK of books."];
            //Books in the stack
            Item* book_stack_occult = [[Item alloc] initWithName:@"occult" andDescription:@"" usedIn:nil andWeight:3 andRoomDescription:@"\"The OCCULT of New Haven.\"" andPoints: 128];
            Item* book_stack_guinea = [[Item alloc] initWithName:@"guinea" andDescription:@"The text was a long and varied. Toward the middle of the book there were a number of pages that had been dog-eared. I looked through this section more closely and saw a description of a ritual sacrifice that FINISH DESCRIPTION." usedIn:nil andWeight:3 andRoomDescription:@"\"On the Religion of Papa New GUINEA.\"" andPoints: 16];
            Item* book_stack_iram = [[Item alloc] initWithName:@"iram" andDescription:@"The cover was torn, the only text visible in the bottom corner read: \"dul Alharzed\"\nI scanned through the text, but most of it seemed to be written in a number of languages I was unfamiliar with. There were numerous pages with drawings of strange symbols and gliphs. A section toward the end referenced a Nameless City wherein eldritch rituals are performed by a group of elders and, in doing so they are renewed for another season. In the margin of the page, scribbled in pencil there was a note:\n\n\t\"alignment in 3 months\n\tit will be my only chance for the sacrifice\"\n" usedIn:nil andWeight:3 andRoomDescription:@"\"Rituals and Practices of IRAM of the Pillars.\"" andPoints: 64];
            [library_book_stack addHiddenItem:[book_stack_occult autorelease]];
            [library_book_stack addHiddenItem:[book_stack_guinea autorelease]];
            [library_book_stack addHiddenItem:[book_stack_iram autorelease]];
            

        Item* library_fireplace = [[Item alloc] initWithName:@"fireplace" andDescription:@"A brick FIREPLACE. Three leather-covered chairs face the fireplace. The mantlepiece appears to be ebony. Carved figures adorn the sides. The brick and metal were cold, and there was not even the slightest smell of soot in the air. The cast iron grating covered the front." usedIn:nil andWeight:-1 andRoomDescription:@"Along the north wall of the library there was a FIREPLACE."];
            //Items inside the fireplace
        Item* library_portrait = [[Item alloc] initWithName:@"portrait" andDescription:@"A portrait of a middle aged man, clean-shaven, wearing a navy blue pea coat. A cap is tucked under one arm, while the other holds a portable brass telescope. The man stares into the distance." usedIn:nil andWeight:-1 andRoomDescription:@"A PORTRAIT of a man hangs above the fireplace." andPoints:1];
            
    
        //Collectable Items
        Item* bust = [[Item alloc] initWithName:@"bust" andDescription:@"A pale marble bust of some long forgotten Greek god." usedIn:nil andWeight:5 andRoomDescription:@"" andPoints:0 andSpecial:true];
        
        [sitting_room addItem: [library_fireplace autorelease]];
        [sitting_room addItem: [library_book_stand autorelease]];
        [sitting_room addItem: [library_book_stack autorelease]];
        [sitting_room addItem: [library_portrait autorelease]];
        [sitting_room addItem: [bust autorelease]];


    //Items in the Formal room
        //Fixed items
        Item* formal_room_record = [[Item alloc] initWithName:@"phonograph" andDescription:@"A phonograph player of older design." usedIn:nil andWeight:60 andRoomDescription:@"In the middle of the western wall there was a PHONOGRAPH player. Dispite there being no record on the player I could almost hear the music playing."];
            //Items by the record player
            Item* formal_room_record_1 = [[Item alloc] initWithName:@"record" andDescription:@"A classical record by Claude Debussy \"En blanc et noir.\" I remembered finding a copy of this same record a few years back, and of dancing with a lady in white. It seemed strange that I could remember such a small detail, but nothing of who I was or who I danced with." usedIn:formal_room andWeight:1 andRoomDescription:@"There was a RECORD of classical music beside the phonograph." andPoints:4];
            [formal_room_record addHiddenItem:[formal_room_record_1 autorelease]];
            
        Item* formal_room_pedestal = [[Item alloc] initWithName:@"pedestal" andDescription:@"The pedestals were marble, ornately chissiled in the greccian fashion. On top of each pedestal there was a model of a boat incased in a glass dome. The coverings were fixed to the base and immobile." usedIn:nil andWeight:-1 andRoomDescription:@"In a gap in the chairs along the south wall there were three marble pedestalS."];
            //Item on the pedestals
            Item* formal_room_pedestal_boat1 = [[Item alloc] initWithName:@"ship" andDescription:@"The ship was an older style, broad and deep, with three tall masts rigged with a number of sails. A plaque at the bottom read: \"Amsterdam - 1741\"." usedIn:nil andWeight:-1 andRoomDescription:@"A model of a large SHIP was on top of one of the pedestals"];
            Item* formal_room_pedestal_boat2 = [[Item alloc] initWithName:@"clipper" andDescription:@"A wooden boat in the distinctive style of a Baltimore Clipper. Five narrow sails were rigged to two tall masts. This type of ship hadn't been common in nearly a century. A plaque at the bottom read: \"Savannah - 1837\"." usedIn:nil andWeight:-1 andRoomDescription:@"A model of a Baltimore CLIPPER was on top of one of the pedestals."];
            Item* formal_room_pedestal_boat3 = [[Item alloc] initWithName:@"steamship" andDescription:@"It was a model of a modern steamship. A plaque at bottom read: \"SS Bridgeport - 1916\"." usedIn:nil andWeight:-1 andRoomDescription:@"A model of a recent STEAMSHIP was on top of one of the pedestals."];
            [formal_room_pedestal addHiddenItem:[formal_room_pedestal_boat1 autorelease]];
            [formal_room_pedestal addHiddenItem:[formal_room_pedestal_boat2 autorelease]];
            [formal_room_pedestal addHiddenItem:[formal_room_pedestal_boat3 autorelease]];
        Item* formal_room_chairs = [[Item alloc] initWithName:@"chairs" andDescription:@"Two rows of chairs, one along the north wall, and one along the south. The chairs were ornate, and did not look like they had seen much use. It was obvious that the room was intended to be used for entertaining and socializing." usedIn:nil andWeight:-1 andRoomDescription:@"Along both the north and south wall there were rows of CHAIRS."];

        [formal_room addItem: [formal_room_record autorelease]];
        [formal_room addItem: [formal_room_chairs autorelease]];
        [formal_room addItem: [formal_room_pedestal autorelease]];

    //Items in the kitchen
        //Fixed items
        Item* kitchen_stove = [[Item alloc] initWithName:@"stove" andDescription:@"" usedIn:nil andWeight:60 andRoomDescription:@""];
        Item* kitchen_table = [[Item alloc] initWithName:@"table" andDescription:@"" usedIn:nil andWeight:60 andRoomDescription:@""];

        //Collectable Items
        Item* knife = [[Item alloc] initWithName:@"knife" andDescription:@"" usedIn:nil andWeight:4 andRoomDescription:@""];

        [kitchen addItem: [kitchen_stove autorelease]];
        [kitchen addItem: [kitchen_table autorelease]];
        [kitchen addItem: [knife autorelease]];

    //Items in the servant's dining room
        //Fixed items
        Item* srvnt_dining_room_table = [[Item alloc] initWithName:@"table" andDescription:@"" usedIn:nil andWeight:60 andRoomDescription:@""];
            //Items on the servant's dining room table
             Item* lantern = [[Item alloc] initWithName:@"lantern" andDescription:@"The metal was more rust than shine, and the glass covering was chipped at the top, but there was a small amount of oil in the reservoir, and a pair of matches were stuck into a container at the base. It might hold a flame long enough to see by." usedIn:cave andWeight:3 andRoomDescription:@"I saw an old LANTERN on the table."];
            [srvnt_dining_room_table addHiddenItem:[lantern autorelease]];

        [srvnt_dining_room addItem:[srvnt_dining_room_table autorelease]];

    //Items in the well house
        //Collectable items
        Item* ladder = [[Item alloc] initWithName:@"ladder" andDescription:@"A short wooden ladder. It appeared sturdy enough." usedIn:upstairs_hall andWeight:15 andRoomDescription:@"A wooden LADDER leaned against the wall."];
        Item* well = [[Item alloc] initWithName:@"well" andDescription:@"The well was a wooden box covering a deep shaft. The first few feet were lined in brick but the light did not reach far enough down to see further. The rope that hung down into the darkness swayed, and a slight breeze rose from the depths. It smelled of damp and mold.  The hole seemed unusually wide, and I wondered how deep the shaft went." usedIn:nil andWeight:-1 andRoomDescription:@""];
            //Items next to the well
            Item* coal = [[Item alloc] initWithName:@"coal" andDescription:@"The box was small enough that I could carry it with me, and held only a few lumps of coal. The coal was damp to the touch and I didn't think it would hold a flame. I couldn't see a use for it yet." usedIn:well_house andWeight:6 andRoomDescription:@"There was a small wooden box of COAL next to the well."];
            [well addHiddenItem:[coal autorelease]];

        [well_house addItem:[ladder autorelease]];
        [well_house addItem:[well autorelease]];


    //Items in the cave
        //Fixed items
        Item* cave_gleam = [[Item alloc] initWithName:@"gleam" andDescription:@"A small section of the floor gleamed a bit brighter than the rest. Sticking up slightly from the mud I saw the outline of something hard. I scraped the mud away and saw that there was a small statue embeded in the ground." usedIn:nil andWeight:-1 andRoomDescription:@""];
            //Items in the gleam
            Item* cthulhu = [[Item alloc] initWithName:@"statue" andDescription:@"A small jade statue of some obscene monstrosity. It was vaguely huminoid, but bat wings drap the figure, and a mass of tenticles were its mouth. The figure was crouched, as if waiting. Along the base there were words carved: \"Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn.\""usedIn:nil andWeight:3 andRoomDescription:@"" andPoints:0 andSpecial:true];
            [cave_gleam addHiddenItem:[cthulhu autorelease]];
        
        [cave addItem:[cave_gleam autorelease]];
    
    //Items in the cave tunnel
    
    //Items in the cemetery
        //Fixed items
        Item* grave = [[Item alloc] initWithName:@"grave" andDescription:@"The headstone read:\n\n\t\t\t\t\t\t William Alexander Gardner\n\t\t\t\t\t\t       1887 - 1918\n\t\t\t\t\t\tBeloved Husband and Father.\n\nThe ground around the grave had been recently disturbed, like some animal has dug into it. The hole reached far enough into the ground that the end disappeared into shadow, but I was sure I saw the lining of a casket below. I didn't notice a body in the grave, and this seemed like a strange place for grave robbers to visit." usedIn:nil andWeight:-1 andRoomDescription:@"At the western edge of the plot a GRAVE had been disturbed." andPoints:512];
            //Items beside the grave
            Item* locket = [[Item alloc] initWithName:@"locket" andDescription:@"A gold locket. I opened the locket and was greeted by a picture of a smiling man, woman, and infant. On the inside of the front, in letters small enough to be hard to read by the moonlight, there was an inscription: \n\t\"Olphelia, Wife and Mother. With love. W. 1913\"" usedIn:nil andWeight:1 andRoomDescription:@"I noticed the glint of a small locket in the dirt beside the grave." andPoints:16384 andSpecial:true];
            [grave addHiddenItem:[locket autorelease]];
        [cemetery addItem:[grave autorelease]];
    
    //Items in the sewing room
        //Fixed items
        Item* sewing_room_corner = [[Item alloc] initWithName:@"corner" andDescription:@"In the corner there was movement EXPAND MOVEMENT TOWARDS MIRROR HERE" usedIn:nil andWeight:-1 andRoomDescription:@""];
            //Items in the corner
   			 Item* mirror = [[Item alloc] initWithName:@"thing" andDescription:@"In the corner of the room some THING waits crouched. In the dim light it was impossible to make out any details. EXPAND DESCRIPTION OF TOUCHING THE MIRROR" usedIn:nil andWeight:60 andRoomDescription:@"" andPoints:262144];
            [sewing_room_corner addHiddenItem:[mirror autorelease]];
        //Regular Items
        Item* axe = [[Item alloc] initWithName:@"axe" andDescription:@"A broken AXE. The handle was just long enough to be used as a hatchet." usedIn:hall1 andWeight:1 andRoomDescription:@"Laying beside the body there was a broken AXE."];
    
        [sewing_room addItem:[sewing_room_corner autorelease]];
        [sewing_room addItem:[axe autorelease]];

    //Items in the servants bedroom
        //Fixed Items
        Item* srvnt_bed_room_bed = [[Item alloc] initWithName:@"bed" andDescription:@"The bed was built with a simple wooden frame. The matress was covered with a thick quilt and a knitted afgan." usedIn:nil andWeight:60 andRoomDescription:@"A small BED was pushed into the northwest corner"];
        Item* srvnt_bed_room_dresser = [[Item alloc] initWithName:@"dresser" andDescription:@"The dresser was plain but well crafted in the shaker design." usedIn:nil andWeight:60 andRoomDescription:@"A small DRESSER was against the wall by the bed."];
        Item* srvnt_bed_room_trunk = [[Item alloc] initWithName:@"trunk" andDescription:@"The trunk was made from pine wood, supported by iron bands, and decorated with a punched tin relief." usedIn:nil andWeight:60 andRoomDescription:@"A steamer TRUNK was at the foot of the bed."];
        Item* srvnt_bed_room_table = [[Item alloc] initWithName:@"table" andDescription:@"The table had a small horizontal shelf at its top, with small cutouts to hold an ink well and pen. The writing surface was angled downwards. A small shelf at the bottom held a charcoal pencil." usedIn:nil andWeight:60 andRoomDescription:@"There was a small writing TABLE in the northwest corner."];
            //Items on the table
            Item* srvnt_bed_room_table_drawing = [[Item alloc] initWithName:@"drawing" andDescription:@"The drawing had been done with a charcoal pencil, obviously by a child. It showed a child and a grown woman holding hands. Underneath the figures there wre names written: Miss. Anne and Victoria." usedIn:nil andWeight:1 andRoomDescription:@"There was a DRAWING on the writing table." andPoints:2];
            [srvnt_bed_room_table addHiddenItem: [srvnt_bed_room_table_drawing autorelease]];

        [srvnt_bed_room addItem:[srvnt_bed_room_bed autorelease]];
        [srvnt_bed_room addItem:[srvnt_bed_room_dresser autorelease]];
        [srvnt_bed_room addItem:[srvnt_bed_room_trunk autorelease]];
        [srvnt_bed_room addItem:[srvnt_bed_room_table autorelease]];



    //Items in the workroom
        //Fixed items
        Item* workroom_windows = [[Item alloc] initWithName:@"windows" andDescription:@"The windows were boarded over with a number of sheets of heavy paper held down by heavy wooden planks. The curtains had been removed, though the support rods had been left in place. I couldn't see even the faintest glow of moonlight through the paper. The occlusions seemed to have been in place for some time; dust covered the boards, and some of the outer layers of paper bore slight tears." usedIn:nil andWeight:-1 andRoomDescription:@"The WINDOWS on the north and west walls were dark and boarded."];
        
        Item* workroom_sign = [[Item alloc] initWithName:@"pattern" andDescription:@"In the center of the floor there was a circular pattern. The pattern seemed to have been drawn with charcoal, or perhaps burned directly into the bare wood. The sigil was composed of an unbroken perimeter circle, connected to a number of off-centerted interier circles by various radiant curving lines. The lines all seemed to be connected unbroken from the center to the edge, but I could not follow the path of any one line to completion before becoming disoriented. In the center of the sigil there was an circle perhaps two feet in diameter, its otherwise unbroken perimeter stained by a large discolored spot. It looked as if someone had attempted to scrub the pattern from the floor, as a number of the lines were blurred." usedIn:nil andWeight:-1 andRoomDescription:@"The center of the floor was covered in an intricate circular PATTERN." andPoints:32768];
            //Items in the pattern
            Item* workroom_sign_spot = [[Item alloc] initWithName:@"spot" andDescription:@"It was blood. I wasn't sure how I knew this, but I was certain it was human." usedIn:nil andWeight:-1 andRoomDescription:@"" andPoints: 256];
            [workroom_sign addHiddenItem:[workroom_sign_spot autorelease]];

        
        Item* workroom_cirTable = [[Item alloc] initWithName:@"table" andDescription:@"The table was broad and wedge shaped. Its face bore many gouges and burn marks." usedIn:nil andWeight:-1 andRoomDescription:@"A semi-circular TABLE was pushed into the north-west corner."];
            //Items on the table
            Item* workroom_cirTable_burner = [[Item alloc] initWithName:@"burner" andDescription:@"The burner was fixed to the table with four solid bolts. The gas line had been cut, and there was no canister in sight." usedIn:nil andWeight:-1 andRoomDescription:@"A BURNER had been bolted to the table."];
            [workroom_cirTable addHiddenItem:[workroom_cirTable_burner autorelease]];
        
        Item* workroom_box = [[Item alloc] initWithName:@"box" andDescription:@"The box was filled with a number of items all thrown in haphazardly." usedIn:nil andWeight:30 andRoomDescription:@"I noticed a BOX filled with a jumble of items near the door to the hall"];
            //Items in the box
            Item* workroom_box_flasks = [[Item alloc] initWithName:@"flasks" andDescription:@"There were a variety of glass flasks, some still covered in burn marks and residue. I couldn't tell what the flaks had been used for, but an acrid smell emanated from them." usedIn:nil andWeight:4 andRoomDescription:@"Inside the box there was a number of glass FLASKS."];
            Item* workroom_box_notebook = [[Item alloc] initWithName:@"notebook" andDescription:@"The notebook was filled with sketches of various sigils, some of which seemed similar to the pattern on the floor. One of these sigils, the last in the series, was circled. A hastily scribbled note beside the pattern reads:\n\n\tthis one\n\tI could feel HIS presence during the sacrifice\n\tanimal blood will not be strong enough to bind HIM long enough\n." usedIn:nil andWeight:-1 andRoomDescription:@"I saw a small NOTEBOOK in the pile." andPoints:1024];
            [workroom_box addHiddenItem:[workroom_box_flasks autorelease]];
            [workroom_box addHiddenItem:[workroom_box_notebook autorelease]];
    
        [workroom addItem:[workroom_windows autorelease]];
        [workroom addItem:[workroom_sign autorelease]];
        [workroom addItem:[workroom_cirTable autorelease]];
        [workroom addItem:[workroom_box autorelease]];
    
    //Items in the upstairs bath
        //Fixed items
        Item* bathroom_mirror = [[Item alloc]  initWithName:@"spot" andDescription:@"The wallpaper above the sink was discolored, darker than the surrounding material. The spot was rectangular, and it seemed most likely that a mirror had once hung there." usedIn:nil andWeight:-1 andRoomDescription:@"There was a discolored SPOT above the sink."];
        Item* bathroom_window = [[Item alloc]  initWithName:@"window" andDescription:@"The window had been shattered, and the curtains hung out through the broken glass into the night air. I thought it strange that there was no bits of glass inside." usedIn:nil andWeight:-1 andRoomDescription:@"The WINDOW in the eastern wall had been badly damaged."];
        Item* bathroom_tub = [[Item alloc]  initWithName:@"tub" andDescription:@"The tub was cast iron, enameled in white. A stepstool had been placed at its feet." usedIn:nil andWeight:4 andRoomDescription:@"A claw foot TUB sat along the northern wall."];
        [bathroom addItem:[bathroom_mirror autorelease]];
        [bathroom addItem:[bathroom_window autorelease]];
        [bathroom addItem:[bathroom_tub autorelease]];
    
    //Items in the childs bedroom
        Item* child_musicbox = [[Item alloc] initWithName:@"box" andDescription:@"A musicbox. The lid, covered in a raised relief, depicts a small child on a field surrounded by sheep." usedIn:bed1 andWeight:1 andRoomDescription:@"On a table beside the bed there was a small music BOX."];
        [bed1 addItem:[child_musicbox autorelease]];


    //Some Items
    //move these to appropriate rooms once the story is fleshed out.
    //Item* item_name = [[Item alloc] initWithName:@"name" andDescription:@"name" usedIn:nil andWeight: andRoomDescription:@""];
 
    
    //In order to advance the sense of amnesia we can start in a (semi) random room.
    //+ We return the entire array so that player can keep a copy to use with the sleep command
	NSMutableArray *rooms = [NSArray arrayWithObjects: bed1, bed3, mast_bed, srvnt_bed_room, nil];
  
    return rooms;
}

-(void)start {
    playing = YES;
    [player outputMessage:[self welcome]];
}

-(void)end {
    //There are 501 points available to collect in the game, we can divide by 5 and get a rough % complete
    //If the player has less than 50 points then we assume that they didn't discover enough to unlock the back story.
    int endpoints = [player points] / 5;
    
    if (endpoints < 40) {
        [player outputMessage:@"I could not shake the feeling that I had been here before. Memories, as if from another life, floated at the edge my my mind. There were more enigmas here to uncover, but the cold air of night was my freedom, and freedom beckoned. Those secrets would have lie in wait for the next venturer.\n\n"];
        [player outputMessage:[self goodbye]];
        playing = NO;
    } else if (endpoints < 70) {
        [player outputMessage:@"I had been here before, I was sure of that. Memories floated at the edge my my mind, vague recollections of a time passed. I wasn't sure who's bodies I had discovered upstairs, but I knew that I had known them. There were more enigmas here to uncover, but the cold air of night was my freedom, and freedom beckoned. Those secrets would have lie in wait for the next venturer.\n\n"];
        [player outputMessage:[self goodbye]];
        playing = NO;
    } else if (endpoints > 99) {
        //perfect ending
        [player outputMessage:@"Hope of redemption faded as I walked out the front door into the night air. I remembered everything, the illness, my search for a cure. I remembered searching the globe for a chance, by any means, to avoid my fate. I remembered my trip to the nameless city in the desert, and how the elders there played me for a fool. They told me of a ritual sacrifice that would extend my existence indefinately. I had hoped that this ritual would give me more time to spend with my love and the child she bore. My greed for life killed my wife and daughter as surely as if I had wielded the axe and strung the noose myself. What had seemed to me a moment as short as the blink of an eye between my death and resurrection was, in fact, years. Four years in the cold ground as the worms did their work. That Old One, that Elder Being, to whom I had prayed and promised my very soul to kept his promise to give me life, only four years to late.\n\nThis house held nothing for me any longer. My wife and child were gone, and where they went I could not follow. The night was mine, and soon, so too would be those who had betrayed me.\n\n"];
        [player outputMessage:[self goodbye]];
        playing = NO;
    }
    
}

-(BOOL)execute:(NSString *)commandString {
	BOOL finished = NO;
    if (playing) {
        [player outputMessage:[NSString stringWithFormat:@">%@",commandString]];
        Command *command = [parser parseCommand:commandString];
        if (command) {
            finished = [command execute:player];
        }
        else {
            wrongCommands++;
            if (wrongCommands > 2) {
                [player outputMessage:[NSString stringWithFormat:@"\nI wasn't sure how to %@.\n", commandString]];
                [player outputMessage:@"Sometimes the pain in my head became unbearable and the simplest of tasks became overwhelming. I remembered that I could ask for 'help' for some tips.\n"];
                [self setWrongCommands: 1];
            } else {
                [player outputMessage:[NSString stringWithFormat:@"\nI couldn't remember how to %@\n", commandString ]];
            }
        }
    }
    return finished;
}

-(NSString *)welcome {
    NSString* asciiArtThe = @"\t\t\t\t\t\t  _____ _\n\t\t\t\t\t\t |_   _| |__   ___\n\t\t\t\t\t\t   | | | '_ \\ / _ \\\n\t\t\t\t\t\t   | | | | | |  __/\n\t\t\t\t\t\t   |_| |_| |_|\\___|";
    NSString* asciiArtReturn = @"\t\t\t\t\t\t\t     ____      _\n\t\t\t\t\t\t\t    |  _ \\ ___| |_ _   _ _ __ _ __\n\t\t\t\t\t\t\t    | |_) / _ \\ __| | | | '__| '_ \\\n\t\t\t\t\t\t\t    |  _ <  __/ |_| |_| | |  | | | |\n\t\t\t\t\t\t\t    |_| \\_\\___|\\__|\\__,_|_|  |_| |_|\n\t\t\t\t\t\t  ****************************************\n";
	return [NSString stringWithFormat:@"%@\n\n%@\n\n\n\n\n\n\n\n\n\n\n\nI awoke. The pain in my head was blinding. I was laying in a puddle of mud and water. My clothes, which I did not recognize, appeared to have once been fine but were now torn, muddy, and soaked. I couldn't remember how I came to this place.  Perhaps this house holds some answers.\n\nUse your words to control the player, search the house to find a way out, or explore further to unlock hidden mysteries.\n\nSay 'help' for a complete list of commands.\n", asciiArtThe, asciiArtReturn];
}

-(NSString *)goodbye {
    int hiddenItems = 0;
     for (NSString* key in [player inventory])  {
         Item* theItem = [player getItem:key];
         if ([theItem special]) {
             hiddenItems++;
         }
     }
    
    return [NSString stringWithFormat:@"\nThank you for playing, Goodbye.\n\tHidden Items found: %i\n\tTotal Story uncovered: %i%%", hiddenItems, [player points]];
}

-(void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterRoom:) name:@"playerDidEnterRoom" object:nil];
}


-(void)didEnterRoom:(NSNotification*)notification {
    Room* theRoom = (Room*)[notification object];
    
    //The only room entrance we need to look for is the front steps, which indicates that the game should end.
    if ([[theRoom tag] isEqualToString:@"the front steps of the house"] ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playerDidExit" object:self];
        [self end];
    }
}

-(void)dealloc
{
	[parser release];
	[player release];
    [sndServer release];
	
	[super dealloc];
}

@end
