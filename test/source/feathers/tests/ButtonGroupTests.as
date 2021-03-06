package feathers.tests
{
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.data.ListCollection;

	import flash.geom.Point;

	import org.flexunit.Assert;

	import starling.display.DisplayObject;

	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class ButtonGroupTests
	{
		private var _group:ButtonGroup;

		[Before]
		public function prepare():void
		{
			this._group = new ButtonGroup();
			this._group.dataProvider = new ListCollection(
			[
				{ label: "One" },
				{ label: "Two" },
				{ label: "Three" },
			]);
			this._group.buttonFactory = function():Button
			{
				var button:Button = new Button();
				button.defaultSkin = new Quad(200, 200);
				return button;
			}
			this._group.direction = ButtonGroup.DIRECTION_VERTICAL;
			TestFeathers.starlingRoot.addChild(this._group);
			this._group.validate();
		}

		[After]
		public function cleanup():void
		{
			this._group.removeFromParent(true);
			this._group = null;

			Assert.assertStrictlyEquals("Child not removed from Starling root on cleanup.", 0, TestFeathers.starlingRoot.numChildren);
		}

		[Test]
		public function testTriggeredEvent():void
		{
			var triggeredItem:Object;
			var hasTriggered:Boolean = false;
			this._group.addEventListener(Event.TRIGGERED, function(event:Event):void
			{
				hasTriggered = true;
				triggeredItem = event.data;
			});
			var position:Point = new Point(10, 210);
			var target:DisplayObject = this._group.stage.hitTest(position, true);
			var touch:Touch = new Touch(0);
			touch.target = target;
			touch.phase = TouchPhase.BEGAN;
			touch.globalX = position.x;
			touch.globalY = position.y;
			var touches:Vector.<Touch> = new <Touch>[touch];
			target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH, touches));
			//this touch does not move at all, so it should result in triggering
			//the button.
			touch.phase = TouchPhase.ENDED;
			target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH, touches));
			Assert.assertTrue("Event.TRIGGERED was not dispatched", hasTriggered);
			Assert.assertStrictlyEquals("Event.TRIGGERED was not dispatched with correct data", this._group.dataProvider.getItemAt(1), triggeredItem);
		}
	}
}
