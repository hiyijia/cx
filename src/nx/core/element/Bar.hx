package nx.core.element;
import nx.core.element.Part;

/**
 * ...
 * @author Jonas Nyström
 */

class Bar 
{
	public var parts(default, null):Array<Part>;

	public function new(parts:Iterable<Part>=null) {
		this.parts = (parts != null) ? Lambda.array(parts) : [new Part()];
	}
	
	/*************************************************************
	 * XML functions
	 */
	
	static public var XBAR 					= 'bar';
	//static public var XDIRECTION		= 'direction';
	
	public function toXml():Xml {		
		var xml:Xml = Xml.createElement(XBAR);				
		
		for (item in this.parts) {
			var itemXml = item.toXml();
			xml.addChild(itemXml);
		}
		
		//if (this.direction != EDirectionUAD.Auto) 		xml.set(XDIRECTION, 		Std.string(this.direction));
		
		return xml;
	}
	
	static public function fromXmlStr(xmlStr:String):Bar {	
		
		var xml = Xml.parse(xmlStr).firstElement();
		var items:Array<Part> = [];
		for (itemXml in xml.elementsNamed(Part.XPART)) {
			var item = Part.fromXmlStr(itemXml.toString());
			items.push(item);
		}	
		
		//var direction = EDirectionUAD.createFromString(xml.get(XDIRECTION));
		
		return new Bar(items);
		
	}
	
	
}