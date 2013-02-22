﻿package com.sqwiggle {	import flash.display.LoaderInfo;	import flash.display.Sprite;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.external.ExternalInterface;	import flash.net.NetConnection;	import flash.net.URLRequestMethod;	import flash.events.MouseEvent;	import flash.media.Video;	import flash.events.Event;	import flash.utils.Dictionary;	import com.sqwiggle.Member;	import com.sqwiggle.Conversation;	import com.sqwiggle.VideoPanel;	import com.sqwiggle.Api;	import com.pusher.Pusher;	import com.pusher.auth.PostAuthorizer;	public class Sqwiggle extends Sprite {				var parameters 			:Object;		var self      			:Self;		var conversation		:Conversation;		var panel				:VideoPanel;		var pusher				:Pusher;		var api					:Api;						public function Sqwiggle() {			parameters = LoaderInfo(this.root.loaderInfo).parameters;			stage.align = StageAlign.TOP;			stage.scaleMode = StageScaleMode.NO_SCALE;						Api.setup('http://localhost:3000/api/v1', parameters.authToken);						// setup socket connection			pusherConnect();						// create video panel			self = new Self(parameters.userId);			panel = new VideoPanel(self);			// render			addChild(panel);						// shuffle the video feeds as the video panel is resized			stage.addEventListener(Event.RESIZE, panel.relayout);		}						private function pusherConnect():void {			// create pusher client authorization			Pusher.authorizer = new PostAuthorizer();						// TODO: change localhost here depending on environment			pusher = new Pusher('fd4dd9eb82163e6920a0', 'http://localhost');						// subscribe to the correct channel and bind the events we care about			pusher.subscribeAsPresence(parameters.companyId);			pusher.bind('pusher_internal:subscription_succeeded', pusherJoinedRoom);			pusher.bind('pusher_internal:member_added', pusherMemberJoined);			pusher.bind('pusher_internal:member_removed', pusherMemberLeft);						// connect to socket			pusher.connect();		}						/*		 * pusherJoinedRoom		 *		 * When joining a chat for the first time this method is called		 * to connect all of the existing participants in the video call.		*/		private function pusherJoinedRoom(event):void {			trace('pusherJoinedRoom', JSON.stringify(event));						var presence = event.presence;						for(var i in presence.hash) {				var member = presence.hash[i];				addMember(i, member.peer_id, member.name);			}		}						private function pusherMemberJoined(event):void {			trace('pusherMemberJoined', JSON.stringify(event));						addMember(event.user_id, event.user_info.peer_id, event.user_info.name);		}						/*		 * pusherMemberLeft		 *		 * When an existing user leaves the room or is otherwise disconnected		 * from the video feed.		*/		private function pusherMemberLeft(event):void {			trace('pusherMemberLeft', JSON.stringify(event));						panel.removeMember(event.user_id);		}						/*		 * addMember		 *		 * When a new user joins the chat this method is called to connect		 * them to the stream		*/		public function addMember(memberId:String, peerId:String, userName:String):void {			trace('addMember', memberId, peerId);						// prevent multiple connections if the user opens another tab			if (self.userId === memberId) return;						// create a new member			var member:Member = new Member(memberId, peerId, userName);			member.addEventListener(MouseEvent.CLICK, toggleInConversation);						// add to the video panel			panel.addMember(member);		}						/*		 * addConversationMembers		 *		 * Whenever the participants in an audio conversation changes this method		 * is triggered with the new peers. This is currently instead of doing add and		 * remove so we don't need to store the conversationalists on the server.		 * TODO: store them on the server.		*/		public function addConversationMembers(conversationId:String, strIds:String):void {			trace('addConversationMembers', strIds);						var userIds:Array = strIds.split(',');			var members:Dictionary = panel.getMembers();						if (!conversation) {				trace('joining existing conversation', conversationId);				conversation = new Conversation(conversationId);			}						if (conversation.id != conversationId) {				trace('already in another conversation');				return;			}						// check if we are in this conversation that we've received an update for.			var filter = userIds.filter(function(memberId){ return memberId == this.userId; }, self);			var inConversation = !!filter.length;						if (inConversation) {				trace('were in this convo');				conversation.addMember(self);			} else {				trace('were not in this convo');				conversation.removeMember(self);			}						// for all members in the video panel			memberLoop: for (var j in members) {				var member = members[j];								if (!inConversation) {					conversation.removeMember(member);					continue;				}								// for all the peers in the conversation				for (var i = 0; i < userIds.length; i++) {					// if this member should be in the conversation					if (member.userId == userIds[i]) {						conversation.addMember(member);						continue memberLoop;					}				}								trace('not in conversation ' + member.userId);				// no longer in conversation				conversation.removeMember(member);			}												// last person has been removed			if (conversation.isEmpty()) {				conversation.removeMember(self);				conversation = null;			}		}						private function toggleInConversation(event:MouseEvent):void {			trace('toggleInConversation');			var member = event.target;						if (!conversation) {				trace('starting new conversation');				conversation = new Conversation();			}						// toggle			if (conversation.hasMember(member)) {				conversation.removeMember(member);			} else {				conversation.addMember(self);				conversation.addMember(member);			}						sendConversationUpdate();		}						private function sendConversationUpdate():void {			trace('sendConversationUpdate');						var userIds:Array = new Array();			var members:Dictionary = conversation.getMembers();						for (var i in members) {				userIds.push(members[i].userId);			}						ExternalInterface.call('sendConversationUpdate', conversation.id, userIds.join(','));		}	}}