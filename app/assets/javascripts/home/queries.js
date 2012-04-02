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
        
    });
    this.el.delegate('.qht-remove', 'click', function() {
        that.remove($(this).closest('.qh-tab'));
    });
    this.content    
    this.index = {};
},
add: function(key, content) {
    var tab = $('<div class="qh-tab qh-selected"></div>');
    tab.append('<div class="qht-content">' + this.format(content) + '</div>');
    tab.append('<div class="qht-remove" title="Удалить вкладку"></div>');
    tab.attr('data-content', content);
    tab.attr('data-key', key);
    tab.attr('id', 'hs-' + key);
    this.el.find('.qh-selected').removeClass('qh-selected');
    this.el.prepend(tab).show();
    Queries.content.css('left', -tab.width());
    Queries.content.animate({'left': 0}, 350);
    this.index[key] = tab;
},
remove: function(tab) {
    var that = this;
    delete this.index[tab.attr('data-key')];
    tab.width('+=0').html('').removeClass('qh-selected');
    tab.animate({width: 0}, 350, function() {
        that.searches.toggle(tab.siblings().length !== 0);
        tab.remove();
    });
},
format: function(content) {
    return content.replace(' — ', '<span class="hst-period">&ndash;</span>');
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