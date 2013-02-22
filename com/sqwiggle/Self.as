﻿package com.sqwiggle {	import flash.events.NetStatusEvent;	import flash.media.Camera;	import flash.net.NetConnection;	import flash.net.NetStream;	import flash.media.Microphone;	import flash.media.SoundCodec;	import flash.events.MouseEvent;	import flash.events.Event;	import com.sqwiggle.Member;	public class Self extends Member {		var cam:Camera;		var mic:Microphone;				public function Self(userId:String) {			super(userId, '', 'Me');			            // TODO: check for camera			cam = Camera.getCamera();			cam.setQuality(0, 100);			            // TODO: check for mic			mic = Microphone.getMicrophone();			mic.enableVAD = true;			mic.codec = SoundCodec.SPEEX;			mic.encodeQuality = 10;			mic.setSilenceLevel(100);		}						public function updatePeerId():void {									var options = new Object();			options.peer_id = peerId;						var request = Api.putRequest('/users/update', options);			request.addEventListener(Event.COMPLETE, function(event:Event) {				trace('complete');  				trace(event.target.data);			});		}						public override function connectToVideo(connection:NetConnection):void {			peerId = connection.nearID;						trace('Publishing video to: ' + userId + ', stream: ' + peerId);						var stream = new NetStream(connection, NetStream.DIRECT_CONNECTIONS);			stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);			stream.attachCamera(this.cam);			stream.attachAudio(this.mic);			stream.publish(this.userId);						var client:Object = new Object();						client.onPeerConnect = function(caller:NetStream):Boolean {				trace('Member connecting to your video stream: ' + caller.farID);				return true;			};						stream.client = client;			video.attachCamera(this.cam);			video.smoothing = true;			video.deblocking = 5;						// ensure we update this users peerID on the server for 			// other clients to connect to.			updatePeerId();		}				public override function audioOn():void {			mic.setSilenceLevel(0);						trace('Your audio is on');		}				public override function audioOff():void {			mic.setSilenceLevel(100);						trace('Your audio is off');		}	}}