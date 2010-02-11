package ui
{
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * TinyButton
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
	public class TinyButton extends Sprite
	{
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		protected var _backOff:Shape;					// Button graphic when unselected
		protected var _backDown:Shape;					// Button graphic when being clicked
		protected var _backSelected:Shape;				// Button graphic when selected		
		
		protected var _formatOff:TextFormat;			// TextFormat when unselected (used for colouring)
		protected var _formatDown:TextFormat;           // TextFormat when being clicked (used for colouring)
		protected var _formatSelected:TextFormat;       // TextFormat when selected (used for colouring)
		
		protected var _text:TextField;					// Label TextField (left aligned)
		
		protected var _rect:Rectangle;					// Bounds of the button in the context of the stage
		
		protected var _selected:Boolean;				// If the button is selected (only used for wave selection)
		protected var _selectable:Boolean;				// If the button is selectable (only used for wave selection)
		
		protected var _enabled:Boolean;					// If the button is currently clickable
		
		protected var _onClick:Function;				// Callback function for when the button is clicked
		
		//--------------------------------------------------------------------------
		//	
		// Getters / Setters
		//
		//--------------------------------------------------------------------------
		
		/** Sets the text on the button */
		public function set label(v:String):void {_text.text = v;}
		
		/** Selects/unselects the button */
		public function get selected():Boolean {return _selected;}
		public function set selected(v:Boolean):void
		{
			_selected = v;
			
			removeChildAt(0);
			
			if(_selected)
			{
				addChildAt(_backSelected, 0);
				setFormat(_formatSelected);
			}
			else
			{
				addChildAt(_backOff, 0);
				setFormat(_formatOff);
			}
		}
		
		/** Enables/disables the button */
		public function set enabled(value:Boolean):void
		{
			if(value) 	alpha = 1.0;
			else		alpha = 0.3;
			
			_enabled = value;
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Creates the TinyButton, adding text and a background shape. 
		 * Defaults to the off state.
		 * @param	onClick			Callback function called when the button is clicked
		 * @param	label			Text to display on the button (left aligned)
		 * @param	border			Thickness of the border in pixels
		 * @param	selectable		If the button should be selectable
		 */
		public function TinyButton(onClick:Function, label:String, border:Number = 2, selectable:Boolean = false):void 
		{
			_onClick = onClick;
			
			_selectable = selectable;
			_selected = false;
			_enabled = true;
			
			_backOff = drawRect(border, 0, 0xA09088);
			_backDown = drawRect(border, 0xA09088, 0xFFF0E0);
			_backSelected = drawRect(border, 0, 0x988070);
			
			_formatOff = new TextFormat("Amiga4Ever", 8, 0);
			_formatDown = new TextFormat("Amiga4Ever", 8, 0xA09088);
			_formatSelected = new TextFormat("Amiga4Ever", 8, 0xFFF0E0);
			
			_text = new TextField();
			_text.defaultTextFormat = _formatOff;
			_text.mouseEnabled = false;
			_text.selectable = false;
			_text.embedFonts = true;
			_text.text = label;
			_text.width = 104;
			_text.height = 16;
			_text.x = _text.y = 2;
			
			addChild(_backOff);
			addChild(_text);
			
			mouseChildren = false;
			blendMode = BlendMode.LAYER;
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded)
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			_rect = getBounds(stage);
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Mouse Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Sets the button to the down state
		 * @param	e	MouseEvent
		 */
		private function onMouseDown(e:MouseEvent):void 
		{
			if (_enabled && _rect.contains(stage.mouseX, stage.mouseY))
			{
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				
				removeChildAt(0);
				
				addChildAt(_backDown, 0);
				setFormat(_formatDown);
			}
		}
		
		/**
		 * Sets the button to the off state if not selectable, switches state between off and selected if it is. 
		 * Calls the onClick callback
		 * @param	e	MouseEvent
		 */
		private function onMouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			removeChildAt(0);
			
			if(_selectable && (_selected = !_selected))
			{
				addChildAt(_backSelected, 0);
				setFormat(_formatSelected);
			}
			else
			{
				addChildAt(_backOff, 0);
				setFormat(_formatOff);
			}
			
			_onClick(this);
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Util Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Returns a background shape with the specified colours and border
		 * @param	border				Thickness of the border in pixels
		 * @param	borderColour		Colour of the border
		 * @param	fillColour			Colour of the fill
		 * @return						The drawn rectangle Shape 
		 */
		private function drawRect(border:uint, borderColour:uint, fillColour:uint):Shape
		{
			var rect:Shape = new Shape();
			rect.graphics.lineStyle(border, borderColour, 1, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
			rect.graphics.beginFill(fillColour, 1);
			rect.graphics.drawRect(0, 0, 104, 18);
			rect.graphics.endFill();
			return rect;
		}
		
		/**
		 * Sets both the current and default text format 
		 * @param	format	TextFormat to apply to the text
		 */
		private function setFormat(format:TextFormat):void
		{
			_text.defaultTextFormat = format;
			_text.setTextFormat(format);
		}
	}
}