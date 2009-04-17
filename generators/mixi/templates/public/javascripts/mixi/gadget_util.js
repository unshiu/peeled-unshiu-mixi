/*
 * Unshiu Mixi Application JavaScript Library 
 * http://drecom.co.jp/
 *
 * Copyright (c) 2009 Drecom
 *
 */

/**
 * リクエスト内容をアプリケーションサーバへなげる
 */
function requestContainer(urlPath, urlParams, method) {
  requestServer(urlPath, urlParams, function(obj) {
    if (obj && obj.text && obj.text.length>0) {
      updateContainer(obj.text);
    } else {
      updateContainerError();
    }
  }, method);
}

/**
 * JSによるリクエスト内容をアプリケーションサーバへなげる
 */
function requestScript(urlPath, urlParams, method) {
  $('#gadget_container').startWaiting();
  requestServer(urlPath, urlParams, function(obj) {
    $('#gadget_container').stopWaiting();
    if (obj && obj.text && obj.text.length>0) {
      runScript(obj.text);
    } else {
      runScriptError();
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
  if (SESSIONID) urlParams['_baton_session_id'] = SESSIONID;

  var params = {};
  params[gadgets.io.RequestParameters.METHOD] = method;
  params[gadgets.io.RequestParameters.CONTENT_TYPE] = gadgets.io.ContentType.TEXT;
  
  var url = "";
  if (method == gadgets.io.MethodType.POST) {
    url = BASE_URL + urlPath;
    params[gadgets.io.RequestParameters.POST_DATA] = encodeValues(urlParams);
  } else {
    url = BASE_URL + urlPath;
    
    var query = toQueryString(urlParams);
    if (query.length>0) url += "?" + query;
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
				params[params_key] = params_value;
				
			} else {
				params_value = [params[params_key], params_value];
				params[params_key] = params_value;
			}
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
  document.getElementById('gadget_container').innerHTML = html;
  gadgets.window.adjustHeight();
}

/**
 * ガジェットの表示をエラーとして更新する
 */
function updateContainerError() {
  updateContainer('エラーが発生しました。<br><a href="#" onclick="location.reload();">TOPに戻る</a><br>');
}

/**
 * スクリプトの実行処理。
 */
function runScript(script) {
  try {
    eval(script);
  } catch (e) {
    runScriptError();
  }
}

/**
 * スクリプトの実行に問題が起こった際の処理。
 */
function runScriptError() {
  openAlert('エラーが発生しました。');
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
 *　各gadgetが読み込まれた際に一番最初に読まれる
 */
function gadgetInit() {
  switch(gadgets.views.getCurrentView().getName()) {
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
  var req = opensocial.newDataRequest();

  var idspec_owner = opensocial.IdSpec.PersonId.OWNER;
  var idspec_friends = opensocial.newIdSpec({'userId':opensocial.IdSpec.PersonId.OWNER, 'groupId':opensocial.IdSpec.GroupId.FRIENDS});

  var friend_params = {};
  friend_params[opensocial.DataRequest.PeopleRequestFields.MAX] = 1000;

  req.add(req.newFetchPersonRequest(idspec_owner), "owner");
  req.add(req.newFetchPeopleRequest(idspec_friends, friend_params), "friends");
  req.send(function (res) {
	  if (res.hadError()) {
      updateContainerError();
    } else {
      var params = {
        "owner" : person_to_json(res.get("owner").getData()),
        "friends" : people_to_json(res.get("friends").getData())
      };
      requestContainer('/mixi_gadget/register', params, gadgets.io.MethodType.POST);
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
        "owner" : owner.getField(opensocial.Person.Field.ID),
        "viewer" : viewer.getField(opensocial.Person.Field.ID)
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

gadgets.util.registerOnLoadHandler(gadgetInit);
