package print.mgr.view;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import print.mgr.model.PrinterConfig;
import ru.stablex.ui.widgets.Checkbox;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Toggle;
import ru.stablex.ui.widgets.VBox;
import sx.ScorxColors;

import ru.stablex.ui.skins.Paint;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Widget;
import sx.mvc.view.HBoxView;
import sx.mvc.view.VBoxView;

/**
 * ...
 * @author 
 */
class ThumbnailsView extends HBoxView 
 {
	 
	private var clickable:Bool;
	var widget:Widget;
	public var btn:Button;	
	
	public var print(default, null):Bool;
	
	override public function createChildren() 
	 {
		 this.align = 'left';
		/*
		 this.btn = UIBuilder.create(Button);
		this.btn.text = "ThumbnailsView";
		this.btn.w = 140;
		this.addChild(this.btn);
		*/
		
		this.w = Constants.MANAGER_VIEW_W;
		this.h = Constants.MANAGER_VIEW_H;
	}
	
	override public function addSkin() 
	{		
		var skin:Paint = new Paint();
		skin.color = 0x222222;
		skin.apply(this);
	}	
	
	public function init(nrOfPages:Int)
	{
		

		while (this.numChildren > 0) this.removeChildAt(0);
		this.clickable = true;
	}
	
	public function addPage(pageNr:Int, data:BitmapData)
	{
		var parent:Widget = this;
		
		widget = UIBuilder.create(Widget);
		var idx = Std.int(Math.min(parent.numChildren, pageNr));
		trace([pageNr, idx]);
		parent.addChildAt(widget, idx);
		widget.y = 8;
		widget.w = 114;
		widget.h = 180;
		
		var bmp:Bmp = UIBuilder.create(Bmp);
		bmp.bitmapData = data;
		bmp.w = 105;
		bmp.x = 3;
		bmp.y = 3;
		bmp.h = 148;
		
		var child : DisplayObject = cast bmp;
		child.width = 105;
		child.height = 148;		
		widget.addChild(bmp);

		/*
		var labelNr:Text = UIBuilder.create(Text);
		labelNr.text = "Sid " + pageNr;
		widget.addChild(labelNr);		
		*/
		
		
		var cb:Toggle = UIBuilder.create(Toggle);
		cb.down();
		cb.x = 16;
		cb.y = 154;
		cb.w = 70;
		cb.h = 20;
		cb.text = "Sid " + (pageNr+1);
		widget.addChild(cb);
		cb.onPress = function(e) 
		{			
			var value:Bool = (cb.state == 'up');
			this.toggle(pageNr, value);			
		};
	
		parent.refresh();
	}
	
	public function freeze()
	{
		this.clickable = false;
	}
	
	dynamic public function toggle(pageNr:Int, value:Bool)
	{
		trace('x');
	}
	

	
	
}

class ThumbnailsMediator extends mmvc.impl.Mediator<ThumbnailsView>
{
	@inject public var printConfig:PrinterConfig;
	
	override function onRegister() 
	 {
		trace('ThumbnailsMediator registered');	
		
		/*
		this.view.btn.onPress = function(e)
		{
			// do something...
		};		
		*/
		
		this.view.toggle = function(pageNr:Int, value:Bool)
		{
			trace(['toggle', pageNr, value]);
			trace(printConfig.getSelectedPages());			
			printConfig.setPage(pageNr, value);			
		}
		
	}	

}



/*

import print.mgr.view.Thumbnails.ThumbnailsView;
import print.mgr.view.Thumbnails.ThumbnailsMediator;


mediatorMap.mapView(ThumbnailsView, ThumbnailsMediator);

*/