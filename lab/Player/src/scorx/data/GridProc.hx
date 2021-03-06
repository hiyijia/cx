package scorx.data;
import sx.player.grid.PageBar;
import sx.player.grid.PageBars;
import sx.player.grid.GridBar;
import sx.player.grid.GridSystem;
import sx.player.grid.GridSystems;
import cx.flash.layout.DocumentLayout.DocInfo;
import flash.geom.Rectangle;
import sx.player.grid.PointerPosition;
/**
 * ...
 * @author Jonas Nyström
 */
class GridProc
{

	public var gridSystems(default, null):GridSystems;
	public var pageBars(default, null):PageBars;		
	public var pageCoordinates(default, null):Map<Int, Rectangle>;	
	public var sysCoordinates(default, null):Map<PageBar, Rectangle>;
	
	public function new() 
	{
		trace("New GridProc");
	}
	
	public function init(xmlString:String=null) 
	{
		//var xmlString:String = this.testXmlNonWorking();
		//this.gridSystems = this.xmlToGridSystems(xmlString);		
		
		this.gridSystems = (xmlString != null) ? this.xmlToGridSystems(xmlString) : this.testGridSystems();
		this.afterInit(this.gridSystems);			
		
		try 
		{
			this.afterInit(this.gridSystems);			
		}
		catch (e:Dynamic)
		{
			this.gridSystems = null;
			throw "Grid Error: " + xmlString;
		}
		
	}
	
	dynamic public function afterInit(gridSystems:GridSystems)
	{
		trace('AFTER INIT');
		
	}
	
	private function debugGridSystems(gridSystems:GridSystems)
	{
		for (gridSystem in gridSystems.systems)
		{
			//trace(' - sys ' + gridSystem.pos);
			for (gridBar in gridSystem.bars)
			{
				//trace(' - bar ' + gridBar.pos);
			}
		}
	}	
	
	public function getPageBars(docInfo:DocInfo):PageBars
	{		
		if (docInfo.pageInfos == null) return null;
		if (docInfo.pageInfos.length < 1) return null;
		
		this.pageBars = [];
		this.pageCoordinates = new Map<Int, Rectangle>();
		this.sysCoordinates = new Map<PageBar, Rectangle>();
							
		var systemIdx:Int = 0;
		var barIdx:Int = 0;
		for (gridSystem in gridSystems.systems)
		{		
			var nextSystemPos:Float = -1;
			nextSystemPos =  (systemIdx == gridSystems.systems.length - 1) ? 1 : gridSystems.systems[systemIdx + 1].pos;
			
			
			var pageNr:Int = gridSystem.pageNr;
			if (pageNr > docInfo.pageInfos.length) throw "GRID PAGE NR OVERFLOW";
			
			//trace(pageNr + ' ' + docInfo.pageInfos[pageNr].rect);
			var pageRect = docInfo.pageInfos[pageNr].rect;
			var pageHeight = pageRect.height;
			var pageWidth = pageRect.width;
			
			var systemRect:Rectangle = new Rectangle(
				pageRect.x + gridSystem.x * pageWidth, 
				pageRect.y + gridSystem.y * pageHeight, 
				gridSystem.width * pageWidth,
				gridSystem.height * pageHeight
				);
			
			// if system has no bar
			if (gridSystem.bars == null || gridSystem.bars.length == 0)
			{
				var pageBar:PageBar = { pageIdx:gridSystem.pageNr, barIdx:barIdx, sysIdx: systemIdx, pos: gridSystem.pos, nextPos:nextSystemPos, rect:systemRect, deltaX:-1  };
				this.pageBars.push(pageBar);
				barIdx++;
				this.pageCoordinates.set(pageBar.pageIdx, pageRect);
				this.sysCoordinates.set(pageBar, systemRect);
			} 
			// if system has one or many bars
			else
			{	
				// first bar on system...
				var barRect:Rectangle = systemRect.clone();
				barRect.width = gridSystem.bars[0].x * pageWidth;
				var pageBar:PageBar = { pageIdx:gridSystem.pageNr, barIdx:barIdx, sysIdx: systemIdx, pos: gridSystem.pos, nextPos:gridSystem.bars[0].pos, rect:barRect, deltaX:-1  };				
				this.pageBars.push(pageBar);
				barIdx++;
				this.pageCoordinates.set(pageBar.pageIdx, pageRect);
				this.sysCoordinates.set(pageBar, systemRect);
				
				//other bars
				for (i in 0...gridSystem.bars.length)
				{
					var gridBar:GridBar = gridSystem.bars[i];
					var barX = systemRect.x + gridBar.x * pageWidth;
					var barX2:Float = 0;
					var nextPos:Float = 0;
					
					// up to last bar on system
					if (i < gridSystem.bars.length-1)
					{
						//trace('Other bar');
						var nextGridBar:GridBar = gridSystem.bars[i + 1];
						//nextPos = nextGridBar.pos;
						barX2 = systemRect.x + nextGridBar.x * pageWidth;	
						nextPos = gridSystem.bars[i + 1].pos;
					}
					else
					// last bar on system
					{
						
						barX2 = systemRect.x + systemRect.width;
						nextPos = nextSystemPos;
					}										
					
					var barRect:Rectangle = new Rectangle(barX, systemRect.y, barX2 - barX, systemRect.height);
					var pageBar:PageBar = { pageIdx:gridSystem.pageNr, barIdx:barIdx, sysIdx: systemIdx, pos: gridBar.pos, nextPos:nextPos, rect: barRect, deltaX:-1 };
					this.pageBars.push(pageBar);
					barIdx++;
					this.pageCoordinates.set(pageBar.pageIdx, pageRect);
					this.sysCoordinates.set(pageBar, systemRect);
					
				}				
			}
			
			systemIdx++;
		}		
		return this.pageBars;
	}	
	
