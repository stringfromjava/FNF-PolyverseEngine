package backend;

#if DISCORD_ALLOWED
import cpp.ConstCharStar;
import cpp.RawConstPointer;
import flixel.util.FlxStringUtil;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types.DiscordEventHandlers;
import hxdiscord_rpc.Types.DiscordRichPresence;
import hxdiscord_rpc.Types.DiscordUser;
import lime.app.Application;
import sys.thread.Thread;
#end

/**
 * Utility class which handles Discord rich presence
 * in the user's Discord "Activity" box.
 */
final class DiscordClient
{
  /**
   * Is Discord presence currently active?
   */
  public static var isInitialized:Bool = false;

  #if DISCORD_ALLOWED
  /**
   * The current Discord client set. This is the ID of a Discord application
   * that is used to connect and display 
   */
  public static var clientID(default, set):String = DEFAULT_CLIENT_ID;

  static inline final DEFAULT_CLIENT_ID:String = '863222024192262205';
  static var presence:DiscordPresence = new DiscordPresence();

  // Hide this field from scripts.
  @:unreflective static var __thread:Thread;
  #end

  function new() {}

  /**
   * Run a check on whether the game's rich presence is either setup or shutdown,
   * then act accordingly.
   */
  public static function check():Void
  {
    #if DISCORD_ALLOWED
    if (ClientPrefs.data.discordRPC)
    {
      initialize();
    }
    else if (isInitialized)
    {
      shutdown();
    }
    #end
  }

  /**
   * Prepares Discord rich presence on the pre-setup in `InitState.hx`.
   */
  public static function prepare():Void
  {
    #if DISCORD_ALLOWED
    if (!isInitialized && ClientPrefs.data.discordRPC)
    {
      initialize();
    }

    Application.current.window.onClose.add(function()
    {
      if (isInitialized)
      {
        shutdown();
      }
    });
    #end
  }

  /**
   * Shuts down Discord rich presence. Should only be called after `initialize()` is called!
   */
  public static function shutdown():Void
  {
    #if DISCORD_ALLOWED
    isInitialized = false;
    Discord.Shutdown();
    #end
  }

  static function onReady(request:RawConstPointer<DiscordUser>):Void
  {
    final user:String = cast(request[0].username, String);
    final discriminator:String = cast(request[0].discriminator, String);

    var message:String = '(Discord) Connected to User ';
    if (discriminator != '0') // Old discriminators
      message += '($user#$discriminator)';
    else // New Discord IDs/Discriminator system
      message += '($user)';

    trace(message);
    changePresence();
  }

  static function onError(errorCode:Int, message:ConstCharStar):Void
  {
    trace('Discord: Error ($errorCode: ${cast (message, String)})');
  }

  static function onDisconnected(errorCode:Int, message:ConstCharStar):Void
  {
    trace('Discord: Disconnected ($errorCode: ${cast (message, String)})');
  }

  /**
   * Setup Discord rich presence.
   * 
   * This should be called ONLY once. After you 
   */
  public static function initialize():Void
  {
    #if DISCORD_ALLOWED
    var discordHandlers:DiscordEventHandlers = DiscordEventHandlers.create();
    discordHandlers.ready = cpp.Function.fromStaticFunction(onReady);
    discordHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
    discordHandlers.errored = cpp.Function.fromStaticFunction(onError);
    Discord.Initialize(clientID, cpp.RawPointer.addressOf(discordHandlers), 1, null);

    if (!isInitialized)
      trace("Discord Client initialized");

    if (__thread == null)
    {
      __thread = Thread.create(() ->
      {
        while (true)
        {
          if (isInitialized)
          {
            #if DISCORD_DISABLE_IO_THREAD
            Discord.UpdateConnection();
            #end
            Discord.RunCallbacks();
          }

          // Wait 1 second until the next loop...
          Sys.sleep(1.0);
        }
      });
    }
    isInitialized = true;
    #end
  }

