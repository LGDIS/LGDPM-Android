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
    if (validate_date($("#evacuee-birthday_year_from").val(), $("#evacuee-birthday_month_from").val(), $("#evacuee-birthday_day_from").val()) == false) {
      errors.push("開始生年月日が不正です。")
    }
    if (validate_date($("#evacuee-birthday_year_to").val(), $("#evacuee-birthday_month_to").val(), $("#evacuee-birthday_day_to").val()) == false) {
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


function setup_address_select() {
  $("#evacuee-prefecture").change(function(event) {
	var pref_cd = $(this).val();
    if (pref_cd == "") {
      var city_select = $("#evacuee-city");
      city_select.empty();
      city_select.append("<option value=''>－</option>");
      city_select.selectmenu('refresh', true); 
    } else {
      $.get("/app/Address/cities", {"pref_cd": pref_cd}, function(data){
        var city_select = $("#evacuee-city");
        city_select.empty();
        city_select.append(data);
        city_select.selectmenu('refresh', true); 
      });
    }
    var town_select = $("#evacuee-town");
    town_select.empty();
    town_select.append("<option value=''>－</option>");
    town_select.selectmenu('refresh', true); 
  });
  $("#evacuee-city").change(function(event) {
    var city_cd = $(this).val();
    if (city_cd == "") {
      var town_select = $("#evacuee-town");
      town_select.empty();
      town_select.append("<option value=''>－</option>");
      town_select.selectmenu('refresh', true); 
    } else {
      $.get("/app/Address/towns", {"pref_cd": $("#evacuee-prefecture").val(), "city_cd": $(this).val()}, function(data){
        var town_select = $("#evacuee-town");
        town_select.empty();
        town_select.append(data);
        town_select.selectmenu('refresh', true); 
      });
    }
  });
}

function validate_evacuee() {
  var errors = new Array();
  if ($("#evacuee-sei").val() == "") {
    errors.push("姓が入力されていません。")
  }
  if ($("#evacuee-mei").val() == "") {
    errors.push("名が入力されていません。")
  }
  if ($("#evacuee-sei_kana").val() == "") {
    errors.push("姓（カナ）が入力されていません。")
  }
  if ($("#evacuee-mei_kana").val() == "") {
    errors.push("名（カナ）が入力されていません。")
  }
  var birthday_year = $("#evacuee-birthday_year").val();
  var birthday_month = $("#evacuee-birthday_month").val();
  var birthday_day = $("#evacuee-birthday_day").val();

  if (birthday_year == "" || birthday_month == "" || birthday_day == "") {
    errors.push("誕生日が入力されていません。")
  } else if (validate_date(birthday_year, birthday_month, birthday_day) == false) {
    errors.push("誕生日が不正です。")
  }
  if ($("#evacuee-shelter").val() == "") {
    errors.push("避難所が選択されていません。")
  }
  if (validate_date($("#evacuee-in_date_year").val(), $("#evacuee-in_date_month").val(), $("#evacuee-in_date_day").val()) == false) {
    errors.push("入所日が不正です。")
  }
  if (validate_date($("#evacuee-out_date_year").val(), $("#evacuee-out_date_month").val(), $("#evacuee-out_date_day").val()) == false) {
    errors.push("退所日が不正です。")
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

function delete_data(url) {
  if (confirm("削除ししてよろしいですか？")) {
    $.mobile.changePage(url, {type: "post", reverse: true});
  }
}