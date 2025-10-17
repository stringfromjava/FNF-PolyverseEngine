package;

import backend.Highscore;
import debug.FPSCounter;
import flixel.FlxGame;
import flixel.FlxState;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import states.TitleState;
#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import psychlua.HScript.HScriptInfos;
#end
#if (linux || mac)
import lime.graphics.Image;
#end
#if CRASH_HANDLER
import haxe.CallStack;
import haxe.io.Path;
import openfl.events.UncaughtErrorEvent;
#end
#if android
import android.content.Context;
#end

// NATIVE API STUFF, YOU CAN IGNORE THIS AND SCROLL //
#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

/**
 * An anonymous structure that contains settings for the game's window and rendering.
 * This goes into the new `FlxGame` object that initializes the game.
 * 
 * You can also change the same settings in the `project.hxp` file, but this is
 * useful if you want to change the settings at runtime.
 */
typedef GameSettings =
{
  /**
   * The width of the game's viewport.
   */
  var width:Int;

  /**
   * The height of the game's viewport.
   */
  var height:Int;

  /**
   * A class reference (which should be of a subclass of `FlxState`) that
   * is the first state the game should switch to.
   */
  var initialState:Class<FlxState>;

  /**
   * How fast the game should run (in frames per second).
   * This also affects the draw rate of the game as well.
   */
  var framerate:Int;

  /**
   * Whether to skip the Flixel splash screen the user sees
   * when they open and launch the game.
   */
  var skipSplash:Bool;

  /**
   * Should the game start with covering the user's entire screen?
   */
  var startFullscreen:Bool;
}

/**
 * The main class that starts up the game. You do not need to worry about this
 * file, all of the setup routines you want to worry about can be found inside of
 * `InitState.hx`.
 */
class Main extends Sprite
{
  /**
   * FPS counter variable (to be used in non-mobile builds only).
   */
  public static var fpsVar:FPSCounter;

  static final game:GameSettings = {
    width: 1280,
    height: 720,
    initialState: TitleState,
    framerate: 60,
    skipSplash: true,
    startFullscreen: false
  };

  /**
   * The function that starts it all.
   * 
   * All this really does here is add the game to the window
   * so it can be seen visibly.
   */
  public static function main():Void
  {
    Lib.current.addChild(new Main());
  }

  public function new()
  {
    super();

    #if (cpp && windows)
    backend.Native.fixScaling();
    #end

    // Credits to MAJigsaw77 (he's the og author for this code)
    #if android
    Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
    #elseif ios
    Sys.setCwd(lime.system.System.applicationStorageDirectory);
    #end

    #if VIDEOS_ALLOWED
    hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end);
    #end

    #if LUA_ALLOWED
    Mods.pushGlobalMods();
    #end
    Mods.loadTopMod();

    FlxG.save.bind('funkin', CoolUtil.getSavePath());
    Highscore.load();

    #if LUA_ALLOWED
    Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call));
    #end

    Controls.instance = new Controls();
    ClientPrefs.loadDefaultKeys();
    #if ACHIEVEMENTS_ALLOWED
    Achievements.load();
    #end

    addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

    #if !mobile
    fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
    addChild(fpsVar);
    Lib.current.stage.align = "tl";
    Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
    if (fpsVar != null)
    {
      fpsVar.visible = ClientPrefs.data.showFPS;
    }
    #end

    #if (linux || mac) // fix the app icon not showing up on the Linux Panel / Mac Dock
    var icon = Image.fromFile("icon.png");
    Lib.current.stage.window.setIcon(icon);
    #end

    #if html5
    FlxG.autoPause = false;
    FlxG.mouse.visible = false;
    #end

    FlxG.fixedTimestep = false;
    FlxG.game.focusLostFramerate = 60;
    FlxG.keys.preventDefaultKeys = [TAB];

    #if CRASH_HANDLER
    Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
    #end

    #if DISCORD_ALLOWED
    DiscordClient.prepare();
    #end

    // shader coords fix
    FlxG.signals.gameResized.add(function(w, h)
    {
      if (FlxG.cameras != null)
      {
        for (cam in FlxG.cameras.list)
        {
          if (cam != null && cam.filters != null)
          {
            resetSpriteCache(cam.flashSprite);
          }
        }
      }

      if (FlxG.game != null)
      {
        resetSpriteCache(FlxG.game);
      }
    });
  }

  static function resetSpriteCache(sprite:Sprite):Void
  {
    @:privateAccess {
      sprite.__cacheBitmap = null;
      sprite.__cacheBitmapData = null;
    }
  }

  // Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
  // very cool person for real they don't get enough credit for their work
  #if CRASH_HANDLER
  function onCrash(e:UncaughtErrorEvent):Void
  {
    var errMsg:String = "";
    var path:String;
    var callStack:Array<StackItem> = CallStack.exceptionStack(true);
    var dateNow:String = Date.now().toString();

    dateNow = dateNow.replace(" ", "_");
    dateNow = dateNow.replace(":", "'");

    path = "./crash/" + "PsychEngine_" + dateNow + ".txt";

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
    errMsg += "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine";
    #end
    errMsg += "\n\n> Crash Handler written by: sqirra-rng";

    if (!FileSystem.exists("./crash/"))
      FileSystem.createDirectory("./crash/");

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