	public function getPositionFromCoords(x:Float, y:Float):Float
	{
		for (pageBar in pageBars)
		{
			if (pageBar.rect.contains(x, y))
			{
				var delta:Float = (x - pageBar.rect.x) / pageBar.rect.width;
				return pageBar.pos + delta * (pageBar.nextPos-pageBar.pos);
			}			
		}
		return -1;
	}
	
	public function getPageCoordinates(pageIdx:Int):Rectangle
	{
		if (this.pageCoordinates == null) return null;
		return this.pageCoordinates.get(pageIdx);		
	}
	
	
	
	public function setPointerPosition(value:Float)
	{
		var pageBar:PageBar = findPageBarFromPos(value);
		this.updatePointerPosition(pageBar);
	}
	
	dynamic public function updatePointerPosition(pageBar:PageBar)
	{
		
	}
	
	public function findPageBarFromPos(currentPos:Float):PageBar
	{
		var count:Int = this.pageBars.length;		
		for (i in 0...count)
		{
			var pageBar = this.pageBars[count-1 - i];
			if (currentPos > pageBar.pos)
			{				
				var span:Float = (currentPos - pageBar.pos)/ (pageBar.nextPos - pageBar.pos) ;				
				pageBar.deltaX = pageBar.rect.x + (span * pageBar.rect.width);				
				return pageBar;
			}			
		}
		// before first bar:
		return {
			pageIdx:pageBars[0].pageIdx,
			barIdx:0,
			sysIdx:0,
			pos:0,
			nextPos:pageBars[0].pos,
			rect:pageBars[0].rect,
			deltaX:pageBars[0].rect.x,
		}
	}
	
	private function xmlToGridSystems(xmlString:String): GridSystems
	{
		var gridSystems:GridSystems = { systems: new Array<GridSystem>() };
		
		var xml:Xml = Xml.parse(xmlString);		
		var items = xml.elements().next().elements();
		
		var gridSystem:GridSystem = null;
		
		for (item in items)
		{
			trace(item.get('type'));
			var pos:Float = getFloat(item.get('pos'));
			var pageNr:Int = Std.parseInt(item.get('page'));
			var x:Float = getFloat(item.get('x'));
			var y:Float = getFloat(item.get('y'));
			var w:Float = getFloat(item.get('w'));
			var h:Float = getFloat(item.get('h'));		
			trace(item.get('pos'));
			
			switch (item.get('type'))
			{
				case 'system':
					gridSystem = { pos: pos, pageNr: pageNr, x: x, y: y, width: w, height: h, bars: [] };	
					gridSystems.systems.push(gridSystem);
				case 'bar':
					var gridBar:GridBar = { pos: pos, x: x };
					gridSystem.bars.push(gridBar);
				default:
			}
		}
		return gridSystems;
	}
	
