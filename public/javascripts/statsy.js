(function() {
  var ci;
  var visitor_id = null;
  if ((ci = document.cookie.indexOf("_stvis=")) != -1) {
    var endi = document.cookie.indexOf(';',ci);
    if (endi == -1) {endi = document.cookie.length}
    visitor_id = unescape(document.cookie.substring(ci + 7, endi));
  }
  var nv = 0;
  if (!visitor_id) {
    visitor_id = new Date().getTime() + '-' + Math.floor(Math.random() * 99999999);
    nv = 1;
    var exdate=new Date();
    exdate.setDate(exdate.getDate()+360);
    document.cookie="_stvis"+ "=" +escape(visitor_id)+";expires="+exdate.toUTCString();
  }
  // Save current page in a cookie, so that we can track a contiguous visit even if
  // the user leaves the site and then comes back.
  var last_page = null;

  var url = "http://localhost:3000/record/pageview.gif?" +
    "v=" + encodeURIComponent(visitor_id) +
    "&nv=" + nv +
    "&p=" + encodeURIComponent(document.location.href) +
    "&r=" + encodeURIComponent(document.referrer) +
    "&lp=" + encodeURIComponent(lage_page || '') +
    "&cb=" + Math.random() * 999;
  var img = document.createElement("img");
  img.height = 0;
  img.width = 0;
  img.src = url;
  document.body.append(img);
})();


