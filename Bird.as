package  {
	import flash.display.MovieClip;
	
	public class Bird extends MovieClip {
		private var _x:int;
		private var _y:int;
		
		public var hRadius:Number = 20.6;
		public var wRadius:Number = 29.1;
		
		public function Bird(_x,_y) {		
			this.x = _x;
			this.y = _y;
		}

	}
	
}