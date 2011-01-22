function leave_a_comment() {
  $.ajax({type: "POST", 
          url: "/leave-comment", 
          data: $("form#leave-a-comment").serialize(), 
          dataType: "text/plain",
    error: function(data, textStatus, XMLHttpRequest) {
      $('form#leave-a-comment .feedback').html('<p class="ko">Sorry, an error occured. please try later!</p>');
    },
    success: function(data, textStatus, XMLHttpRequest) {
      if (data == "ok") {
        $('form#leave-a-comment .button').hide();
        $('form#leave-a-comment .feedback').html('<p class="ok">Thank you for your comment!</p>');
      } else {
        $('form#leave-a-comment .feedback').html('<p class="ko">Please provide a nickname and a message!</p>');
      }
    }
  });
  return false;
};
