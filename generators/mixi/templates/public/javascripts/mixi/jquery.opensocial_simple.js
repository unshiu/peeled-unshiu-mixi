/**
 * jQuery opensocial-simple plugin
 * Copyright (C) KAYAC Inc. | http://www.kayac.com/
 * Dual licensed under the MIT <http://www.opensource.org/licenses/mit-license.php>
 * and GPL <http://www.opensource.org/licenses/gpl-license.php> licenses.
 * Date: 2009-05-13
 * @author kyo_ago <http://tech.kayac.com/archive/jquery-opensocial-simple.html>
 * @version 1.1.3
 */
;(function ($) {
	var name_space = 'opensocial_simple';
	var klass = {
		ajaxSettings : {
			'url' : undefined,
			'success' : function () {},
			'data' : undefined,
			'METHOD' : undefined,
			'CONTENT_TYPE' : undefined,
			'AUTHORIZATION' : undefined,
			'GET_SUMMARIES' : undefined,
			'HEADERS' : undefined,
			'NUM_ENTRIES' : undefined,
			'POST_DATA' : undefined,
			'REFRESH_INTERVAL' : undefined
		},
		'person' : {}
	};
	klass.get = function ( url, data, callback, type ) {
		if ($.isFunction(data)) {
			callback = data;
			data = null;
		}

		return klass.ajax({
			METHOD: 'GET',
			url: url,
			data: data,
			success: callback,
			CONTENT_TYPE: type
		});
	};
	$.each(gadgets.io.ContentType, function (k, v) {
		klass['get' + k] = function ( url, data, callback ) {
			return klass.get(url, data, callback, k);
		};
	});
	klass.post = function ( url, data, callback, type ) {
		if ($.isFunction(data)) {
			callback = data;
			data = {};
		}

		return klass.ajax({
			METHOD: 'POST',
			url: url,
			data: data,
			success: callback,
			CONTENT_TYPE: type
		});
	};
	klass.ajaxSetup = function ( settings ) {
		$.extend( klass.ajaxSettings, settings );
		return this;
	};
	klass.ajax = function ( settings ) {
		settings = $.extend(true, settings, $.extend(true, {}, klass.ajaxSettings, settings));

		var params = {};
		var req = gadgets.io.RequestParameters;

		(settings.data && (settings.METHOD == 'POST'))
			? params[req.POST_DATA] = $.param(settings.data || {})
			: settings.url += '?' + $.param(settings.data || {})
		;

		$.each([
			{
				'obj' : 'AuthorizationType',
				'req' : 'AUTHORIZATION'
			},
			{
				'obj' : 'ContentType',
				'req' : 'CONTENT_TYPE'
			},
			{
				'obj' : 'MethodType',
				'req' : 'METHOD'
			}
		], function () {
			var val = gadgets.io[this['obj']][settings[this['req']]];
			if (val !== undefined) params[req[this['req']]] = val;
		});
		if (settings['REFRESH_INTERVAL'] !== undefined) params[gadgets.io.RequestParameters.REFRESH_INTERVAL] = settings['REFRESH_INTERVAL'];
		$.each([
			'GET_SUMMARIES',
			'HEADERS',
			'NUM_ENTRIES'
		], function () {
			if (settings[this] !== undefined) params[this] = s[this];
		});

		gadgets.io.makeRequest(settings.url, function (data) {
			settings.success(data.data);
		}, params);

		return this;
	};
	klass.getPerson = function (callback) {
		if (klass.person.OWNER && klass.person.VIEWER) {
			if ($.isFunction(callback)) callback(klass.person);
			return klass.person;
		};
		var os = opensocial;
		var id = os.IdSpec.PersonId;
		var req = os.newDataRequest();
		req.add(req.newFetchPersonRequest(id.OWNER), 'OWNER');
		req.add(req.newFetchPersonRequest(id.VIEWER), 'VIEWER');
		req.send(function (res) {
			if (res.hadError()) return;
			klass.person.OWNER = res.get('OWNER').getData();
			klass.person.VIEWER = res.get('VIEWER').getData();
			if ($.isFunction(callback)) callback(klass.person);
		});
		return klass.person;
	};
	klass.getPersons = function (persons, callback) {
		var os = opensocial;
		var req = os.newDataRequest();
		var users = [];
		new function () {
			var tmp = {};
			$.each(persons, function () { tmp[this] = 1; });
			$.each(tmp, function (key) { users.push(key); });
		};
		var idSpec = (function () {
			var param = {};
			param[os.IdSpec.Field.USER_ID] = users;
			return opensocial.newIdSpec(param); 
		})();
		var param = {};
		param[os.DataRequest.PeopleRequestFields.PROFILE_DETAILS] = [
			os.Person.Field.PROFILE_URL
		];
		req.add(req.newFetchPersonRequest(idSpec, param), 'PERSONS');
		req.send(function (res) {
			if (res.hadError()) return;
			if ($.isFunction(callback)) callback(res.get('PERSONS').getData());
		});
		return klass.person;
	};
	klass.getFriends = function (settings) {
		var callback = settings.callback;
		var os = opensocial;
		var idspec = os.newIdSpec({
			'userId' : settings.userId,
			'groupId' : 'FRIENDS'
		});
		var fields = opensocial.DataRequest.PeopleRequestFields;
		var opt = {};
		if (settings.max !== undefined) opt[fields.MAX] = settings.max;
		if (settings.first !== undefined) opt[fields.FIRST] = settings.first;
    if (settings.has_app) opt[fields.FILTER] = os.DataRequest.FilterType.HAS_APP;
		var req = os.newDataRequest();
		req.add(req.newFetchPeopleRequest(idspec, opt), 'FRIENDS');
		req.send(function (res) {
			if (res.hadError()) return;
			var friends = res.get('FRIENDS').getData();
			var next = settings.first + settings.max;
			if (next < friends.getTotalSize()) friends.nextFriends = function (callback) {
				settings.callback = callback;
				settings.first = next;
				klass.getFriends(settings);
			};
			var prev = settings.first - settings.max;
			if (prev >= 0) friends.prevFriends = function (callback) {
				settings.callback = callback;
				settings.first = prev;
				klass.getFriends(settings);
			};
			friends.getFriends = function (callback, page) {
				settings.callback = callback;
				settings.first = settings.max * (page - 0);
				klass.getFriends(settings);
			};
			friends.getPageSize = function () {
				return Math.ceil(friends.getTotalSize() / settings.max);
			};
			friends.getCurrentPage = function () {
				return Math.ceil(friends.getOffset() / settings.max);
			};
			if ($.isFunction(callback)) callback(friends);
		});
		return;
	};
	klass.getOwnerFriends = function (callback, max, first, has_app) {
		return klass.getFriends({
			'callback' : callback,
			'userId' : 'OWNER',
			'max' : max,
			'first' : first,
      'has_app' : has_app
		});
	};
	klass.getViewerFriends = function (callback, max, first, has_app) {
		return klass.getFriends({
			'callback' : callback,
			'userId' : 'VIEWER',
			'max' : max,
			'first' : first,
      'has_app' : has_app
		});
	};
	new function () {
		var id = opensocial.IdSpec.PersonId;
		klass.getOwnerData = function (callback) {
			return klass.getData(callback, id.OWNER);
		};
		klass.postOwnerData = function (values, callback) {
			throw('security error');
		};
		klass.getViewerData = function (callback) {
			return klass.getData(callback, id.VIEWER);
		};
		klass.postViewerData = function (values, callback) {
			return klass.postData(values, callback, id.VIEWER);
		};
	};
	new function () {
		var viewerId = opensocial.IdSpec.PersonId.VIEWER;
		var ownerId = opensocial.IdSpec.PersonId.OWNER;
		var create_req = function (obj, func) {
			var req = opensocial.newDataRequest();
			var result = {};
			$.each(obj, function (key, val) {
				result[opensocial.IdSpec.Field[key]] = val;
			});
			var spec = opensocial.newIdSpec(result);
			var esp = {};
			esp[opensocial.DataRequest.DataRequestFields.ESCAPE_TYPE] = opensocial.EscapeType.NONE;
			req.add(req.newFetchPersonAppDataRequest(spec, name_space, esp), name_space);
			req.add(req.newFetchPersonRequest(viewerId), 'viewer');
			req.send(function (data) {
				if (data.hadError()) return(data.getErrorMessage() ? undefined : func.call(this));
				var viewer = data.get('viewer').getData(); 
				if (!viewer) return;
				func.apply(this, [data, viewer]);
			});
			return req;
		};
		klass.getData = function (callback, id) {
			if (!$.isFunction(callback)) throw('callback is not function');
			create_req({
				'USER_ID' : id
			}, function (data, viewer) {
				if (!$.isFunction(callback)) return;
				if (!data || !viewer) return callback({});
				var get = data.get(name_space).getData();
				var result = get[viewer.getId()] || get[viewer.getId().replace(/\D/g, '')];
				try {
					if ('string' === typeof result[name_space]) result[name_space] = gadgets.json.parse(decodeURIComponent(result[name_space]));
					result = result[name_space][name_space];
				} catch (e) {
					result = {};
				};
				return callback(result);
			});
			return this;
		};
		klass.getFriendsData = function (callback) {
			if (!$.isFunction(callback)) throw('callback is not function');
			create_req({
				'USER_ID' : ownerId,
				'GROUP_ID' : 'FRIENDS',
				'NETWORK_DISTANCE' : 1
			}, function (data, viewer) {
				if (!arguments.length) return callback({});
				var result = data.get(name_space).getData();
				(result[viewer.getId()] || result[viewer.getId().replace(/\D/g, '')] || {}).is_viewer = true;
				result.VIEWER = viewer;
				
				for (var id in result) {
					try {
						result[id] = gadgets.json.parse(result[id])[name_space];
					} catch (e) { };
				};
				return callback(result);
			});
			return this;
		};
	};
	new function () {
		var os = opensocial;
		var create_bridge = function (callback) {
			return function (data) {
				if (data.hadError()) return;
				if ($.isFunction(callback)) callback.apply(this, arguments);
			};
		};
		var create_param = function (params, name) {
			var result = {};
			var field = os[name].Field;
			$.each(params, function (key, val) {
				result[field[key] || key] = val;
			});
			return result;
		};
		klass.postData = function (values, callback, id) {
			var req = os.newDataRequest();
			var param = {};
			param[name_space] = values;
			req.add(req.newUpdatePersonAppDataRequest(id, name_space, encodeURIComponent(gadgets.json.stringify(param))));
			req.send(create_bridge(callback));
			return this;
		};
		klass.postActivity = function (title, priority, callback) {
			var activityPriority = os.CreateActivityPriority;
			var params = {'TITLE' : title};
			if ('string' !== typeof title) params = title;
			if ($.isFunction(priority)) {
				callback = priority;
				priority = activityPriority.LOW;
			}
			priority = activityPriority[priority] || priority;

			var param = create_param(params, 'Activity');
			var req = os.newActivity(param);
			os.requestCreateActivity(req, priority, create_bridge(callback));
			return this;
		};
		klass.postMessage = function (target, title, body, callback) {
			var messageType = os.Message.Type;
			var params = {
				'TITLE' : title,
				'TYPE' : 'PRIVATE_MESSAGE'
			};
			if ('string' !== typeof target) {
				params = target;
				if ($.isFunction(title)) callback = title;
				body = params['BODY'];
				delete params['BODY'];
				target = params['TARGET'];
				delete params['TARGET'];
			};
			params['TYPE'] = messageType[params['TYPE']] || params['TYPE'];

			var param = create_param(params, 'Activity');
			var req = os.newMessage(body, params);
			os.requestSendMessage(target, req, create_bridge(callback));
			return this;
		};
	};
	new function () {
		var viewerId = opensocial.IdSpec.PersonId.VIEWER;
		var ownerId = opensocial.IdSpec.PersonId.OWNER;
		var create_req = function (obj, func) {
			var req = opensocial.newDataRequest();
			var spec = opensocial.newIdSpec(obj);
			req.add(req.newFetchActivitiesRequest(spec), 'activity');
			req.send(function (data) {
				if (data.hadError()) return(data.getErrorMessage() ? undefined : func.call(this));
				func.apply(this, [data]);
			});
			return req;
		};
		klass.getActivity = function (callback) {
			if (!$.isFunction(callback)) throw('callback is not function');
			create_req({
				'USER_ID' : ownerId,
				'GROUP_ID' : 'SELF'
			}, function (data) {
				if (!$.isFunction(callback)) return;
				if (!data) return callback({});
				var get = data.get('activity')
				console.log(get);
				
				var result = {};
				for (var id in get) {
					try {
						result[id] = gadgets.json.parse(result[id])[name_space];
					} catch (e) { };
				};
				console.log(result);
				return callback(get);
			});
			return this;
			
			var idspec = os.newIdSpec({'userId':'OWNER', 'groupId':'SELF'});
			var req = os.newDataRequest();
			req.add(req.newFetchActivitiesRequest(idspec), 'activity');
			
		};
	};
	klass.getLocale = function (selector) {
		var result = {};
		var loc = $(selector || '.jQuery_opensocial_simple_locale').get(0).innerHTML.replace(/\/\*|\*\//g, '');
		if (!loc) throw('missing local value');
		var lang = (new gadgets.Prefs()).getLang();
		if (!(new RegExp('<Locale lang="'+lang+'">')).test(loc)) lang = '';
		var match = loc.match(new RegExp('<Locale lang="'+lang+'">([\\s\\S]+?)<\/Locale>'));
		if (!match) match = loc.match(new RegExp('<Locale>([\\s\\S]+?)<\/Locale>'));
		if (!match) return {};
		var msgs = match[1].match(/<msg\s+name="\w+">[\s\S]+?<\/msg>/gi);
		if (!msgs) return {};
		$.each(msgs, function () {
			var k_v = this.match(/<msg\s+name="(\w+)">([\s\S]+?)<\/msg>/i);
			result[k_v[1]] = k_v[2];
		});
		return result;
	};
	klass.navigateTo = function (name, param) {
		if (!gadgets.views.getSupportedViews) throw('require <Require feature="views" />');
		var all = gadgets.views.getSupportedViews();
		if (!all[name]) throw 'unsupportedViewName ' + name;
		gadgets.views.requestNavigateTo(all[name], param);
		return this;
	};
	klass.getParams = function () {
		if (!gadgets.views.getParams) throw('require <Require feature="views" />');
		return gadgets.views.getParams();
	};
	$[name_space] = klass;
	$[name_space.replace(/_([a-z])/g, function () { return arguments[1].toUpperCase() })] = klass;
})(jQuery);
