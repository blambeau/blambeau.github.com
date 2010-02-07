function goto_page(url) {
	document.getElementById('page_' + current).style.display = "none";
	document.getElementById('link_' + current).className = "normal";
	current = url;
	document.getElementById('page_' + current).style.display = "block";
	document.getElementById('link_' + current).className = "current";
}
