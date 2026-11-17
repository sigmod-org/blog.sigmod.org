// Shows "N reads" under a post: the old WordPress count (frozen) plus the new
// GoatCounter views (see _includes/post-meta.html). The label stays hidden until
// the total is known, so the number never changes in front of the reader.
(function () {
  var el = document.querySelector(".reads[data-path]");
  if (!el) return;
  var legacy = parseInt(el.getAttribute("data-legacy"), 10) || 0;
  function show(n) {
    el.querySelector(".reads-n").textContent = n.toLocaleString("en-US");
    el.hidden = false;
  }
  if (!window.fetch) return show(legacy);
  fetch(el.getAttribute("data-counter") + encodeURIComponent(el.getAttribute("data-path")) + ".json")
    .then(function (r) { return r.ok ? r.json() : { count: "0" }; })  // 404: no views yet
    .then(function (d) { show(legacy + (parseInt(String(d.count).replace(/\D/g, ""), 10) || 0)); })
    .catch(function () { show(legacy); });  // counter unreachable: old count only
})();
