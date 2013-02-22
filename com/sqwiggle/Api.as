﻿package com.sqwiggle {    import flash.events.*;    import flash.net.*;	import com.sqwiggle.ApiDelegate;    public class Api {  		private static var base:String; 		private static var auth_token:String;				public static function setup(base:String, auth_token:String) {			Api.base = base;			Api.auth_token = auth_token;		}		        private static function request(method:String, path:String, options:Object = null) {						if (!options) options = new Object();						options['auth_token'] = Api.auth_token;						var delegate = new ApiDelegate(method, Api.base + path, options);			return delegate;        }				public static function getRequest(path:String, options:Object = null) {			return Api.request("GET", path, options);		}				public static function postRequest(path:String, options:Object = null) {			return Api.request("POST", path, options);		}				public static function putRequest(path:String, options:Object = null) {			return Api.request("PUT", path, options);		}				public static function deleteRequest(path:String, options:Object = null) {			return Api.request("DELETE", path, options);		}    }}