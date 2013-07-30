package sx.mvc.app.base;
import cx.ConfigTools;
import flash.display.Sprite;
import mmvc.api.IViewContainer;
import mmvc.impl.Context;
import sx.mvc.app.AppView;

/**
 * ...
 * @author Jonas Nyström
 */
class AppBaseContext extends Context
{
	public var view(default, null):Sprite;
	public function new() 
	{
		var view = new sx.mvc.app.AppView();
		super(view);
		this.view = view;
	}
	
	override public function startup()
	{
		trace('AppContext startup');
		config();
		init();
		//mediatorMap.mapView(AppView, AppMediator);
	}
	
	function config() 
	{
	}
	
	function init()
	{
	}
}