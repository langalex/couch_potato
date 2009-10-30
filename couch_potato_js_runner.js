          // taken and adapted from http://scriptnode.com/article/javascript-print_r-or-var_dump-equivalent/

/**
 * Concatenates the values of a variable into an easily readable string
 * by Matt Hackett [scriptnode.com]
 * @param {Object} x The variable to debug
 * @param {Number} max The maximum number of recursions allowed (keep low, around 5 for HTML elements to prevent errors) [default: 10]
 * @param {String} sep The separator to use between [default: a single space ' ']
 * @param {Number} l The current level deep (amount of recursion). Do not use this parameter: it's for the function's own use
 */
function print_r(x, max, sep, l) {

	l = l || 0;
	max = max || 10;
	sep = sep || ' ';

	if (l > max) {
		throw("Too much recursion");
	};

	var r = '';

	if (x === null) {
		r += "null";
	} else if (is_array(x)) {
	  r += '[' + x.map(function(i) {
	    return print_r(i, max, sep, (l + 1));
	  }).join(', ') + ']';
	} else if(is_object(x)) {
    r += '{'
    var pairs = [];
    for (i in x) {
			pairs.push('"' + i + '": ' + print_r(x[i], max, sep, (l + 1)));
		}
		r += pairs.join(', ');
    r += '}';
	} else if(is_string(x)) {
	  r += '"' + x + "\"";
  } else {
    r += x;
  };

  return r;
  
  function is_string(a) {
    return typeof a === 'string';
  };
	
	function is_array(a) {
    return (a &&
      typeof a === 'object' &&
      a.constructor === Array);
  };
  
  function is_object(a) {
    return a && typeof a == 'object'
  };
  
};


          var doc = {"tags":["person","male"],"name":"horst"};
          var map = function(doc) {emit(doc.name, doc.tags.length);};
          var result = [];
          var emit = function(key, value) {
            result.push([key, value]);
          };
          map(doc);
          print(print_r(result));
