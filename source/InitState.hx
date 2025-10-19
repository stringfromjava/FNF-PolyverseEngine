package;

import backend.Highscore;
import flixel.FlxState;
import lime.app.Application;
import openfl.Lib;
import openfl.display.StageScaleMode;
import openfl.events.KeyboardEvent;
import states.StoryMenuState;
import states.TitleState;
#if (linux || mac)
import lime.graphics.Image;
#end

/**
 * Initialization state where every major part of the
 * pre-setup is configured. This includes registering mods,
 * achievements, Flixel settings, and similar.
 */
class InitState extends FlxState
{
  /**
   * Has the game been fully setup?
   */
  public static var initialized:Bool = false;

  /**
   * The volume used when the window is out of focus.
   */
  static final MINIMIZED_VOLUME:Float = 0.02;

  /**
   * The duration of the volume tweening.
   */
  static final TWEEN_DURATION:Float = 0.24;

  /**
   * A tween for the volume when the window
   * loses focus and gains focus again.
   */
  static var volumeTween:FlxTween = null;

  /**
   * The last volume the user had before the game lost focus.
   */
  static var lastVolume:Float = 1.0;

  /**
   * Is the game's window currently focused?
   */
  static var isWindowFocused:Bool = true;

  override function create():Void
  {
    super.create();

    // Remove all unnecessary memory.
    Paths.clearStoredMemory();
    Paths.clearUnusedMemory();

    // Configure the players settings.
    if (!initialized)
    {
      ClientPrefs.loadPrefs();
      Language.reloadPhrases();
    }

    // Load if the user had fullscreen enabled the last time they had the game open.
    if (!initialized)
    {
      if (FlxG.save.data != null && FlxG.save.data.fullscreen)
      {
        FlxG.fullscreen = FlxG.save.data.fullscreen;
      }
    }

    // Configure the save binds and highscores on songs.
    FlxG.save.bind('funkin', CoolUtil.getSavePath());
    Highscore.load();

    // Add an event listener for when the user attempts
    // to go into fullscreen mode.
    #if desktop
    FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (_) ->
    {
      if (Controls.getControls().FULLSCREEN)
      {
        FlxG.fullscreen = !FlxG.fullscreen;
      }
    });
    #end

    // Disable the right-click context menu for web builds.
    #if web
    Browser.document.addEventListener('contextmenu', (e) ->
    {
      e.preventDefault();
    });
    #end

    // Bring the volume back up when the window is focused again.
    #if desktop
    Application.current.window.onFocusIn.add(() ->
    {
      if (isWindowFocused)
      {
        return;
      }

      // Cancel any ongoing tween.
      if (volumeTween != null && volumeTween.active)
      {
        volumeTween.cancel();
        volumeTween = null;
      }

      // Smoothly tween from current (minimized) volume back to lastVolume.
      volumeTween = FlxTween.num(FlxG.sound.volume, lastVolume, TWEEN_DURATION, null, (v:Float) ->
      {
        FlxG.sound.volume = v;
      });
      volumeTween.onComplete = (_) ->
      {
        lastVolume = FlxG.sound.volume;
      };
      isWindowFocused = true;
    });
    // Minimize the volume when the window loses focus.
    Application.current.window.onFocusOut.add(() ->
    {
      if (!isWindowFocused || (volumeTween != null && volumeTween.active))
      {
        return;
      }

      // Store the current (user) volume so we can restore it later.
      lastVolume = FlxG.sound.volume;

      var isMuted:Bool = FlxG.sound.muted || (Math.abs(FlxG.sound.volume) < FlxMath.EPSILON) || FlxG.sound.volume == 0;

      if (volumeTween != null)
      {
        volumeTween.cancel();
        volumeTween = null;
      }

      // Tween to a very low volume (or zero if already muted).
      volumeTween = FlxTween.num(FlxG.sound.volume, !isMuted ? MINIMIZED_VOLUME : 0, TWEEN_DURATION, null, (v:Float) ->
      {
        FlxG.sound.volume = v;
      });
      isWindowFocused = false;
    });
    // Save the volume the user originally had, just in
    // case they close the game while it's out of focus.
    Application.current.window.onClose.add(() ->
    {
      FlxG.save.data.mute = FlxG.sound.muted;
      FlxG.save.data.volume = lastVolume;
      FlxG.save.flush();
    });
    #end

    // Load all completed weeks.
    if (FlxG.save.data.weekCompleted != null)
    {
      StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
    }

    // Setup the user's controls.
    Controls.load();
    ClientPrefs.loadDefaultKeys();

    // Load all of the player's earned achievements.
    #if ACHIEVEMENTS_ALLOWED
    Achievements.load();
    #end

    // Set the scaling modes.
    // If the game is on desktop, it will be set to keep the viewport's
    // aspect ratio no matter the screen's size.
    // On mobile, however, it will be stretched out on the user's screen.
    #if !mobile
    Lib.current.stage.align = "tl";
    Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
    #end

    // Fix for the app icon not showing up on the Linux Panel / Mac Dock.
    #if (linux || mac)
    var icon = Image.fromFile("icon.png");
    Lib.current.stage.window.setIcon(icon);
    #end

    FlxG.autoPause = false; // This should ALWAYS be off!
    FlxG.mouse.useSystemCursor = true;
    FlxG.mouse.visible = false;

    // Some window configs.
    FlxG.fixedTimestep = false;
    FlxG.game.focusLostFramerate = 60;
    FlxG.keys.preventDefaultKeys = [TAB];

    // Setup the crash handler for when an uncaught exception is thrown.
    #if CRASH_HANDLER
    Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
    #end

    // Setup and prepare Discord rich presence.
    DiscordClient.prepare();

    // After everything has been setup, we can now safely
    // switch to the main menu of the game.
    FlxG.switchState(() -> new TitleState());
  }

  // Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!
  // Very cool person for real, they don't get enough credit for their work.
  #if CRASH_HANDLER
  function onCrash(e:UncaughtErrorEvent):Void
  {
    var errMsg:String = "";
    var path:String;
    var callStack:Array<StackItem> = CallStack.exceptionStack(true);
    var dateNow:String = Date.now().toString();

    dateNow = dateNow.replace(" ", "_");
    dateNow = dateNow.replace(":", "'");

    path = "./crash/" + "PolyverseEngine_" + dateNow + ".txt";

    for (stackItem in callStack)
    {
      switch (stackItem)
      {
        case FilePos(s, file, line, column):
          errMsg += file + " (line " + line + ")\n";
        default:
          Sys.println(stackItem);
      }
    }

    errMsg += "\nUncaught Error: " + e.error;
    // remove if you're modding and want the crash log message to contain the link
    // please remember to actually modify the link for the github page to report the issues to.
    #if officialBuild
    errMsg += "\nPlease report this error to the GitHub page: https://github.com/stringfromjava/FNF-PolyverseEngine";
    #end
    errMsg += "\n\n> Crash Handler written by: sqirra-rng";

    if (!FileSystem.exists("./crash/"))
    {
      FileSystem.createDirectory("./crash/");
    }

    File.saveContent(path, errMsg + "\n");

    Sys.println(errMsg);
    Sys.println("Crash dump saved in " + Path.normalize(path));

    Application.current.window.alert(errMsg, "Error!");
    #if DISCORD_ALLOWED
    DiscordClient.shutdown();
    #end
    Sys.exit(1);
  }
  #end
}
