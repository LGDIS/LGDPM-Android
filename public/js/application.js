// 登録画面初期処理
$("#evacuee-new").live("pageinit", function(event) {
  $("form").submit(function(event) {
    return false;
  });
  setup_address_select();
});

// 更新画面初期処理
$("#evacuee-edit").live("pageinit", function(event) {
  $("form").submit(function(event) {
    return false;
  });
  setup_address_select();
});

// 検索画面初期処理
$("#evacuee-search").live("pageinit", function(event) {
  $("form").submit(function(event) {
    return false;
  });
});

// ログイン画面初期処理
$("#login").live("pageinit", function(event) {
  $("form").submit(function(event) {
    return false;
  });
});

// 認証エラーメッセージ表示
function authentication_error() {
  $("#error_message").empty();
  $("#error_message").append("ログイン名またはパスワードが正しくありません。");
  $("#login-button").removeAttr("disabled");
}

// 住所選択セレクトボックスセットアップ
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

// 避難者データ保存時の検証処理
function validate_save() {
  var errors = new Array();
  if ($("#evacuee-family_name").val() == "") {
    errors.push("姓が入力されていません。");
  }
  if ($("#evacuee-given_name").val() == "") {
    errors.push("名が入力されていません。");
  }
  if ($("#evacuee-alternate_family_name").val() == "") {
    errors.push("姓（かな）が入力されていません。")
  } else if ($("#evacuee-alternate_family_name").val().match(/[^\u3040-\u309F]/)) {
    errors.push("姓（かな）は、ひらがなで入力してください。");
  }
  if ($("#evacuee-alternate_given_name").val() == "") {
    errors.push("名（かな）が入力されていません。");
  } else if ($("#evacuee-alternate_given_name").val().match(/[^\u3040-\u309F]/)) {
    errors.push("名（かな）は、ひらがなで入力してください。");
  }
  var date_of_birth_year = $("#evacuee-date_of_birth_year").val();
  var date_of_birth_month = $("#evacuee-date_of_birth_month").val();
  var date_of_birth_day = $("#evacuee-date_of_birth_day").val();

  if (date_of_birth_year == "" || date_of_birth_month == "" || date_of_birth_day == "") {
    errors.push("生年月日が入力されていません。");
  } else if (validate_date(date_of_birth_year, date_of_birth_month, date_of_birth_day) == false) {
    errors.push("生年月日が不正です。");
  }
  if ($("#evacuee-shelter_name").val() == "") {
    errors.push("避難所が選択されていません。");
  }
  if (validate_date($("#evacuee-shelter_entry_date_year").val(), $("#evacuee-shelter_entry_date_month").val(), $("#evacuee-shelter_entry_date_day").val()) == false) {
    errors.push("入所年月日が不正です。");
  }
  if (validate_date($("#evacuee-shelter_leave_date_year").val(), $("#evacuee-shelter_leave_date_month").val(), $("#evacuee-shelter_leave_date_day").val()) == false) {
    errors.push("退所年月日が不正です。");
  }
  if (errors.length > 0) {
    alert(errors.join("\n"));
    return false;
  }
  
  return confirm("保存します。よろしいですか？");
}

// 日付の検証処理
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

// 検索時の検証処理
function validate_search() {
  var errors = new Array();
  if (validate_date($("#evacuee-date_of_birth_year_from").val(), $("#evacuee-date_of_birth_month_from").val(), $("#evacuee-date_of_birth_day_from").val()) == false) {
    errors.push("開始生年月日が不正です。");
  }
  if (validate_date($("#evacuee-date_of_birth_year_to").val(), $("#evacuee-date_of_birth_month_to").val(), $("#evacuee-date_of_birth_day_to").val()) == false) {
    errors.push("終了生年月日が不正です。");
  }
  if (errors.length > 0) {
    alert(errors.join("\n"));
    return false;
  }
  return true;
}

// ログイン時時の検証処理
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

// 保存ボタン押下時の処理
function save_data(url) {
  if (validate_save()) {
    $.mobile.changePage(url, {type: "post", data: $("#evacuee-form").serialize()});
  }
}

// キャンセルボタン押下時の処理
function cancel_data(url) {
  $.mobile.changePage(url, {type: "get", reverse: true});
}

// 削除ボタン押下時の処理
function delete_data(url) {
  if (confirm("削除ししてよろしいですか？")) {
    $.mobile.changePage(url, {type: "post", reverse: true});
  }
}

// ダウンロードボタン押下時の処理
function confirm_download(url) {
  if (confirm("ダウンロードしますか？")) {
    $.mobile.changePage(url, {type: "get"});
  }
}

// 避難者アップロードキャンセルボタン押下時の処理
function cancel_upload(url) {
  $.post(url);
}

// 検索ボタン押下時の処理
function do_search(url) {
  if (validate_search()) {
    $.mobile.changePage(url, {type: "post", data: $("#evacuee-search-form").serialize()});
  }
}

// ログインボタン押下時の処理
function do_login(url) {
  $("#error_message").empty();
  $("#error_message").append("ログイン認証しています...");
  if (validate_login()) {
    $("#login-button").attr("disabled","disabled");
    $.post(url, $("#login-form").serialize());
  }
}