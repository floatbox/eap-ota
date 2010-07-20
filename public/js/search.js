// "Accept", "text/javascript"
// - странно, ведь нам же html нужен?
/*
jQuery.ajaxSetup({
    'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});
*/

app.search.change = function() {
    var data = {
        "search_type": "travel",
        "debug": 1,
        "rt": 1,
        "adults": 1,
        "children": 0,
        "nonstop": 0,
        "day_interval": 1
    }
    for (var key in this.fields) {
        var field = this.fields[key];
        var value = field.val();
        if (field.required && !value) return;
        data[key] = value;
    }
    app.offers.showLoader(data);
    //data.from = "MOW";
    //data.to = "LED";
    $.get("/pricer/", {
        search: data
    }, function(s) {
        $("#offers\\.loader").addClass("g-none");
        if (typeof s == "string") {
            // app.offers.update(s);
            $("#offers").html(s).removeClass("g-none");
        } else {
            alert(s && s.exception && s.exception.message);
        }
    });
};

app.search.fields = {};

app.offers.showLoader = function(data) {
    // Заполнение заголовка, пока не сделаем аяксовое
    var d1 = Date.parseAmadeus(data.date1);
    var d2 = Date.parseAmadeus(data.date2);
    var monthes = app.constant.MNg;
    var words = [d1.getDate(), monthes[d1.getMonth()], d2.getDate(), monthes[d2.getMonth()]];
    if (words[1] == words[3]) words[1] = "по"; else words[1] += " по";
    $("#offers\\.transcript s").text(data.from + " → " + data.to + ", c " + words.join(" "));

    $("#offers\\.transcript").removeClass("g-none");
    $("#offers\\.loader").removeClass("g-none");
    var w = $(window);
    var cst = w.scrollTop();
    var offset = $("#media").offset().top;
    if (offset - cst > w.height() / 2) {
        $({st: cst}).animate({
            st: offset - 112
        }, {
            duration: 500,
            step: function() {
                w.scrollTop(this.st);
            }
        });
    }
};

app.offers.update = function(s) {
    $("#offers\\.list").html(s).removeClass("g-none");
};

