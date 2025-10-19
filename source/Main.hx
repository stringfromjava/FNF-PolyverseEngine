package;

import backend.Highscore;
import debug.FPSCounter;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;
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
    initialState: InitState,
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

    // Set the current working directory for mobile platforms.
    // Credits to MAJigsaw77 for this code.
    #if android
    Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
    #elseif ios
    Sys.setCwd(lime.system.System.applicationStorageDirectory);
    #end

    // Load and configure the hxvlc library for
    // displaying videos in-game. 
    #if VIDEOS_ALLOWED
    hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end);
    #end

    Mods.loadTopMod();

    // Add the game to the window's display.
    addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

    // Add an FPS and memory usage display
    // on the top-left corner of the game's window.
    // (Only is enabled for non-mobile platforms!)
    #if !mobile
    fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
    addChild(fpsVar);
    if (fpsVar != null)
    {
      fpsVar.visible = ClientPrefs.data.showFPS;
    }
    #end

    // Reset the sprite cache when the screen is resized.
    // This to prevent some shaders that rely on the screen size
    // from breaking and causing weird formations on the display.
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
}
