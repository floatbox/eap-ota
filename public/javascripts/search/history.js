search.history = {
init: function() {
    this.el = $('#history');
    this.items = [];
    var saved = Cookie('searches_encoded');
    if (browser.platform.search(/ipad|iphone/) !== -1 || browser.name.search(/msie6|msie7/) !== -1) {
        this.toggle = function() {};
        this.update = function() {};
        this.show = function() {};
        return;
    }
    if (saved) {
        saved = saved.split('|');
        for (var i = 0, im = saved.length; i < im; i++) {
            var item = saved[i];
            var key = item.split(' ', 1)[0];
            this.add(key, item.substring(key.length));
        }
        this.show();
    }
    var that = this;
    this.el.delegate('.history-tab:not(.ht-selected) .ht-content', 'click', function() {
        $('#logo').click();
        var key = $(this).closest('.history-tab').addClass('ht-selected').attr('data-key');
        pageurl.update('search', key);
        search.validate(key);
    });
    this.el.delegate('.ht-remove', 'click', function() {
        var tab = $(this).closest('.history-tab');
        if (tab.hasClass('ht-selected')) {
            $('#logo').click();
        }
        that.remove(tab.attr('data-key'));
    });
},
update: function() {
    var selected = pageurl.search;
    if (selected && $('#ht' + selected).length === 0) {
        var content = $('#offers-options .ht-content');
        if (content.length !== 0) {
            this.add(selected, content.html());
            this.save();
        }
    }
    if (this.items.length > 1) {
        this.toggle(true);
    }
    this.show();
},
add: function(key, content) {
    var tab = $('<div class="history-tab"></div>').attr('id', 'ht' + key).attr('data-key', key);
    tab.append('<div class="ht-content">' + content + '</div>');
    tab.append('<div class="ht-remove" title="Удалить вкладку">&times;</div><div class="ht-shadow"></div>');
    this.items.push({el: tab, key: key, content: content});
    this.el.prepend(tab);
},
remove: function(key) {
    var tab = $('#ht' + key), tw = tab.width();
    var tph = $('<div/>').addClass('ht-placeholder').width(tw);
    tab.after(tph).remove();
    tph.animate({
        width: 1
    }, 300, function() {
        $(this).remove();
    });
    this.items = $.grep(this.items, function(item) {
        return item.key !== key;
    });
    if (this.items.length === 0) {
        this.active = false;
        this.el.hide();
    }
    this.save();
},
save: function() {
    var result = [];
    for (var i = 0, im = this.items.length; i < im; i++) {
        var item = this.items[i];
        result.push(item.key + ' ' + item.content);
    }
    Cookie('searches_encoded', result.length ? result.join('|') : undefined, new Date().shiftDays(3));
},
show: function() {
    var selected = pageurl.search;
    this.el.find('.history-tab').each(function() {
        var tab = $(this);
        $(this).toggleClass('ht-selected', tab.attr('data-key') === selected);
    });
},
toggle: function(mode) {
    if (this.items.length !== 0 && mode) {
        this.el.show().height(this.items[0].el.find('.ht-content').outerHeight() + 4);
        this.active = true;
    } else {
        this.el.hide();
    }
}
};