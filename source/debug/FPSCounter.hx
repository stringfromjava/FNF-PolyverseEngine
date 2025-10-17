package debug;

import flixel.FlxG;
import openfl.Assets;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
  The FPS class provides an easy-to-use monitor to display
  the current frame rate of an OpenFL project.
**/
class FPSCounter extends TextField
{
  /**
	 * The current frame rate, expressed using frames-per-second.
   */
  public var currentFPS(default, null):Int;

  /**
	 * The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory).
   */
  public var memoryMegas(get, never):Float;

  @:noCompletion
  var times:Array<Float>;

  public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
  {
    super();

    this.x = x;
    this.y = y;

    var fontName:String = Assets.getFont(Paths.font('Inconsolata-ExtraBold.ttf')).fontName;

    currentFPS = 0;
    selectable = false;
    mouseEnabled = false;
    defaultTextFormat = new TextFormat(fontName, 20, color);
    autoSize = LEFT;
    multiline = true;
    text = "FPS: ";

    times = [];
  }

  var deltaTimeout:Float = 0.0;

  override function __enterFrame(deltaTime:Float):Void
  {
    final now:Float = haxe.Timer.stamp() * 1000;
    times.push(now);
    while (times[0] < now - 1000)
    {
      times.shift();
    }

    if (deltaTimeout < 50)
    {
      deltaTimeout += deltaTime;
      return;
    }

    currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
    updateText();
    deltaTimeout = 0.0;
  }

  /**
   * Updates the text field with the current FPS and memory usage.
   */
  public dynamic function updateText():Void
  {
    text = 'FPS: ${currentFPS}' + '\nMemory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';

    textColor = 0xFFFFFFFF;
    if (currentFPS < FlxG.drawFramerate * 0.5)
    {
      textColor = 0xFFFF0000;
    }
  }

  inline function get_memoryMegas():Float
  {
    return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
  }
}
