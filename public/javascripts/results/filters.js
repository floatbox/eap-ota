results.filters = {
init: function() {
    var that = this;
    this.items = {};
    this.selected = {};
    this.el = $('#results-filters');
    this.el.find('.filter').each(function() {
        var f = new controls.Filter($(this));
        f.template = ': $';
        f.el.bind('change', function(e, values) {
            var name = $(this).attr('data-name');
            if (values && values.length) {
                that.selected[name] = values;
            } else {
                delete(that.selected[name]);
            }            
            if (that.active) {
                results.applyFilters();
            }
        });
        that.items[$(this).attr('data-name')] = f;
    });
    this.el.find('.rfshow').click(function() {
        that.show();
    });
    this.el.find('.rfhide').click(function() {
        that.hide();
    });
    this.el.find('.rfreset').click(function() {
        that.reset();
        results.applyFilters();
    });
    $('#offers').delegate('.rfreset', 'click', function() {
        that.reset();
        results.applyFilters();
    });
    var lf = this.items['layovers'];
    lf.dropdown.removeClass('dropdown').addClass('vlist');
    lf.show = function() {};
    lf.hide = function() {};
},
show: function() {
    var height = this.el.height();
    var el = this.el.css({
        height: height,
        overflow: 'hidden'
    });
    el.removeClass('hidden').animate({
        height: el.find('.rfvisible').height()
    }, 150, function() {
        el.css({
            height: 'auto',
            overflow: ''
        });
    });
},
hide: function() {
    this.el.css({
        height: this.el.height(),
        overflow: 'hidden'
    }).animate({
        height: 30
    }, 150, function() {
        var el = $(this).addClass('hidden').css({
            height: 'auto',
            overflow: ''
        });
    });
},
reset: function() {
    this.active = false;
    for (var key in this.selected) {
        this.items[key].reset();
    }
    this.selected = {};
    this.active = true;
},
update: function(data) {
    this.active = false;
    var that = this;
    this.el.find('.rfreset').addClass('latent');
    this.el.find('.rftitle').removeClass('latent');
    this.el.find('.filter').each(function() {
        var name = $(this).attr('data-name');
        var f = that.items[name];
        f.fill(data[name]);
        f.el.toggleClass('latent', f.items.length < 2);
        var lid = f.el.attr('data-location');
        if (lid && data.locations[lid]) {
            f.el.find('.control').html((lid.charAt(0) == 'd' ? 'вылет ' : 'прилёт ') + data.locations[lid]);
        }
    });
    this.el.find('.filters').each(function() {
        $(this).closest('td').toggleClass('latent', $(this).find('.filter:not(.latent)').length === 0);
    });
    this.el.removeClass('hidden');
    this.data = data;
    this.selected = {};
    this.active = true;
}
};
