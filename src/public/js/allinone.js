function book_toggle(identifier) {
  $('#page_' + identifier).toggle();
  $('#link_' + identifier).toggleClass("current");
}
function goto_page(url) {
  book_toggle(current);
  current = url;
  book_toggle(current);
}