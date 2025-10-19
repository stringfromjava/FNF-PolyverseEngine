package backend;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

/**
 * Utility class for checking what binds the user is pressing 
 * based on their controls set for the said binds.
 */
final class Controls
{
  /**
   * Is controller mode currently enabled?
   * This is usually set to `true` when the user
   * presses a button on a connected gamepad.
   */
  public static var controllerMode:Bool = false;

  /**
   * Loads all the user's binds.
   * This is only called once in `InitState.hx`.
   */
  public static function load():Void
  {
    keyboardBinds = ClientPrefs.keyBinds;
    gamepadBinds = ClientPrefs.gamepadBinds;
  }

  /**
   * Gets and returns an instance of `Controls` with variables
   * of all currently pressed keys.
   * 
   * @return An instance of `Controls` with all currently pressed keys.
   */
  public static function getControls():Controls
  {
    return new Controls();
  }

  /**
   * A `Map` of all binds that are connected to keys on the keyboard set 
   * by the user.
   * 
   * It's done with this simple format:
   * 
   * ```haxe
   * [
   *   'ui_left' => [W, UP] // Notice how the key is the bind ID, and the value is an array with two keys.
   * ]
   * ```
   * 
   * Note that any keys after the first two will be ignored!
   */
  static var keyboardBinds:Map<String, Array<FlxKey>>;

  /**
   * Gets a copied array of the user's bind settings for the keyboard.
   * 
   * @return A shallow copy of the user's set binds.
   */
  public static function getKeyboardBinds():Map<String, Array<FlxKey>>
  {
    return keyboardBinds.copy();
  }

  /**
   * A `Map` of all binds that are connected to buttons on a gamepad set 
   * by the user.
   * 
   * It's done with this simple format:
   * 
   * ```haxe
   * [
   *   'ui_left' => [DPAD_UP, LEFT_STICK_DIGITAL_UP] // Notice how the key is the bind ID, and the value is an array with two buttons.
   * ]
   * ```
   * 
   * Note that any buttons after the first two will be ignored!
   */
  static var gamepadBinds:Map<String, Array<FlxGamepadInputID>>;

  /**
   * Gets a copied array of the user's bind settings for the keyboard.
   * 
   * @return A shallow copy of the user's set binds.
   */
  public static function getGamepadBinds():Map<String, Array<FlxGamepadInputID>>
  {
    return gamepadBinds.copy();
  }

  function new() {}

  public var UI_UP_JP(get, never):Bool;
  public var UI_DOWN_JP(get, never):Bool;
  public var UI_LEFT_JP(get, never):Bool;
  public var UI_RIGHT_JP(get, never):Bool;

  function get_UI_UP_JP():Bool
  {
    return justPressed('ui_up');
  }

  function get_UI_DOWN_JP():Bool
  {
    return justPressed('ui_down');
  }

  function get_UI_LEFT_JP():Bool
  {
    return justPressed('ui_left');
  }

  function get_UI_RIGHT_JP():Bool
  {
    return justPressed('ui_right');
  }

  public var NOTE_UP_P(get, never):Bool;
  public var NOTE_DOWN_P(get, never):Bool;
  public var NOTE_LEFT_P(get, never):Bool;
  public var NOTE_RIGHT_P(get, never):Bool;

  function get_NOTE_UP_P():Bool
  {
    return justPressed('note_up');
  }

  function get_NOTE_DOWN_P():Bool
  {
    return justPressed('note_down');
  }

  function get_NOTE_LEFT_P():Bool
  {
    return justPressed('note_left');
  }

  function get_NOTE_RIGHT_P():Bool
  {
    return justPressed('note_right');
  }

  // Held buttons (directions)
  public var UI_UP(get, never):Bool;
  public var UI_DOWN(get, never):Bool;
  public var UI_LEFT(get, never):Bool;
  public var UI_RIGHT(get, never):Bool;

  function get_UI_UP():Bool
  {
    return pressed('ui_up');
  }

  function get_UI_DOWN():Bool
  {
    return pressed('ui_down');
  }

  function get_UI_LEFT():Bool
  {
    return pressed('ui_left');
  }

  function get_UI_RIGHT():Bool
  {
    return pressed('ui_right');
  }

  public var NOTE_UP(get, never):Bool;
  public var NOTE_DOWN(get, never):Bool;
  public var NOTE_LEFT(get, never):Bool;
  public var NOTE_RIGHT(get, never):Bool;

