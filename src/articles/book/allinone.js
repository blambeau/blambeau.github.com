function book_toggle(identifier) {
  var page = $('#page_' + identifier);
  page.toggle();
  var link = $('#link_' + identifier);
  link.toggleClass("current");
}
function goto_page(url) {
  book_toggle(current);
  current = url;
  book_toggle(current);
}