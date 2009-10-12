/*
 * Unshiu Mixi Application JavaScript Library 
 * http://drecom.co.jp/
 *
 * Copyright (c) 2009 Drecom
 *
 */
;(function($) {
  Deferred.define();

	var name_space = 'drecom_mixi_gadget';
	$.fn[name_space] = function(config){
		// 引数 デフォルト値
		config = jQuery.extend({
				session_id: "",
				session_key: "",
				base_url: "",
				app_url: "",
				owner_only: false,
				app_name: "",
				iframe_width: "400px",
				iframe_height: "500px",
        show_load_seq: true,
        has_app_filter: true,
        debug_flag: false,
				view_name: gadgets.views.getCurrentView().getName()
			},config);
		
		gadgets.util.registerOnLoadHandler(gadgetInit);
		
		var klass = {
		};
		
		/**
		 *　各gadgetが読み込まれた際に一番最初に読まれる
		 */
		function gadgetInit() {
			switch(config.view_name) {
		  	case 'canvas':
		    	canvasInit();
		    	break;
		  	case 'home':
		  	case 'profile':
		    	profileInit();
		    	break;
		  	case 'preview':
		    	previewInit();
		    	break;
		  		default:
		  }
		}
		
		/**
		 * canvasが表示された場合の処理
		 * 自分と友達の情報をアプリケーションサーバへ登録するリクエストを投げる
		 */
		function canvasInit() {
      var drecom_mixiapp_friend_ids = [];
		  var req = opensocial.newDataRequest();

		  var idspec_owner = opensocial.IdSpec.PersonId.OWNER;
			var idspec_viewer = opensocial.IdSpec.PersonId.VIEWER;

		  req.add(req.newFetchPersonRequest(idspec_owner), "owner");
			req.add(req.newFetchPersonRequest(idspec_viewer), "viewer");
		  req.send(function (res) {
			  if (res.hadError()) {
		      updateContainerError();
		    } else {
		      var params = {
		        "drecom_mixiapp_owner" : person_to_json(res.get("owner").getData()),
		        "drecom_mixiapp_viewer" : person_to_json(res.get("viewer").getData())
		      };
		
					if(config.owner_only) {
						if(res.get("owner").getData().getField(opensocial.Person.Field.ID) != res.get("viewer").getData().getField(opensocial.Person.Field.ID)) {
							window.open(config.app_url, '_parent');
							return false;
						}
					}
          klass.infollow_iframe();

          // Deferred
          klass.requestContainer('/mixi_gadget/register_person', params, gadgets.io.MethodType.POST, true)
          .next(function(data){
            // register 時には klass.setSession() が入っているので eval
            var ScriptFragment = '<script[^>]*>([\\S\\s]*?)<\/script>';
            var scripts = data.text.match(new RegExp(ScriptFragment, 'img'));
            if (scripts) {
              for (var i=0; i<scripts.length; i++) {
                var script = scripts[i].match(new RegExp(ScriptFragment, 'im'));
                if (script) runScript(script[1]);
              }
            }
          })
          .next(function(){
            return klass.getViewerFriends();
          })
          .next(function(data){
            if (config.show_load_seq) {
              $("#gadget_container_seq").fadeIn("slow");
            }
            loopSize = Math.ceil(data.getTotalSize() / 20);
            return loop(loopSize, function(index){
              return klass.getViewerFriends(index * 20)
              .next(function(data){
                data.each(function(e){
                  drecom_mixiapp_friend_ids.push(e.getId());
                });
                var params = {
                  "drecom_mixiapp_viewer" : person_to_json(res.get("viewer").getData()),
                  "drecom_mixiapp_friends" : people_to_json(data)
                };
                return klass.requestContainer('/mixi_gadget/register_friends', params, gadgets.io.MethodType.POST, true);
              })
              .next(function(){
                $("#gadget_container_seq").html('<div style="text-align:center;"><span id="load_sequence" style="font-size:40px;color:#aaaaaa;">' + parseInt((index + 1) / loopSize * 100) + '</span>％</div>');
              });
            });
          })
          .next(function(){
            var params = {
              "drecom_mixiapp_viewer" : person_to_json(res.get("viewer").getData()),
              "drecom_mixiapp_friend_ids" : gadgets.json.stringify(drecom_mixiapp_friend_ids)
            };
            return klass.requestContainer('/mixi_gadget/register_friendships', params, gadgets.io.MethodType.POST, true)
          })
          .next(function(){
            if (config.show_load_seq) {
              $("#gadget_container_seq").fadeOut("slow");
              $("#gadget_container_seq").html("");
            }
            klass.historyInit();
          })
          .error(function(e){
            updateContainerError(e);
          });
		    }
		  });
		}

		/**
		 * profileが表示された場合の処理
		 */
		function profileInit() {
		  var req = opensocial.newDataRequest();
		  req.add(req.newFetchPersonRequest(opensocial.IdSpec.PersonId.OWNER), "owner");
		  req.add(req.newFetchPersonRequest(opensocial.IdSpec.PersonId.VIEWER), "viewer");
		  req.send(function (res) {
		    if (res.hadError()) {
		      updateContainerError();
		    } else {
		      owner = res.get("owner").getData();
		      viewer = res.get("viewer").getData();
		      var params = {
		        "opensocial_owner_id" : owner.getField(opensocial.Person.Field.ID),
		        "opensocial_viewer_id" : viewer.getField(opensocial.Person.Field.ID)
		      };
		      requestContainer('/mixi_gadget/profile', params);
		    }
		  });
		}

		/**
		 * previewが表示された場合の処理
		 */
		function previewInit() {
		  requestContainer('/mixi_gadget/preview');
		}
		
		/**
		 *　session内容を再セットアップする
		 */
		klass.setSession = function(session_id, session_key) {
			config.session_id = session_id;
			config.session_key = session_key;
		}
		
		klass.requestNavigateTo = function (view, pagename) {
			var canvas_view = new gadgets.views.View(view);
			$.opensocial_simple.postViewerData({'drecom_mixiapp_history' : pagename}, function () { 
				//console.log(arguments) 
			});
			gadgets.views.requestNavigateTo(canvas_view, {'pagename' : pagename });
		}
		
		/**
		 * リクエスト内容をアプリケーションサーバへなげる
		 */
		klass.requestContainer = function (urlPath, urlParams, method, useDeferred) {
      if (typeof(useDeferred) == "undefined") {
        useDeferred = false;
      }
			$.opensocial_simple.getPerson(function (result) {
				if(urlParams == null) {
					urlParams = new Array
				} 
				
				if(typeof(urlParams) == "object" || urlParams instanceof Array) {
					urlParams['opensocial_viewer_id'] = result.VIEWER.getId();
					if (config.session_id) urlParams[config.session_key] = config.session_id;
				} else if(typeof(urlParams) == "string" || urlParams instanceof String) {
					if (urlParams.length > 0) {
						urlParams += encodeURI("&opensocial_viewer_id=" + result.VIEWER.getId());
					} else {
						urlParams += encodeURI("?opensocial_viewer_id=" + result.VIEWER.getId());
					}
					if (config.session_id) urlParams += encodeURI("&" + config.session_key + "=" + config.session_id);
				}
			});

      if (useDeferred) {
        var deferred = new Deferred();
        requestServer(urlPath, urlParams, function(data){
          // mixi 本番環境だと data.rc が取れないので data.text.length で仕方なく length でチェック。エラー時が取れない＞＜
          if (data && data.text && data.text.length > 0) {
            deferred.call(data);
          } else {
            errorMessage = "ERROR : klass.requestContainer : " + urlPath + " faild."
            if (data) { errorMessage += "(" + data.rc + ")"; }
            if (config.debug_flag) {
              deferred.fail(data.text);
            } else {
              deferred.fail(errorMessage);
            }
          }
        }, method);
        return deferred;
      } else {
        requestServer(urlPath, urlParams, function(obj) {
          if (obj && obj.text && obj.text.length>0) {
              updateContainer(obj.text);
          } else {
            updateContainerError();
          }
        }, method);
      }
		};
		
		/**
		 * JSによるリクエスト内容をアプリケーションサーバへなげる
		 */
		klass.requestScript = function (urlPath, urlParams, method) {
		  requestServer(urlPath, urlParams, function(obj) {
		    if (obj && obj.text && obj.text.length>0) {
		      runScript(obj.text);
		    } 
		  }, method);
		}

		/**
		 * gadgets.ioを利用してアプリケーションサーバへリクエスト処理を実際になげる
		 */
		function requestServer(urlPath, urlParams, callbackFunction, method) {
		  method = method || gadgets.io.MethodType.GET;
		  if (urlParams==null) {
		    urlParams = {};
		  } else if (typeof urlParams == "string") {
		    urlParams = parseQuery(urlParams);
		  }
		
		  if (config.session_id) urlParams[config.session_key] = config.session_id;
			
		  var params = {};
		  params[gadgets.io.RequestParameters.METHOD] = method;
		  params[gadgets.io.RequestParameters.CONTENT_TYPE] = gadgets.io.ContentType.TEXT;
		  params[gadgets.io.RequestParameters.REFRESH_INTERVAL] = 0

		  var url = "";
		  if (method == gadgets.io.MethodType.POST) {
		    url = config.base_url + urlPath;
		    params[gadgets.io.RequestParameters.POST_DATA] = encodeValues(urlParams);
		  } else {
		    url = config.base_url + urlPath;

		    var query = toQueryString(urlParams);
		    if (query.length>0) {
					if(url.indexOf("?") != -1) {
						url += "&" + query;
					} else {
						url += "?" + query;
					}
				}
		  }
		  gadgets.io.makeRequest(url, callbackFunction, params);
		}

		/**
		 * params内容をリクエストクエリ文字列に変換
		 */
		function toQueryString(params) {
		  var query = "";
		  for (var key in params) {
		    query += "&" + encodeURIComponent(key) + "=" + encodeURIComponent(params[key]);
		  }
		  if (query.length>0) query = query.substring(1);
		  return query;
		}

		/**
		 * リクエストクエリ文字列を解析しhashを生成する
		 */
		function parseQuery(query) {
		  var params = {};
		  if (query) {
		    var pairs = query.split("&");
		    for (var i = 0; i < pairs.length; i++) {
		      var kv = pairs[i].split("=");
					var params_key = decodeURIComponent(kv[0].replace(/\+/g, ' '));
					var params_value = kv[1] ? decodeURIComponent(kv[1].replace(/\+/g, ' ')) : '';
					
					if(params[params_key] == null) {
						// notihng
						
					} else if(typeof(params[params_key]) == "string" || params[params_key] instanceof String) {
						params_value = [params[params_key], params_value];
						
					} else if(typeof(params[params_key]) == "array" || params[params_key] instanceof Array) {
						params_value = params[params_key].concat([params_value]);
					}
					params[params_key] = params_value;
		    }
		  }
		  return params;
		}

		/**
		 * ガジェットの表示更新処理
		 */
		function updateContainer(html, evalScripts) {
		  if (!html) updateContainerError();
		  evalScripts = evalScripts || true;

		  //script実行
		  if (evalScripts) {
		    var ScriptFragment = '<script[^>]*>([\\S\\s]*?)<\/script>';
		    var scripts = html.match(new RegExp(ScriptFragment, 'img'));
		    if (scripts) {
		      for (var i=0; i<scripts.length; i++) {
		        var script = scripts[i].match(new RegExp(ScriptFragment, 'im'));
		        if (script) runScript(script[1]);
		      }
		    }
		  }

		  $("#gadget_container").html(html);
		  gadgets.window.adjustHeight();
			
		}

		/**
		 * ガジェットの表示をエラーとして更新する
		 */
		function updateContainerError(errorMessage) {
      ERR_MESSAGE = '<div style="color:#ff0000;">※ mixiとの通信にエラーが発生した可能性があります。</div>'
      if (typeof(errorMessage) != "undefined") {
        ERR_MESSAGE += errorMessage;
      }
		  updateContainer(ERR_MESSAGE + '<br><a href="#" onclick="location.reload();">TOPに戻る</a><br>');
		}

		/**
		 * スクリプトの実行処理。
		 */
		function runScript(script) {
		  try {
		    eval(script);
		  } catch (e) {
		    runScriptError(e);
		  }
		}

		/**
		 * スクリプトの実行に問題が起こった際の処理。
		 */
		function runScriptError(e) {
		  alert('javascriptに問題があります。:' + e);
		}

		/**
		 *　人単体情報をjsonに形式に変換
		 */
		function person_to_json(_person) {
		  return gadgets.json.stringify(_person_to_hash(_person));
		}

		/**
		 *　人複数の情報をjsonに形式に変換
		 */
		function people_to_json(_people) {
		  var people = [];
		  _people.each(function(_person) {
		    people.push(_person_to_hash(_person));
		  });
		  return gadgets.json.stringify(people);
		}

		/**
		 *　人情報のjsonに変換のコア
		 */
		function _person_to_hash(_person) {
		  var fields = {
		    'mixi_id' : opensocial.Person.Field.ID,
		    'nickname' : opensocial.Person.Field.NICKNAME,
		    'profile_url' : opensocial.Person.Field.PROFILE_URL,
		    'thumbnail_url' : opensocial.Person.Field.THUMBNAIL_URL
		  };
		  var person = {};
		  for (var key in fields) {
		    person[key] = _person.getField(fields[key]);
		  }
		  person['nickname'] = _person.getDisplayName(); //bug?? adhoc
		  return person;
		}

		/**
		 *　リクエスト情報をhtmlエンコードする
		 */
		function encodeValues(fields, opt_noEscaping) {
			var escape = !opt_noEscaping;

			var buf = [];
			var first = false;
			for (var i in fields) if (fields.hasOwnProperty(i)) {
				if (!first) {
					first = true;
				} else {
					buf.push("&");
				}
				if (fields[i] instanceof Array) {
					var array = fields[i];
					for(var j = 0 ; j < array.length ; j++) {
						buf.push(escape ? encodeURIComponent(i) : i);
						buf.push("=");
						buf.push(escape ? encodeURIComponent(array[j]) : array[j])
						if (j != array.length - 1) {
							buf.push("&");
						}
					}
				} else {
					buf.push(escape ? encodeURIComponent(i) : i);
					buf.push("=");
					buf.push(escape ? encodeURIComponent(fields[i]) : fields[i]);
				}
			}
			return buf.join("");	
		}
		
		/**
		 *　指定位置へスクロールする
		 */
		klass.scrollTo = function(point_id) {
			var scrollpoint = 0
			if($.browser.mozilla) {
				gadgets.window.adjustHeight(1);
				setTimeout(function(){gadgets.window.adjustHeight();}, 0);
			} else {
				if(point_id != null) {
					scrollpoint = $("#" + point_id).position().top;
				}
				window.parent.scrollTo(0, scrollpoint);
			}
			return false;
		}
		
		/**
		 *　流入を確認するためのiframeを表示する
		 */
		klass.infollow_iframe = function() {
			$.opensocial_simple.getPerson(function (result) {
				var iframe = "<iframe src='" + config.base_url +"/mixi_inflows/show?app_name=" + config.app_name + "&mixi_user_id=" + result.VIEWER.getId() + "' name='inflow' width='0' height='0'></iframe>"
				$("#infollow_iframe").html(iframe);
			});
		}
		
		klass.gadget_iframe = function() {
			$.opensocial_simple.ajaxSetup({AUTHORIZATION: gadgets.io.AuthorizationType.SIGNED});
			$.opensocial_simple.get( config.base_url + "/mixi_gadget_iframe/remote_token", function (result) {
				token = result;
				$.opensocial_simple.getPerson(function (result) {
					var iframe = "<iframe src='" + config.base_url +"/mixi_gadget_iframe/index?app_name=" + config.app_name + "&mixi_user_id=" + result.VIEWER.getId() + "&mixi_token=" + token + "' name='mixi_app_iframe' width='" + config.iframe_width + "' height='" + config.iframe_height + "'></iframe>"
					$("#gadget_iframe").html(iframe);
				});
			});
		}
		
		/**
		 *　ユーザ招待をする画面をポップアップで表示
		 */
		klass.invite = function() {
			$.opensocial_simple.getPerson(function (result) {
				opensocial.requestShareApp("VIEWER_FRIENDS", null, function(response) {
					// 現時点で成功しても　hadError()　がかえるのでそこが解消するまで一旦サスペンド
				 　// if (response.hadError()) { 
				  //  	updateContainerError();
				  // } else {
					// }
					var params = {
						"drecom_mixiapp_inviteId": result.VIEWER.getId(),
	        	"drecom_mixiapp_recipientIds" : gadgets.json.stringify(response.getData()["recipientIds"])
	      	};
					requestServer('/mixi_gadget/invite_register', params, function() {}, gadgets.io.MethodType.POST);
				});
			});
		}

    klass.historyInit = function() {
      alert('klass.historyInit is not implemented.');
    };
    klass.getViewerFriends = function(offset) {
      if (offset == undefined) {
        offset = 0;
      }
      var deferred = new Deferred();
      $.opensocial_simple.getViewerFriends(function(data){
        deferred.call(data);
      }, 20, offset, config.has_app_filter);
      return deferred;
    };
		
		$[name_space] = klass;
		$[name_space.replace(/_([a-z])/g, function () { return arguments[1].toUpperCase() })] = klass;
		
		return this;
	};

})(jQuery);
