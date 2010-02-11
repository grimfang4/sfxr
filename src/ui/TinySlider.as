package ui
{
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * TinySlider
	 * 
	 * Copyright 2009 Thomas Vian
	 *
	 * Licensed under the Apache License, Version 2.0 (the "License");
	 * you may not use this file except in compliance with the License.
	 * You may obtain a copy of the License at
	 *
	 * 	http://www.apache.org/licenses/LICENSE-2.0
	 *
	 * Unless required by applicable law or agreed to in writing, software
	 * distributed under the License is distributed on an "AS IS" BASIS,
	 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	 * See the License for the specific language governing permissions and
	 * limitations under the License.
	 * 
	 * @author Thomas Vian
	 */
	public class TinySlider extends Sprite 
	{
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		protected var _back:Shape;					// Background colour shape
		protected var _bar:Shape;					// Coloured bar to indicate value
		protected var _border:Shape;				// Border shape to cover the borders of the back and bar
		
		protected var _text:TextField;				// Label TextField positioned to the left of the slider (right aligned)
		
		protected var _rect:Rectangle;				// Bounds of the slider in the context of the stage
		protected var _textRect:Rectangle;			// Bounds of the label in the context of the stage
		
		protected var _formatLight:TextFormat;		// Format for colouring the undimmed text (black)
		protected var _formatDim:TextFormat;		// Format for colouring the dimmed text (gray)
		
		protected var _plusMinus:Boolean;			// If the slider ranges from -1 to 1, instead of 0 to 1
		protected var _value:Number;				// The current value of the slider
		
		protected var _onChange:Function;			// Callback function called when the value of the slider changes
		
		//--------------------------------------------------------------------------
		//	
		// Getters / Setters
		//
		//--------------------------------------------------------------------------
		
		/** Changes the text to gray if true, black if false */
		public function set dimLabel(v:Boolean):void {_text.setTextFormat(v? _formatDim : _formatLight);}
		
		/** The value of the slider */
		public function get value():Number {return _value;}
		public function set value(v:Number):void
		{
				 if (_plusMinus && v < -1.0) 	v = -1.0;
			else if (!_plusMinus && v < 0.0) 	v = 0.0;
			else if (v > 1.0) 					v = 1.0;
			
			if (v != _value)
			{
				_value = v;
				
				_bar.scaleX = _plusMinus ? (_value + 1.0) * 0.5 : _value;
				
				_onChange(this);
			}
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Creates the TinySlider, adding text and three shapes
		 * @param	onChange		Callback function called when the value of the slider changes
		 * @param	label			Label to display to the left of the slider
		 * @param	plusMinus		If the slider ranges from -1 to 1, instead of 0 to 1
		 */
		public function TinySlider(onChange:Function, label:String = "", plusMinus:Boolean = false)
		{
			_onChange = onChange;
			_plusMinus = plusMinus;
			_value = 0.0;
			
			mouseChildren = false;
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			_back = 	drawRect(0, 		0x807060);
			_bar = 		drawRect(0xFFFFFF, 	0xF0C090);
			_border = 	drawRect(0, 		0xFFFFFF, 0);
			
			_bar.scaleX = _plusMinus ? 0.5 : 0.0;
			
			if (plusMinus)
			{
				_border.graphics.moveTo(50, 0);
				_border.graphics.lineTo(50, -1);
				_border.graphics.moveTo(50, 9);
				_border.graphics.lineTo(50, 10);
			}
			
			if(label != "")
			{
				_text = new TextField();
				_text.defaultTextFormat = new TextFormat("Amiga4Ever", 8, null, null, null, null, null, null, TextFormatAlign.RIGHT);
				_text.antiAliasType = AntiAliasType.ADVANCED;
				_text.selectable = false;
				_text.embedFonts = true;
				_text.text = label;
				_text.width = 200;
				_text.height = 20;
				_text.x = -205;
				_text.y = -2.5;
				addChild(_text);
				
				_formatLight = new TextFormat(null, null, 0);
				_formatDim = new TextFormat(null, null, 0x808080);
			}
			
			addChild(_back);
			addChild(_bar);
			addChild(_border);
		}
		
		/**
		 * Once the slider is on the stage, the event listener can be set up and rectangles recorded
		 * @param	e	Added to stage event
		 */
		private function onAdded(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded)
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			_rect = _back.getBounds(stage);
			
			if (_text)  _textRect = _text.getBounds(stage);
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Mouse Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Starts listening for mouse move and updates the value, or resets the value if you click on the text
		 * @param	e	MouseEvent
		 */
		protected function onMouseDown(e:MouseEvent):void
		{
			if (_rect.contains(stage.mouseX, stage.mouseY))
			{
				updateValue();
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			else if (_textRect && _textRect.contains(stage.mouseX, stage.mouseY))
			{
				value = 0.0;
			}
		}
		
		/**
		 * Updates the value when the mouse moves
		 * @param	e	MouseEvent
		 */
		protected function onMouseMove(e:MouseEvent):void
		{
			updateValue();
			
			e.updateAfterEvent();
		}
		
		/**
		 * Stops listening for mouse move
		 * @param	e	MouseEvent
		 */
		protected function onMouseUp(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Util Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Returns a background shape with the specified colours and alpha
		 * @param	borderColour		Colour of the border
		 * @param	fillColour			Colour of the fill
		 * @param	fillAlpha			Alpha of the fill
		 * @return						The drawn rectangle Shape 
		 */
		private function drawRect(borderColour:uint, fillColour:uint, fillAlpha:Number = 1):Shape
		{
			var rect:Shape = new Shape();
			rect.graphics.lineStyle(1, borderColour, 1, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
			rect.graphics.beginFill(fillColour, fillAlpha);
			rect.graphics.drawRect(0, 0, 100, 9);
			rect.graphics.endFill();
			return rect;
		}
		
		/**
		 * Updates the value based on mouse position
		 */
		protected function updateValue():void
		{
			value = _plusMinus ? (mouseX / 100) * 2 - 1 : mouseX / 100;
		}
	}
}