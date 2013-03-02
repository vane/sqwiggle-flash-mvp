﻿package com.sqwiggle {	import flash.net.NetStream;	import flash.net.NetConnection;	import flash.events.NetStatusEvent;	import flash.events.Event;	import flash.events.TimerEvent;	import flash.external.ExternalInterface;	import flash.display.Sprite;	import flash.display.MovieClip;    import flash.filters.BitmapFilter;    import flash.filters.BitmapFilterQuality;    import flash.filters.DropShadowFilter;	import flash.utils.Timer;	import fl.transitions.Tween;	import fl.transitions.easing.*;		import com.sqwiggle.Member;	import com.sqwiggle.Self;	import com.sqwiggle.GUID;	public class VideoPanel extends Sprite {				public var connection:NetConnection;		public var self:Self;				public var members:Object;		private var length:Number;		private var connectionStatus:MovieClip;		private var hideTimer:Timer;						public function VideoPanel(self:Self) {			this.self = self;			this.members = new Object();						// show connection status text			connectionStatus = new ConnectionStatus();			connectionStatus.gotoAndStop('connecting');			addChild(connectionStatus);						// setup a new video connection for this panel and get connecting			connection = new NetConnection();			connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);			connection.connect('rtmfp://p2p.rtmfp.net', '56ec6665a4c675c72fb85db7-b6153286fa1e');						self.addEventListener("Connected", selfConnected);						drawDropShadow();		}						private function selfConnected(event:Event):void {			connectionStatus.gotoAndStop('connected');		}						private function drawDropShadow():void {            var color:Number = 0x000000;            var angle:Number = 0;            var alpha:Number = 0.75;            var blurX:Number = 10;            var blurY:Number = 10;            var distance:Number = 0;            var strength:Number = 0.65;            var inner:Boolean = false;            var knockout:Boolean = false;            var quality:Number = BitmapFilterQuality.MEDIUM;			            var filter = new DropShadowFilter(				distance,				angle,				color,				alpha,				blurX,				blurY,				strength,				quality,				inner,				knockout);						filters = [filter];		}						public function addMember(member:Member):void {						// dont connect ourselves here, this is done elsewhere			if (member.peerId == connection.nearID) {				Sqwiggle.trace('NOTICE: attempted to connect self');				return;			}						if (members[member.userId]) {				Sqwiggle.trace('NOTICE: peer already present');				return;			}						Sqwiggle.trace('VideoPanel:addMember', member.peerId);			members[member.userId] = member;			// connect video			member.connectToVideo(connection);						// add to stage			addChild(member);			length++;						relayout();		}						public function removeMember(memberId:String):void {			Sqwiggle.trace('VideoPanel:removeMember');			var member = members[memberId];						// handle if we're asked to remove a member that			// has already been removed or not yet connected			if (!member) return;						// disconnect video			member.disconnectFromVideo();					// remove from stage			removeChild(member);			length--;						delete members[memberId];						relayout();		}						public function hideVideos():void {						hideTimer = new Timer(1000, 3); // 3 seconds			hideTimer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent){								for (var i in members) {					members[i].hideVideo();				}   			});						hideTimer.start();		}						public function showVideos():void {						if (hideTimer) {				hideTimer.stop();			}						for (var i in members) {				members[i].showVideo();			}		}						public function getMembersCount():Number {			return length;		}						public function inConversation(member:Member):Boolean {						// convert to boolean			return !!members[member.userId];		}						public function relayout(event:Event=null, tween:Boolean=true):void {			Sqwiggle.trace('VideoPanel:relayout');						var centerX = stage.stageWidth / 2;			var centerY = stage.stageHeight / 2;			var memberHalfWidth = 0;			var memberHalfHeight = 0;			// relayout video feeds in grid for now, this is currently			// assuming that self is always in the top right corner.			var key = 1;						for (var i in members) {				var member = members[i];				var newX = (member.width  * (key % 3));				var newY = (member.height * (Math.ceil((key+1) / 3)-1));				memberHalfWidth = member.width/2;				memberHalfHeight = member.height/2;							if (false) { //tween					new Tween(member, "x", Back.easeOut, member.x, newX, 0.5, true);					new Tween(member, "y", Back.easeOut, member.y, newY, 0.5, true);				} else {					member.x = newX;					member.y = newY;				}								Sqwiggle.trace('positioning: ' + i + ' at ' + members[i].x + '|' + members[i].y);				key++;			}						var halfPanelWidth = this.width / 2;			var halfPanelHeight = this.height / 2;						this.x = Math.round(centerX-halfPanelWidth+memberHalfWidth);			this.y = Math.round(centerY-halfPanelHeight+memberHalfHeight);									// connection status			connectionStatus.x = halfPanelWidth - (connectionStatus.width/2);			connectionStatus.y = halfPanelHeight - (connectionStatus.height/2);						// change layout depending on how many clients are connected			// lower numbers have custom layouts to make the most of the space			/*			switch(members.length) {				case 1:				case 2:				case 3:				case 4:				default:			}			*/		}						private function onNetStatus(e:NetStatusEvent):void {			switch (e.info.code) {				case 'NetConnection.Connect.Success':										// set up our video stream					self.connectToVideo(connection);					// add video to stage					addChild(self);										relayout(null, false);				break;			}		}	}}