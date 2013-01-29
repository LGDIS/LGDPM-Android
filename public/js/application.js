$("#evacuee-new").live("pageinit", function(event) {
  $("#evacuee-form").submit(function(event) {
    return false;
  });
  $("#save-button").click(function(event) {
    if (validate_evacuee()) {
      $.mobile.changePage($("#evacuee-form").attr("action"), {
        type: "post",
        data: $("#evacuee-form").serialize()
      });
    }
  });
  setup_address_select();
});

$("#evacuee-edit").live("pageinit", function(event) {
  $("#evacuee-form").submit(function(event) {
    return false;
  });
  $("#save-button").click(function(event) {
    if (validate_evacuee()) {
      $.mobile.changePage($("#evacuee-form").attr("action"), {
        type: "post",
        data: $("#evacuee-form").serialize()
      });
    }
  });
  setup_address_select();
});

$("#evacuee-search").live("pageinit", function(event) {
  $("#evacuee-search-form").submit(function(event) {
	return false;
  });
  $("#search-button").click(function(event) {
	var errors = new Array();
    if (validate_date($("#evacuee-date_of_birth_year_from").val(), $("#evacuee-date_of_birth_month_from").val(), $("#evacuee-date_of_birth_day_from").val()) == false) {
      errors.push("開始生年月日が不正です。")
    }
    if (validate_date($("#evacuee-date_of_birth_year_to").val(), $("#evacuee-date_of_birth_month_to").val(), $("#evacuee-date_of_birth_day_to").val()) == false) {
      errors.push("終了生年月日が不正です。")
    }
    if (errors.length > 0) {
      alert(errors.join("\n"));
      return false;
    }
    
    $.mobile.changePage($("#evacuee-search-form").attr("action"), {
      type: "post",
      data: $("#evacuee-search-form").serialize()
    });
  });
});

$("#login").live("pageinit", function(event) {
  $("#login-form").submit(function(event) {
    return false;
  });
  $("#login-button").click(function(event) {
    $("#error_message").empty();
    $("#error_message").append("サーバにログインしています...");
    if (validate_login()) {
      $("#login-button").attr("disabled","disabled");
      $.post($("#login-form").attr("action"), $("#login-form").serialize());
    }
  });
});

function authentication_error() {
  $("#error_message").empty();
  $("#error_message").append("ログイン名またはパスワードが正しくありません。");
  $("#login-button").removeAttr("disabled");
}

function setup_address_select() {
  $("#evacuee-home_state").change(function(event) {
	var state_cd = $(this).val();
    if (state_cd == "") {
      var city_select = $("#evacuee-home_city");
      city_select.empty();
      city_select.append("<option value=''>－</option>");
      city_select.selectmenu('refresh', true); 
    } else {
      $.get("/app/Address/cities", {"state_cd": state_cd}, function(data){
        var city_select = $("#evacuee-home_city");
        city_select.empty();
        city_select.append(data);
        city_select.selectmenu('refresh', true); 
      });
    }
    var street_select = $("#evacuee-home_street");
    street_select.empty();
    street_select.append("<option value=''>－</option>");
    street_select.selectmenu('refresh', true); 
  });
  $("#evacuee-home_city").change(function(event) {
    var city_cd = $(this).val();
    if (city_cd == "") {
      var street_select = $("#evacuee-home_street");
      street_select.empty();
      street_select.append("<option value=''>－</option>");
      street_select.selectmenu('refresh', true); 
    } else {
      $.get("/app/Address/streets", {"state_cd": $("#evacuee-home_state").val(), "city_cd": $(this).val()}, function(data){
        var street_select = $("#evacuee-home_street");
        street_select.empty();
        street_select.append(data);
        street_select.selectmenu('refresh', true); 
      });
    }
  });
}

function validate_evacuee() {
  var errors = new Array();
  if ($("#evacuee-family_name").val() == "") {
    errors.push("姓が入力されていません。")
  }
  if ($("#evacuee-given_name").val() == "") {
    errors.push("名が入力されていません。")
  }
  if ($("#evacuee-alternate_family_name").val() == "") {
    errors.push("姓（カナ）が入力されていません。")
  }
  if ($("#evacuee-alternate_given_name").val() == "") {
    errors.push("名（カナ）が入力されていません。")
  }
  var date_of_birth_year = $("#evacuee-date_of_birth_year").val();
  var date_of_birth_month = $("#evacuee-date_of_birth_month").val();
  var date_of_birth_day = $("#evacuee-date_of_birth_day").val();

  if (date_of_birth_year == "" || date_of_birth_month == "" || date_of_birth_day == "") {
    errors.push("生年月日が入力されていません。")
  } else if (validate_date(date_of_birth_year, date_of_birth_month, date_of_birth_day) == false) {
    errors.push("生年月日が不正です。")
  }
  if ($("#evacuee-shelter_name").val() == "") {
    errors.push("避難所が選択されていません。")
  }
  if (validate_date($("#evacuee-shelter_entry_date_year").val(), $("#evacuee-shelter_entry_date_month").val(), $("#evacuee-shelter_entry_date_day").val()) == false) {
    errors.push("入所年月日が不正です。")
  }
  if (validate_date($("#evacuee-shelter_leave_date_year").val(), $("#evacuee-shelter_leave_date_month").val(), $("#evacuee-shelter_leave_date_day").val()) == false) {
    errors.push("退所年月日が不正です。")
  }
  if (errors.length > 0) {
	  alert(errors.join("\n"));
	  return false;
  }
  
  return confirm("保存ししてよろしいですか？");
}

function validate_date(year, month, day) {
  if (year == "" && month == "" && day == "") {
	return true;
  }
  if (year == "" || month == "" || day == "") {
	return false;
  }
  var iYear = parseInt(year, 10);
  var iMonth = parseInt(month, 10) - 1;
  var iDay = parseInt(day, 10);
  
  var d = new Date(iYear, iMonth, iDay);
  if (isNaN(d)) {
	return false
  }
  if (d.getFullYear() == iYear && d.getMonth() == iMonth && d.getDate() == iDay) {
	return true;
  }
  return false;
}
function validate_login() {
  var errors = new Array();
  if ($("#login_id").val() == "") {
    errors.push("ログインIDが入力されていません。")
  }
  if ($("#password").val() == "") {
    errors.push("パスワードが入力されていません。")
  }
  if (errors.length > 0) {
	  alert(errors.join("\n"));
	  return false;
  }
  return true;
}

function delete_data(url) {
  if (confirm("削除ししてよろしいですか？")) {
    $.mobile.changePage(url, {type: "post", reverse: true});
  }
}

function confirm_download(url) {
  if (confirm("ダウンロードしますか？")) {
    $.mobile.changePage(url, {type: "get"});
  }
}

function cancel_upload(url) {
  $.post(url);
}