	private function getFloat(floatStr:String):Float
	{
		floatStr = StringTools.replace(floatStr, ',', '.');
		return Std.parseFloat(floatStr);
	}	
	
	
	private function testXmlNonWorking():String
	{
		return 
		'

<grid id="133" title="Den dödsdömde">
<item  pos="0,063029791424853"  type="system"  page="2"   x="0,1359375"  y="0,15039281705948"  w="0,74126984126984" h="0,18069584736251"  />
<item  pos="0,095670219127009"  type="bar"  page="2"   x="0,14285714285714"  y="0,15039281705948"  w="0" h="0,18069584736251"  />
<item  pos="0,12605958284971"  type="bar"  page="2"   x="0,25555555555556"  y="0,15039281705948"  w="0" h="0,18069584736251"  />
<item  pos="0,13506383876754"  type="bar"  page="2"   x="0,34603174603175"  y="0,15039281705948"  w="0" h="0,18069584736251"  />
<item  pos="0,17445745840808"  type="bar"  page="2"   x="0,44603174603175"  y="0,15039281705948"  w="0" h="0,18069584736251"  />
<item  pos="0,18233618233618"  type="bar"  page="2"   x="0,51746031746032"  y="0,15039281705948"  w="0" h="0,18069584736251"  />
<item  pos="0,20484682213077"  type="bar"  page="2"   x="0,63174603174603"  y="0,15039281705948"  w="0" h="0,18069584736251"  />
<item  pos="0,23073405789455"  type="system"  page="2"   x="0,146875"  y="0,39281705948373"  w="0,73174603174603" h="0,17732884399551"  />
<item  pos="0,27012767753508"  type="bar"  page="2"   x="0,12380952380952"  y="0,39281705948373"  w="0" h="0,17732884399551"  />
<item  pos="0,27800640146319"  type="bar"  page="2"   x="0,21428571428571"  y="0,39281705948373"  w="0" h="0,17732884399551"  />
<item  pos="0,30389363722697"  type="bar"  page="2"   x="0,32063492063492"  y="0,39281705948373"  w="0" h="0,17732884399551"  />
<item  pos="0,33586523073406"  type="bar"  page="2"   x="0,46031746031746"  y="0,39281705948373"  w="0" h="0,17732884399551"  />
<item  pos="0,34486948665189"  type="bar"  page="2"   x="0,55555555555556"  y="0,39281705948373"  w="0" h="0,17732884399551"  />
<item  pos="0,35725033853892"  type="bar"  page="2"   x="0,61746031746032"  y="0,39281705948373"  w="0" h="0,17732884399551"  />
<item  pos="0,38324584080757"  type="bar"  page="2"   x="0,68888888888889"  y="0,39281705948373"  w="0" h="0,17732884399551"  />
<item  pos="0,39393619640533"  type="system"  page="2"   x="0,1375"  y="0,67901234567901"  w="0,40952380952381" h="0,17845117845118"  />
<item  pos="0,41757236818965"  type="bar"  page="2"   x="0,12063492063492"  y="0,67901234567901"  w="0" h="0,17845117845118"  />
<item  pos="0,44345960395343"  type="bar"  page="2"   x="0,25873015873016"  y="0,67901234567901"  w="0" h="0,17845117845118"  />
<item  pos="0,47047237170694"  type="bar"  page="2"   x="0,34285714285714"  y="0,67901234567901"  w="0" h="0,17845117845118"  />
<item  pos="0,52562343920369"  type="system"  page="2"   x="0,140625"  y="0,15151515151515"  w="0,73968253968254" h="0,18518518518519"  />
<item  pos="0,55826386690584"  type="bar"  page="2"   x="0,14126984126984"  y="0,15151515151515"  w="0" h="0,18518518518519"  />
<item  pos="0,590904294608"  type="bar"  page="2"   x="0,25555555555556"  y="0,15151515151515"  w="0" h="0,18518518518519"  />
<item  pos="0,5987830185361"  type="bar"  page="2"   x="0,34285714285714"  y="0,15151515151515"  w="0" h="0,18518518518519"  />
<item  pos="0,63817663817664"  type="bar"  page="2"   x="0,44285714285714"  y="0,15151515151515"  w="0" h="0,18518518518519"  />
<item  pos="0,64605536210474"  type="bar"  page="2"   x="0,51428571428571"  y="0,15151515151515"  w="0" h="0,18518518518519"  />
<item  pos="0,66969153388906"  type="bar"  page="2"   x="0,62857142857143"  y="0,15151515151515"  w="0" h="0,18518518518519"  />
<item  pos="0,69445323766311"  type="system"  page="2"   x="0,1484375"  y="0,39393939393939"  w="0,73015873015873" h="0,17957351290685"  />
<item  pos="0,73384685730365"  type="bar"  page="2"   x="0,12857142857143"  y="0,39393939393939"  w="0" h="0,17957351290685"  />
<item  pos="0,74397664521121"  type="bar"  page="2"   x="0,21111111111111"  y="0,39393939393939"  w="0" h="0,17957351290685"  />
<item  pos="0,76986388097499"  type="bar"  page="2"   x="0,32222222222222"  y="0,39393939393939"  w="0" h="0,17957351290685"  />
<item  pos="0,80066460245858"  type="bar"  page="2"   x="0,46190476190476"  y="0,39393939393939"  w="0" h="0,17957351290685"  />
<item  pos="0,80741779439696"  type="bar"  page="2"   x="0,55555555555556"  y="0,39393939393939"  w="0" h="0,17957351290685"  />
<item  pos="0,8243007742429"  type="bar"  page="2"   x="0,61746031746032"  y="0,39393939393939"  w="0" h="0,17957351290685"  />
<item  pos="0,84620083491611"  type="bar"  page="2"   x="0,68888888888889"  y="0,39393939393939"  w="0" h="0,17957351290685"  />
<item  pos="0,85694120194506"  type="system"  page="2"   x="0,5609375"  y="0,67564534231201"  w="0,32539682539683" h="0,18518518518519"  />
<item  pos="0,88395396969857"  type="bar"  page="2"   x="0,10952380952381"  y="0,67564534231201"  w="0" h="0,18518518518519"  />
<item  pos="0,91321780143154"  type="bar"  page="2"   x="0,19365079365079"  y="0,67564534231201"  w="0" h="0,18518518518519"  />
<item  pos="0,91884546138018"  type="bar"  page="2"   x="0,24761904761905"  y="0,67564534231201"  w="0" h="0,18518518518519"  />
</grid>		
		
		';
	}
	
	
	private function testXml():String
	{
		return 
		'
<grid id="43" title="Waldesnacht">
<item  pos="0,042894192382784"  type="system"  page="0"   x="0,1765625"  y="0,11335578002245"  w="0,74761904761905" h="0,23456790123457"  />
<item  pos="0,059678876358656"  type="bar"  page="0"   x="0,095238095238095"  y="0,11335578002245"  w="0" h="0,23456790123457"  />
<item  pos="0,076463560334528"  type="bar"  page="0"   x="0,20634920634921"  y="0,11335578002245"  w="0" h="0,23456790123457"  />
<item  pos="0,0932482443104"  type="bar"  page="0"   x="0,29365079365079"  y="0,11335578002245"  w="0" h="0,23456790123457"  />
<item  pos="0,11096541072938"  type="bar"  page="0"   x="0,37301587301587"  y="0,11335578002245"  w="0" h="0,23456790123457"  />
<item  pos="0,12868257714835"  type="bar"  page="0"   x="0,45555555555556"  y="0,11335578002245"  w="0" h="0,23456790123457"  />
<item  pos="0,14266981379491"  type="bar"  page="0"   x="0,56190476190476"  y="0,11335578002245"  w="0" h="0,23456790123457"  />
<item  pos="0,16038698021389"  type="bar"  page="0"   x="0,64603174603175"  y="0,11335578002245"  w="0" h="0,23456790123457"  />
<item  pos="0,17717166418976"  type="system"  page="0"   x="0,1484375"  y="0,4040404040404"  w="0,77777777777778" h="0,23905723905724"  />
<item  pos="0,19768627793805"  type="bar"  page="0"   x="0,11904761904762"  y="0,4040404040404"  w="0" h="0,23905723905724"  />
<item  pos="0,21447096191392"  type="bar"  page="0"   x="0,24761904761905"  y="0,4040404040404"  w="0" h="0,23905723905724"  />
<item  pos="0,23125564588979"  type="bar"  page="0"   x="0,38888888888889"  y="0,4040404040404"  w="0" h="0,23905723905724"  />
<item  pos="0,24710784742256"  type="bar"  page="0"   x="0,51904761904762"  y="0,4040404040404"  w="0" h="0,23905723905724"  />
<item  pos="0,26762246117085"  type="bar"  page="0"   x="0,65873015873016"  y="0,4040404040404"  w="0" h="0,23905723905724"  />
<item  pos="0,28254218026051"  type="system"  page="0"   x="0,1484375"  y="0,69135802469136"  w="0,77619047619048" h="0,25813692480359"  />
<item  pos="0,29932686423638"  type="bar"  page="0"   x="0,11904761904762"  y="0,69135802469136"  w="0" h="0,25813692480359"  />
<item  pos="0,31611154821226"  type="bar"  page="0"   x="0,21746031746032"  y="0,69135802469136"  w="0" h="0,25813692480359"  />
<item  pos="0,33382871463123"  type="bar"  page="0"   x="0,31904761904762"  y="0,69135802469136"  w="0" h="0,25813692480359"  />
<item  pos="0,35154588105021"  type="bar"  page="0"   x="0,41746031746032"  y="0,69135802469136"  w="0" h="0,25813692480359"  />
<item  pos="0,37019552991229"  type="bar"  page="0"   x="0,5047619047619"  y="0,69135802469136"  w="0" h="0,25813692480359"  />
<item  pos="0,38511524900195"  type="bar"  page="0"   x="0,6031746031746"  y="0,69135802469136"  w="0" h="0,25813692480359"  />
<item  pos="0,40096745053472"  type="bar"  page="0"   x="0,6952380952381"  y="0,69135802469136"  w="0" h="0,25813692480359"  />
<item  pos="0,42148206428301"  type="system"  page="1"   x="0,146875"  y="0,088664421997755"  w="0,77619047619048" h="0,25476992143659"  />
<item  pos="0,4419966780313"  type="bar"  page="1"   x="0,077777777777778"  y="0,088664421997755"  w="0" h="0,25476992143659"  />
<item  pos="0,45971384445027"  type="bar"  page="1"   x="0,17619047619048"  y="0,088664421997755"  w="0" h="0,25476992143659"  />
<item  pos="0,47743101086925"  type="bar"  page="1"   x="0,28888888888889"  y="0,088664421997755"  w="0" h="0,25476992143659"  />
<item  pos="0,49235072995891"  type="bar"  page="1"   x="0,3968253968254"  y="0,088664421997755"  w="0" h="0,25476992143659"  />
<item  pos="0,51100037882099"  type="bar"  page="1"   x="0,5047619047619"  y="0,088664421997755"  w="0" h="0,25476992143659"  />
<item  pos="0,53058251012618"  type="bar"  page="1"   x="0,59206349206349"  y="0,088664421997755"  w="0" h="0,25476992143659"  />
<item  pos="0,54923215898826"  type="bar"  page="1"   x="0,69365079365079"  y="0,088664421997755"  w="0" h="0,25476992143659"  />
<item  pos="0,56601684296413"  type="system"  page="1"   x="0,1484375"  y="0,39393939393939"  w="0,77460317460317" h="0,24915824915825"  />
<item  pos="0,58559897426931"  type="bar"  page="1"   x="0,085714285714286"  y="0,39393939393939"  w="0" h="0,24915824915825"  />
<item  pos="0,60584540825247"  type="bar"  page="1"   x="0,15396825396825"  y="0,39393939393939"  w="0" h="0,24915824915825"  />
<item  pos="0,62449505711455"  type="bar"  page="1"   x="0,20952380952381"  y="0,39393939393939"  w="0" h="0,24915824915825"  />
<item  pos="0,64034725864732"  type="bar"  page="1"   x="0,29047619047619"  y="0,39393939393939"  w="0" h="0,24915824915825"  />
<item  pos="0,6589969075094"  type="bar"  page="1"   x="0,38095238095238"  y="0,39393939393939"  w="0" h="0,24915824915825"  />
<item  pos="0,67671407392837"  type="bar"  page="1"   x="0,46190476190476"  y="0,39393939393939"  w="0" h="0,24915824915825"  />
<item  pos="0,69536372279045"  type="bar"  page="1"   x="0,53968253968254"  y="0,39393939393939"  w="0" h="0,24915824915825"  />
<item  pos="0,71401337165253"  type="bar"  page="1"   x="0,61746031746032"  y="0,39393939393939"  w="0" h="0,24915824915825"  />
<item  pos="0,73266302051461"  type="bar"  page="1"   x="0,7031746031746"  y="0,39393939393939"  w="0" h="0,24915824915825"  />
<item  pos="0,7506012417315"  type="system"  page="1"   x="0,146875"  y="0,68799102132435"  w="0,76666666666667" h="0,25813692480359"  />
<item  pos="0,76365599593496"  type="bar"  page="1"   x="0,033333333333333"  y="0,68799102132435"  w="0" h="0,25813692480359"  />
<item  pos="0,79163046922808"  type="bar"  page="1"   x="0,16190476190476"  y="0,68799102132435"  w="0" h="0,25813692480359"  />
<item  pos="0,80934763564706"  type="bar"  page="1"   x="0,23492063492063"  y="0,68799102132435"  w="0" h="0,25813692480359"  />
<item  pos="0,83079473183845"  type="bar"  page="1"   x="0,31587301587302"  y="0,68799102132435"  w="0" h="0,25813692480359"  />
<item  pos="0,85037686314363"  type="bar"  page="1"   x="0,39365079365079"  y="0,68799102132435"  w="0" h="0,25813692480359"  />
<item  pos="0,87182395933502"  type="bar"  page="1"   x="0,47936507936508"  y="0,68799102132435"  w="0" h="0,25813692480359"  />
<item  pos="0,89513602041262"  type="bar"  page="1"   x="0,55555555555556"  y="0,68799102132435"  w="0" h="0,25813692480359"  />
<item  pos="0,90632580972987"  type="bar"  page="1"   x="0,58571428571429"  y="0,68799102132435"  w="0" h="0,25813692480359"  />
<item  pos="0,92404297614885"  type="bar"  page="1"   x="0,63492063492063"  y="0,68799102132435"  w="0" h="0,25813692480359"  />
</grid>		
		';
	}	
	private function testGridSystems():GridSystems
	{
		var gridSystems:GridSystems = { systems: new Array<GridSystem>()};
		var gridSystem:GridSystem = { pos: 0.1, pageNr: 0, x: 0.2, y: 0.2, width: 0.7, height: 0.3, bars: [] };
		gridSystems.systems.push(gridSystem);
		var gridBar:GridBar = { pos: 0.2, x: 0.35 };
		gridSystem.bars.push(gridBar);
		var gridBar:GridBar = { pos: 0.3, x: 0.5 };
		gridSystem.bars.push(gridBar);
		
		var gridSystem:GridSystem = { pos: 0.5, pageNr: 0, x: 0.2, y: 0.6, width: 0.6, height: 0.3, bars: [] };
		gridSystems.systems.push(gridSystem);
		/*
		var gridBar:GridBar = { pos: 0.6, x: 0.3 };
		gridSystem.bars.push(gridBar);
		var gridBar:GridBar = { pos: 0.65, x: 0.4 };
		gridSystem.bars.push(gridBar);
		var gridBar:GridBar = { pos: 0.7, x: 0.5 };
		gridSystem.bars.push(gridBar);
		*/
		
		var gridSystem:GridSystem = { pos: 0.8, pageNr: 1, x: 0.2, y: 0.3, width: 0.7, height: 0.4, bars: [] };
		gridSystems.systems.push(gridSystem);
		var gridBar:GridBar = { pos: 0.9, x: 0.6 };
		gridSystem.bars.push(gridBar);		
		
		return gridSystems;
	}	
	
}