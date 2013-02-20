﻿package sqwiggle {	import flash.events.NetStatusEvent;	import flash.media.Camera;	import flash.net.NetConnection;	import flash.net.NetStream;	import sqwiggle.Member;	import flash.media.Microphone;	import flash.events.MouseEvent;	import fl.motion.MotionEvent;		public class Self extends Member {		var cam:Camera;				public function Self(userId:String, peerId:String) {			super(userId, peerId);						cam = Camera.getCamera();			cam.setQuality(0, 100);		}				public override function connectToAudio(audioConnection:NetConnection, peerId:String):void {						var stream = new NetStream(audioConnection, NetStream.DIRECT_CONNECTIONS);			stream.addEventListener(NetStatusEvent.NET_STATUS, onAudioStatus);			stream.attachAudio(Microphone.getMicrophone());			stream.publish('audio-' + this.userId);		}				public function onAudioStatus(e:NetStatusEvent):void {			// nothing here just yet		}				public override function connectToVideo(videoConnection:NetConnection):void {			//trace('Publishing to id ' + id + ', stream: ' + peerId);						var stream = new NetStream(videoConnection, NetStream.DIRECT_CONNECTIONS);			stream.addEventListener(NetStatusEvent.NET_STATUS, onVideoStatus);			stream.attachCamera(this.cam);			stream.publish(this.userId);						var client:Object = new Object();						client.onPeerConnect = function(caller:NetStream):Boolean {				trace('Callee connecting to stream: ' + caller.farID);				return true;			};						stream.client = client;			video.attachCamera(this.cam);			video.smoothing = true;			video.deblocking = 5;		}	}}