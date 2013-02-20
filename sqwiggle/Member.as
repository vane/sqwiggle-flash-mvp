﻿package sqwiggle {	import flash.display.Sprite;	import flash.events.NetStatusEvent;	import flash.media.Video;	import flash.net.NetConnection;	import flash.net.NetStream;	import flash.display.Shape;	import flash.display.MovieClip;	import flash.events.MouseEvent;	import flash.utils.Timer;		public class Member extends Sprite {		public var connection	:NetConnection;		public var userId		:String;		public var peerId    	:String;		var stream:NetStream;		var video :Video;				var bar:MovieClip;		var t:MovieClip;				public function Member(userId:String, peerId:String) {			this.userId = userId;			this.peerId = peerId;			video = new Video();			video.width  = 291;			video.height = 218;			addChild(video);			bar = new statusBar();			bar.y = video.height;			bar.visible=false;			addChild(bar);						t = new talk();			t.x = 4;			t.buttonMode=true;			t.useHandCursor=true;			t.y = video.height - 4;			t.visible=false;			addChild(t);			addEventListener(MouseEvent.MOUSE_OVER, mover);			addEventListener(MouseEvent.MOUSE_OUT, mout);		}				public function connectToVideo(connection:NetConnection):void {			trace('Connecting to video of: ' + userId + ', stream: ' + peerId);						stream = new NetStream(connection, peerId);			stream.addEventListener(NetStatusEvent.NET_STATUS, onVideoStatus);			stream.play(this.userId);			stream.receiveAudio(false);						video.attachNetStream(stream);		}				public function disconnectFromVideo():void {			removeChild(video);			stream.close();		}				public function audioOn():void {			t.gotoAndStop(2);			stream.receiveAudio(true);		}				public function audioOff():void {			t.gotoAndStop(1);			stream.receiveAudio(false);		}				public  function onVideoStatus(e:NetStatusEvent):void {			trace('Video status ' + peerId + ': ' + e.info.code);		}				function mover(e:*):void {			bar.visible = true;			t.visible = true;		}				function mout(e:*):void {			bar.visible = false;			t.visible = false;		}	}}