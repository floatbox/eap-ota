/* History */
Queries = {
init: function() {
    this.el = $('#queries');
    if (browser.ios) {
        this.history.add = $.noop;
        this.show = $.noop;
        this.hide = $.noop;        
        this.height = 0;
    } else {
        this.height = this.el.show().outerHeight();
        this.content = this.el.find('.q-content');        
        this.history.init(this.el.find('.q-history'));
        //this.live.init(this.el.find('.q-live'));
    }
},
show: function() {
    var that = this;
    this.el.css('bottom', -this.height).show();
    this.el.animate({bottom: 0}, 250, function() {
        that.el.css('bottom', '');
        that.live.active = true;
    });
},
hide: function() {
    var that = this;
    this.live.active = false;
    this.el.animate({bottom: -this.height}, 250, function() {
        that.el.hide().css('bottom', '');
    });
}
};

/* History */
Queries.history = {
init: function(el) {
    var that = this;
    this.el = el;
    this.el.delegate('.qht-content', 'click', function() {
        var tab = $(this).closest('.qh-tab');
        if (true || !tab.hasClass('qh-selected')) {
            results.header.summary.hide();
            page.restoreResults(tab.attr('data-key'));
            that.el.find('.qh-selected').removeClass('qh-selected');
            tab.addClass('qh-selected');
        }
    });
    this.el.delegate('.qht-remove', 'click', function() {
        that.remove($(this).closest('.qh-tab'));
    });
    this.index = {};
    var saved = Cookie('searches');
    if (saved) {
        var tabs = saved.split('|');
        for (var i = 0; i < tabs.length; i++) {
            var key = tabs[i].split(' ', 1)[0];
            this.add(key, tabs[i].substring(key.length), true);
        }
    }
},
add: function(key, content, saved) {
    if (this.index[key]) return;
    var tab = $('<div class="qh-tab"></div>');
    tab.append('<div class="qht-content">' + this.format(content) + '</div>');
    tab.append('<div class="qht-remove" title="Удалить вкладку"></div>');
    tab.attr('data-content', content);
    tab.attr('data-key', key);
    tab.attr('id', 'hs-' + key);
    this.el.prepend(tab).show();
    Queries.content.css('left', -tab.width());
    Queries.content.animate({'left': 0}, 350);
    this.index[key] = tab;
    if (!saved) {
        this.save();
    }
},
remove: function(tab) {
    var that = this;
    delete this.index[tab.attr('data-key')];
    tab.width('+=0').html('').removeClass('qh-selected');
    tab.animate({width: 0}, 350, function() {
        that.el.toggle(tab.siblings().length !== 0);
        tab.remove();
    });
    this.save();
},
select: function(key) {
    this.el.find('.qh-selected').removeClass('qh-selected');
    if (this.index[key]) {
        this.index[key].addClass('qh-selected');
    }
},
format: function(content) {
    return content.replace(' — ', '<span class="hst-period">&ndash;</span>');
},
save: function() {
    var result = [];
    this.el.find('.qh-tab').each(function() {
        var tab = $(this);
        result.push(tab.attr('data-key') + ' ' + tab.attr('data-content'));
    });
    Cookie('searches', result.length ? result.join('|') : undefined, new Date().shift(3));
}
};

/* Live */
Queries.live = {
init: function(el) {
    this.el = el;
    this.items = this.el.find('.ql-items');
    this.last = this.el.find('.ql-item').last();
    var that = this;
    setInterval(function() {
        if (that.active && !that.hover) that.slide();
    }, 5000);
    this.el.hover(function() {
        that.hover = true;
    }, function() {
        that.hover = false;
    });;
    this.active = true;
},
slide: function() {
    var item = this.last;
    this.last = item.prev();
    item.css('margin-left', -item.outerWidth()).prependTo(this.items);
    item.animate({'margin-left': 0}, 500);
},
update: function(data) {
    var template = '<li><a href="/#{code}/featured" data-key="{code}">{description} от {hprice}</a></li>';
}
};