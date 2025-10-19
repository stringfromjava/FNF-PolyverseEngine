package;

/**
 * A class with similar functionality to `FlxG`, except this class
 * has functions that pertain specifically to the game. This includes
 * functions such as closing the game with extra functionality, for example.
 */
final class FunkinG
{
  /**
   * Close the entire game.
   * 
   * @param sysShutdown Whether to close the game using the dedicated platform
   *                    shutdown method or not. Set this to `false` when you
   *                    just need to save the user's data and shutdown the utilities and
   *                    wish to shut the game down another way (i.e. throwing an exception).
   */
  public static function closeGame(sysShutdown:Bool = true):Void
  {
    ClientPrefs.saveSettings();
    DiscordClient.shutdown();

    if (sysShutdown)
    {
      #if web
      Browser.window.close();
      #elseif desktop
      Sys.exit(0);
      #end
    }
  }
}
