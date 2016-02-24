package feathers.examples.componentsExplorer.screens
{
	import feathers.controls.List;
	import feathers.controls.PanelScreen;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.system.DeviceCapabilities;

	import flash.system.Capabilities;

	import starling.core.Starling;
	import starling.events.Event;
	import starling.textures.Texture;

	[Event(name="complete",type="starling.events.Event")]
	[Event(name="showMapControls",type="starling.events.Event")]
	[Event(name="showLevelControls",type="starling.events.Event")]
	

	public class MainMenuScreen extends PanelScreen
	{
		public static const SHOW_MAP_CONTROLS:String = "showMapControls";
		public static const SHOW_LEVEL_CONTROLS:String = "showLevelControls";
		
		
		public function MainMenuScreen()
		{
			super();
		}

		private var _list:List;

		public var savedVerticalScrollPosition:Number = 0;
		public var savedSelectedIndex:int = -1;

		override protected function initialize():void
		{
			//never forget to call super.initialize()
			super.initialize();

			this.title = "Feathers";

			this.layout = new AnchorLayout();

			this._list = new List();
			this._list.dataProvider = new ListCollection(
			[
				{ label: "Map", event: SHOW_MAP_CONTROLS },
				{ label: "Level", event: SHOW_LEVEL_CONTROLS }
			]);
			if(Capabilities.playerType == "Desktop") //this means AIR, even for mobile
			{
				this._list.dataProvider.addItem( { label: "Web View", event: SHOW_WEB_VIEW } );
			}
			this._list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			this._list.clipContent = false;
			this._list.autoHideBackground = true;
			this._list.verticalScrollPosition = this.savedVerticalScrollPosition;

			this._list.itemRendererFactory = this.createItemRenderer;

			var isTablet:Boolean = DeviceCapabilities.isTablet(Starling.current.nativeStage);
			if(isTablet)
			{
				this._list.addEventListener(Event.CHANGE, list_changeHandler);
				this._list.selectedIndex = 0;
				this._list.revealScrollBars();
			}
			else
			{
				this._list.selectedIndex = this.savedSelectedIndex;
				this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
			}
			this.addChild(this._list);
		}
		
		private function createItemRenderer():IListItemRenderer
		{
			var isTablet:Boolean = DeviceCapabilities.isTablet(Starling.current.nativeStage);
			
			var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
			if(!isTablet)
			{
				renderer.styleNameList.add(DefaultListItemRenderer.ALTERNATE_STYLE_NAME_DRILL_DOWN);
			}

			//enable the quick hit area to optimize hit tests when an item
			//is only selectable and doesn't have interactive children.
			renderer.isQuickHitAreaEnabled = true;

			renderer.labelField = "label";
			return renderer;
		}
		
		private function transitionInCompleteHandler(event:Event):void
		{
			if(!DeviceCapabilities.isTablet(Starling.current.nativeStage))
			{
				this._list.selectedIndex = -1;
				this._list.addEventListener(Event.CHANGE, list_changeHandler);
			}
			this._list.revealScrollBars();
		}
		
		private function list_changeHandler(event:Event):void
		{
			var eventType:String = this._list.selectedItem.event as String;
			if(DeviceCapabilities.isTablet(Starling.current.nativeStage))
			{
				this.dispatchEventWith(eventType);
				return;
			}

			//save the list's scroll position and selected index so that we
			//can restore some context when this screen when we return to it
			//again later.
			this.dispatchEventWith(eventType, false,
			{
				savedVerticalScrollPosition: this._list.verticalScrollPosition,
				savedSelectedIndex: this._list.selectedIndex
			});
		}
	}
}