  function get_NOTE_UP():Bool
  {
    return pressed('note_up');
  }

  function get_NOTE_DOWN():Bool
  {
    return pressed('note_down');
  }

  function get_NOTE_LEFT():Bool
  {
    return pressed('note_left');
  }

  function get_NOTE_RIGHT():Bool
  {
    return pressed('note_right');
  }

  // Released buttons (directions)
  public var UI_UP_R(get, never):Bool;
  public var UI_DOWN_R(get, never):Bool;
  public var UI_LEFT_R(get, never):Bool;
  public var UI_RIGHT_R(get, never):Bool;

  function get_UI_UP_R():Bool
  {
    return justReleased('ui_up');
  }

  function get_UI_DOWN_R():Bool
  {
    return justReleased('ui_down');
  }

  function get_UI_LEFT_R():Bool
  {
    return justReleased('ui_left');
  }

  function get_UI_RIGHT_R():Bool
  {
    return justReleased('ui_right');
  }

  public var NOTE_UP_R(get, never):Bool;
  public var NOTE_DOWN_R(get, never):Bool;
  public var NOTE_LEFT_R(get, never):Bool;
  public var NOTE_RIGHT_R(get, never):Bool;

  function get_NOTE_UP_R():Bool
  {
    return justReleased('note_up');
  }

  function get_NOTE_DOWN_R():Bool
  {
    return justReleased('note_down');
  }

  function get_NOTE_LEFT_R():Bool
  {
    return justReleased('note_left');
  }

  function get_NOTE_RIGHT_R():Bool
  {
    return justReleased('note_right');
  }

  // Pressed buttons (others)
  public var ACCEPT(get, never):Bool;
  public var BACK(get, never):Bool;
  public var PAUSE(get, never):Bool;
  public var RESET(get, never):Bool;
  public var FULLSCREEN(get, never):Bool;

  function get_ACCEPT():Bool
  {
    return justPressed('accept');
  }

  function get_BACK():Bool
  {
    return justPressed('back');
  }

  function get_PAUSE():Bool
  {
    return justPressed('pause');
  }

  function get_RESET():Bool
  {
    return justPressed('reset');
  }

  function get_FULLSCREEN():Bool
  {
    return justPressed('fullscreen');
  }

  /**
   * Gets a bind that was just pressed by its ID.
   * 
   * @param key The bind to search for.
   * @return If the bind given was just pressed.
   */
  public static function justPressed(key:String):Bool
  {
    var result:Bool = FlxG.keys.anyJustPressed(keyboardBinds[key]);
    if (result)
    {
      controllerMode = false;
    }

    return result || myGamepadJustPressed(gamepadBinds[key]);
  }

  /**
   * Gets a bind that is currently pressed by its ID.
   * 
   * @param key The bind to search for.
   * @return If the bind given is currently pressed.
   */
  public static function pressed(key:String):Bool
  {
    var result:Bool = FlxG.keys.anyPressed(keyboardBinds[key]);
    if (result)
    {
      controllerMode = false;
    }

    return result || myGamepadPressed(gamepadBinds[key]);
  }

  /**
   * Gets a bind that was just released by its ID.
   * 
   * @param key The bind to search for.
   * @return If the bind given was just released.
   */
  public static function justReleased(key:String):Bool
  {
    var result:Bool = FlxG.keys.anyJustReleased(keyboardBinds[key]);
    if (result)
    {
      controllerMode = false;
    }

    return result || myGamepadJustReleased(gamepadBinds[key]);
  }

  static function myGamepadJustPressed(keys:Array<FlxGamepadInputID>):Bool
  {
    if (keys != null)
    {
      for (key in keys)
      {
        if (FlxG.gamepads.anyJustPressed(key))
        {
          controllerMode = true;
          return true;
        }
      }
    }
    return false;
  }

  static function myGamepadPressed(keys:Array<FlxGamepadInputID>):Bool
  {
    if (keys != null)
    {
      for (key in keys)
      {
        if (FlxG.gamepads.anyPressed(key))
        {
          controllerMode = true;
          return true;
        }
      }
    }
    return false;
  }

  static function myGamepadJustReleased(keys:Array<FlxGamepadInputID>):Bool
  {
    if (keys != null)
    {
      for (key in keys)
      {
        if (FlxG.gamepads.anyJustReleased(key))
        {
          controllerMode = true;
          return true;
        }
      }
    }
    return false;
  }
}
