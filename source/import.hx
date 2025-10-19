package;

#if !macro
import FunkinG;
import backend.BaseStage;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Controls;
import backend.CoolUtil;
import backend.CustomFadeTransition;
import backend.Difficulty;
import backend.Language;
import backend.Mods;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.Paths;
import backend.ui.*; // Polyverse-UI
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.Alphabet;
import objects.BGSprite;
import states.LoadingState;
import states.PlayState;

using StringTools;

#if flxanimate
import flxanimate.*;
import flxanimate.PsychFlxAnimate as FlxAnimate;
#end
// Discord API
#if DISCORD_ALLOWED
import backend.Discord;
#end
#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end
#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end
#end
