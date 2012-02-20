//
//  ChampionsPreferences.h
//  champions
//
//  Created by Mac on 02.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Preferences.h"

extern const NSString* PREFS_IS_EXIST;
extern const NSString* PREFS_SOUND_ON;
extern const NSString* PREFS_MUSIC_ON;

extern const NSString* TUTORIAL_MAPS[];
#define TUTORIAL_LEVELS_COUNT 15

#define AC_Minesweeper 423664
#define AC_Fireworks 423704
#define AC_Sapper 423714
#define AC_Bomb_Squad 423724
#define AC_Demolition_Dynamo -1
#define AC_Magnetic_Force 423734
#define AC_Pole_Attraction 423744
#define AC_Force_Field 423754
#define AC_North_Pole 423764
#define AC_Tesla_Disciple -1
#define AC_Crow_Bar_Test 423774
#define AC_Brickbreaker 423784
#define AC_Pneumatic_Finger 423794
#define AC_Sledgehammer 423804
#define AC_Crusher -1
#define AC_Junkie 423814
#define AC_Star_Gazer 423824
#define AC_Astrologer 424614
#define AC_Astronaut 424624
#define AC_Golden_Wheel 424644
#define AC_Russian_Roulette 424654
#define AC_Spintastic 424664
#define AC_Spin_Master 424674
#define AC_Circle_of_Matter -1
#define AC_Laborer 424684
#define AC_Builder 424694
#define AC_Engineer 424704
#define AC_Foreman 424714
#define AC_Architect -1
#define AC_Fingertip_Facile 424724
#define AC_Handyman 424734
#define AC_Phalange_Phenomenon 424744
#define AC_Finger_Whiz 424754
#define AC_Trial 424844
#define AC_Letter_to_a_Friend -1
#define AC_Postman -1
#define AC_Long_Distance_Runner 424854
#define AC_Welcome 424864
#define AC_Subscriber -1
#define AC_Treasure_Hunter -1
#define AC_High_Five -1
#define AC_Reviewer -1
#define AC_Navigator 424874
#define AC_Shadow_Fight 424764
#define AC_5th_Power 424774
#define AC_Altius_Citius_Fortius 424784
#define AC_Beat_That 424794
#define AC_Singularity -1
#define AC_Accelerator 424804
#define AC_Chronometer 424814
#define AC_Tick_Tock 424824
#define AC_Time_Traveler 424834
#define AC_Quantum_Leap -1
#define AC_Tutorial 446324

@interface ChampionsPreferences : Preferences
{
}

-(void)resetToDefaults;

@end