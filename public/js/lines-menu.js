function lineMenu(type) {
  $('li.nav-line-item').removeClass('active');
  $('#nav-' + type).addClass('active');

  $('.type-content').hide();
  $('#content-' + type).show();
}