  /**
   * Change the presence display in the user's Discord "Activity" box.
   * 
   * @param details           The details to be displayed. Some examples might be "In the Menus", "Changing Options", etc.
   * @param state             The current state the user is in (this does NOT mean Flixel states!).
   * @param smallImageKey     The ID of the small icon that is displayed in the bottom-right corner of the icon in the presence.
   * @param hasStartTimestamp Does the user have an already started timestamp? 
   * @param endTimestamp      The ended timestamp.
   * @param largeImageKey     The ID of the large image display. This is the main icon users on Discord would see on the current presence.
   */
  public static function changePresence(details:String = 'In the Menus', ?state:String, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float,
      largeImageKey:String = 'icon'):Void
  {
    #if DISCORD_ALLOWED
    var startTimestamp:Float = 0;
    if (hasStartTimestamp)
      startTimestamp = Date.now().getTime();
    if (endTimestamp > 0)
      endTimestamp = startTimestamp + endTimestamp;

    presence.state = state;
    presence.details = details;
    presence.smallImageKey = smallImageKey;
    presence.largeImageKey = largeImageKey;
    presence.largeImageText = "Engine Version: " + states.MainMenuState.psychEngineVersion;
    // Obtained times are in milliseconds so they are divided so Discord can use it
    presence.startTimestamp = Std.int(startTimestamp / 1000);
    presence.endTimestamp = Std.int(endTimestamp / 1000);
    updatePresence();
    #end
  }

  /**
   * Send an update to the 
   */
  public static function updatePresence():Void
  {
    #if DISCORD_ALLOWED
    Discord.UpdatePresence(RawConstPointer.addressOf(presence.__presence));
    #end
  }

  public static inline function resetClientID():Void
  {
    #if DISCORD_ALLOWED
    clientID = DEFAULT_CLIENT_ID;
    #end
  }

  #if DISCORD_ALLOWED
  static function set_clientID(newID:String):String
  {
    var change:Bool = (clientID != newID);
    clientID = newID;

    if (change && isInitialized)
    {
      shutdown();
      initialize();
      updatePresence();
    }
    return newID;
  }
  #end

  #if MODS_ALLOWED
  public static function loadModRPC()
  {
    #if DISCORD_ALLOWED
    var pack:Dynamic = Mods.getPack();
    if (pack != null && pack.discordRPC != null && pack.discordRPC != clientID)
    {
      clientID = pack.discordRPC;
      // trace('Changing clientID! $clientID, $_defaultID');
    }
    #end
  }
  #end
}

#if DISCORD_ALLOWED
@:allow(backend.DiscordClient)
private final class DiscordPresence
{
  public var state(get, set):String;
  public var details(get, set):String;
  public var smallImageKey(get, set):String;
  public var largeImageKey(get, set):String;
  public var largeImageText(get, set):String;
  public var startTimestamp(get, set):Int;
  public var endTimestamp(get, set):Int;

  @:noCompletion private var __presence:DiscordRichPresence;

  function new()
  {
    __presence = DiscordRichPresence.create();
  }

  public function toString():String
  {
    return FlxStringUtil.getDebugString([
      LabelValuePair.weak("state", state),
      LabelValuePair.weak("details", details),
      LabelValuePair.weak("smallImageKey", smallImageKey),
      LabelValuePair.weak("largeImageKey", largeImageKey),
      LabelValuePair.weak("largeImageText", largeImageText),
      LabelValuePair.weak("startTimestamp", startTimestamp),
      LabelValuePair.weak("endTimestamp", endTimestamp)
    ]);
  }

  @:noCompletion inline function get_state():String
  {
    return __presence.state;
  }

  @:noCompletion inline function set_state(value:String):String
  {
    return __presence.state = value;
  }

  @:noCompletion inline function get_details():String
  {
    return __presence.details;
  }

  @:noCompletion inline function set_details(value:String):String
  {
    return __presence.details = value;
  }

  @:noCompletion inline function get_smallImageKey():String
  {
    return __presence.smallImageKey;
  }

  @:noCompletion inline function set_smallImageKey(value:String):String
  {
    return __presence.smallImageKey = value;
  }

  @:noCompletion inline function get_largeImageKey():String
  {
    return __presence.largeImageKey;
  }

  @:noCompletion inline function set_largeImageKey(value:String):String
  {
    return __presence.largeImageKey = value;
  }

  @:noCompletion inline function get_largeImageText():String
  {
    return __presence.largeImageText;
  }

  @:noCompletion inline function set_largeImageText(value:String):String
  {
    return __presence.largeImageText = value;
  }

  @:noCompletion inline function get_startTimestamp():Int
  {
    return __presence.startTimestamp;
  }

  @:noCompletion inline function set_startTimestamp(value:Int):Int
  {
    return __presence.startTimestamp = value;
  }

  @:noCompletion inline function get_endTimestamp():Int
  {
    return __presence.endTimestamp;
  }

  @:noCompletion inline function set_endTimestamp(value:Int):Int
  {
    return __presence.endTimestamp = value;
  }
}
#end
