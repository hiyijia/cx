package nx3.units;
#if nme
import nme.geom.Rectangle;
#else
import flash.geom.Rectangle;
#end

/**
 * ...
 * @author 
 */
class NRect
{
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;	
	
	public var bottom(get, set):Float;
	public var top(get, set):Float;	
	public var left(get, set):Float;
	public var right(get, set):Float;	
	
	public function new(?inX:Float=0, ?inY:Float=0, ?inWidth:Float=0, ?inHeight:Float=0):Void 
	{
		x = inX; // == null ? 0 : inX;
		y = inY; // == null ? 0 : inY;
		width = inWidth; // == null ? 0 : inWidth;
		height = inHeight ; //== null ? 0 : inHeight;
	}
	
	public function clone():NRect 
	{
		return new NRect(x, y, width, height);
	}	
	
	public function contains(inX:Float, inY:Float):Bool 
	{
		return inX >= x && inY >= y && inX < right && inY < bottom;
	}	

	public function equals(toCompare:NRect):Bool 
	{
		return x == toCompare.x && y == toCompare.y && width == toCompare.width && height == toCompare.height;
	}   

	public function inflate(dx:Float, dy:Float):Void 
	{
		x -= dx; width += dx * 2;
		y -= dy; height += dy * 2;
	}

	public function intersection(toIntersect:NRect):NRect 
	{
		var x0 = x < toIntersect.x ? toIntersect.x : x;
		var x1 = right > toIntersect.right ? toIntersect.right : right;
		if (x1 <= x0) return new NRect();

		var y0 = y < toIntersect.y ? toIntersect.y : y;
		var y1 = bottom > toIntersect.bottom ? toIntersect.bottom : bottom;
		if (y1 <= y0) return new NRect();

		return new NRect(x0, y0, x1 - x0, y1 - y0);
	}

	public function intersects(toIntersect:NRect):Bool 
	{
		var x0 = x < toIntersect.x ? toIntersect.x : x;
		var x1 = right > toIntersect.right ? toIntersect.right : right;
		if (x1 <= x0) return false;

		var y0 = y < toIntersect.y ? toIntersect.y : y;
		var y1 = bottom > toIntersect.bottom ? toIntersect.bottom : bottom;
		return y1 > y0;
	}   

	public function offset(dx:Float, dy:Float):Void 
	{
		x += dx;
		y += dy;
	}

	public function union(toUnion:NRect):NRect 
	{
		var x0 = x > toUnion.x ? toUnion.x : x;
		var x1 = right < toUnion.right ? toUnion.right : right;
		var y0 = y > toUnion.y ? toUnion.y : y;
		var y1 = bottom < toUnion.bottom ? toUnion.bottom : bottom;
		return new NRect(x0, y0, x1 - x0, y1 - y0);
	}   
	
	
	// Getters & Setters
	private function get_bottom() { return y + height; }
	private function set_bottom(b:Float) { height = b - y; return b; }
	//private function get_bottomRight() { return new Point(x + width, y + height); }
	//private function set_bottomRight(p:Point) { width = p.x - x;   height = p.y - y; return p.clone(); }
	private function get_left() { return x; }
	private function set_left(l:Float) { width -= l - x; x = l; return l; }
	private function get_right() { return x + width; }
	private function set_right(r:Float) { width = r - x; return r; }
	//private function get_size() { return new Point(width, height); }
	//private function set_size(p:Point) { width = p.x; height = p.y; return p.clone(); }
	private function get_top() { return y; }
	private function set_top(t:Float) { height -= t - y; y = t; return t; }
	//private function get_topLeft() { return new Point(x, y); }
	//private function set_topLeft(p:Point) { x = p.x; y = p.y; return p.clone(); }	
	
	public function toRectangle():Rectangle
	{
		return new Rectangle(this.x, this.y, this.width, this.height);
	}
}