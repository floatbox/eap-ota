/* Results */
var results = {
init: function() {
    this.header.init();
    this.message.init();
    this.content.init();
    this.filters.init();
    this.queue.init();
    this.fixed.init();
    this.bookTemplate = $('#ob-template').clone().removeAttr('id');
    this.debug = Boolean($('#search-debug').length);
},
show: function(instant) {
    var that = this, context;
    this.queue.stop();
    this.header.buttonEnabled.hide();
    if (this.ready) {
        this.content.el.show();
        this.filters.show();
    } else {
        this.message.show();
    }
    if (!browser.ios) {
        page.header.addClass('fixed');
    }
    if (instant) {
        context = search.el.hide();
        $w.scrollTop(0);
    } else if ($.support.fixedPosition) {
        that.fixed.preview();    
        context = $w.delay(300);
        context.smoothScrollTo(this.header.position(), 450);
        context.delay(100).queue(function(next) {
            search.el.hide();
            $w.scrollTop(that.header.position());
            next();
        });
    } else {
        context = search.el.delay(300).slideUp(600);
    }
    context.queue(function(next) {
        that.visible = true;
        that.header.el.addClass('rh-fixed');
        that.header.button.hide();
        that.header.edit.show();
        that.fixed.update();
        that.queue.resume();
        next();
    });
    search.active = false;
},
hide: function() {
    booking.abort();
    var that = this, context;
    this.header.edit.hide();
    this.header.buttonEnabled.hide();
    this.header.button.show();
    this.visible = false;
    this.fixed.update();
    if (browser.ios) {
        context = search.el.delay(100).slideDown(600);
    } else {
        search.el.show();
        search.map.resize();
        search.map.load();
        context = $w.scrollTop(this.header.position());
        context.delay(100).smoothScrollTo(0, 450);
        this.header.el.removeClass('rh-fixed');
    }
    context.delay(100).queue(function(next) {
        page.header.removeClass('fixed');
        that.header.buttonEnabled.fadeIn(150);
        that.message.el.hide();
        that.content.el.hide();
        that.filters.hide();
        search.active = true;
        next();
    });
},
slide: function() {
    var that = this;
    this.message.el.hide();
    this.content.el.show();
    this.filters.el.show();
    this.fixed.update();
    page.title.set(local.title.results.absorb(this.data.titles.window));
},
update: function(data) {
    this.data = data;
    this.updateTitles();
    this.header.show(this.data.titles.header, data.valid);
    this.data.fresh = true;
    if (page.location.booking) {
        page.title.set(local.title.booking.absorb(results.data.titles.window));    
    }
},
load: function() {
    var that = this;
    var data = {query_key: this.data.query_key};
    if (this.data.fragment_exist) {
        data.restore_results = true;
    }
    this.getPriceTemplate();
    this.all.load('/pricer/', data, 150000);
    this.matrix.load('/calendar/', data, 75000);
    page.showData(this.data);
    this.data.fresh = false;
    this.ready = false;
    this.message.toggle('loading');
},
updated: function() {
    var that = this;
    if (this.all.loading || this.matrix.loading) return;
    this.queue.add(function() {
        that.processCollections();
    });
},
changeDates: function(dates) {
    this.updateTitles(dates);
    var titles = this.data.titles;
    this.header.summary.html(titles.header);
    page.title.set(local.title.results.absorb(titles.window));
},
updateTitles: function(dates) {
    var wparts = [];
    var hparts = [];
    var year = search.dates.csnow.getFullYear();
    var yearUsed = false;
    if (this.data && this.data.segments) {
        for (var i = 0, l = this.data.segments.length; i < l; i++) {
            var segment = this.data.segments[i];
            var date = Date.parseDMY(dates ? dates[i] : segment.date);
            var title = segment.rt ? 'обратно' : segment.title;
            var hdate = date.human(!yearUsed && date.getFullYear() !== year && (yearUsed = true));
            hparts[i] = title.replace(/(^из| в) /g, '$1&nbsp;') + ' ' + hdate.nowrap();
            wparts[i] = title + ' на ' + hdate;
        }
        if (this.data.options.human) {
            hparts.push(this.data.options.human);
        }
    }
    this.data.titles = {
        header: hparts.join(', ').capitalize(),
        window: wparts.join(', ')
    };
},
processSubscription: function() {
    var form = this.all.content.find('.r-subscription');
    this.cheap.content.find('.r-subscription').remove();
    this.cheap.content.append(form);
    this.subscription.init(form);
},
processCollections: function() {
    var that = this;
    if (this.all.offers.length) {
        var tab = page.location.offer;
        if (tab && results[tab] && !results[tab].control.hasClass('rt-disabled')) {
            this.content.select(tab);
        } else {
            this.content.selectFirst();
        }
        this.processSubscription();
        setTimeout(function() {
            that.ready = true;
            if (that.visible) {
                that.slide();
            }
        }, 30);
    } else {
        this.message.toggle('empty');
        trackPage('/search/empty');
    }
},
updateFeatured: function() {
    var cheap = this.getCheap();
    var cheapNonstop = 0;
    var cheapOptimal = 0;
    for (var i = cheap.length; i--;) {
        var features = cheap[i].features;
        if (features.nonstop) cheapNonstop++;
        if (features.optimal) cheapOptimal++;
    }
    var nonstop = [];
    if (cheap.length && cheapNonstop === cheap.length) {
        this.cheap.update(cheap, 'cheapNonstop'); // Все дешевые оказались прямыми
        this.nonstop.control.addClass('rt-disabled').hide();
    } else {
        this.cheap.update(cheap);    
        this.nonstop.control.show();
        nonstop = this.getNonstop();
    }
    this.nonstop.update(nonstop);
    var optimal = [];
    if (cheapNonstop + cheapOptimal < cheap.length) {
        var mp, md;
        if (nonstop.length !== 0) {
            var first = nonstop[0];
            md = first.duration * 2;
            mp = first.price;
        } else {
            var fast = this.getFastDuration();
            md = Math.max(fast * 1.25, fast + 120);
        }
        optimal = this.getOptimal(md, mp);
    }
    if (optimal.length === cheapOptimal) {
        optimal = []; // Все оптимальные есть в дешевых
    }
    this.optimal.update(optimal);
},
getCheap: function() {
    var mp, md;
    return this.getVariants(function(v) {
        mp = mp || Math.min(v.price * 1.5, v.price + 10000);
        return v.price < mp && v.duration < (md || (md = v.duration * 5));
    }, 20);
},
getNonstop: function() {
    var mp;
    return this.getVariants(function(v) {
        //return v.features.nonstop && v.price < (mp || (mp = Math.min(v.price * 1.5, v.price + 10000)));
        return v.features.nonstop;
    });
},
getOptimal: function(md, mp) {
    return this.getVariants(function(v) {
        return v.duration < md && (mp ? (v.features.optimal && v.price < mp) : true);
    }, 20);
},
getFastDuration: function() {
    var fd;
    this.getVariants(function(v) {
        fd = fd ? Math.min(fd, v.duration) : v.duration;
    });
    return fd;
},
getVariants: function(condition, limit) {
    var result = [];
    var offers = this.all.offers;
    for (var i = 0, im = offers.length; i < im; i++) {
        var offer = offers[i], variants = offer.variants;
        for (var v = 0, vm = variants.length; v < vm; v++) {
            var variant = variants[v];
            if (!variant.improper && condition(variant)) {
                result.push(variant);
            }
        }
        if (limit && result.length > limit) {
            break;
        }
    }
    return result;
},
extendData: function() {
    var segments = this.data.segments;
    if (!segments) return;
    var sl = segments.length;
    var titles = [], os = local.offers.othersegments;
    for (var s = sl; s--;) {
        if (s === 0 && sl > 1 && segments[1].rt) {
            titles[s] = os.rt;
        } else {
            var mw = sl > 2;
            var parts = [];
            for (var i = 0; i < sl; i++) {
                if (i !== s) parts.push(segments[i][mw ? 'arvto_short' : 'arvto']);
            }
            titles[s] = os[mw ? 'many' : 'one'].absorb(parts.enumeration());
        }
    }
    this.data.ostitles = titles;
    var height = page.innerHeight() - 150; // заголовок и табы
    height -= sl * 60; // сортировка и ссылки на скрытые варианты
    height -= 62; // цена и часть подробностей
    this.data.capacity = Math.max(sl * 2, Math.floor(height / 35));
    this.data.sl = sl;
},
getOfferTemplate: function() {
    var sample = this.all.offers[0];
    var offer = $('<div class="offer">');
    var segments = $('<div class="o-segments">').appendTo(offer);
    sample.el.find('.o-segment').each(function() {
        var s = $(this);
        var segment = $('<div></div>').addClass(s.attr('class'));
        s.find('.os-title').clone().appendTo(segment);
        segment.appendTo(segments);
    });
    this.offerTemplate = offer;
},
getPriceTemplate: function() {
    this.stateTemplate = local.offers.price[this.data.options.total !== 1 ? 'many' : 'one'];
    this.priceTemplate = local.offers.price.buy;
},
currencies: {
    RUR: '{0} <span class="ruble">Р</span>',
    USD: '{0} $'
}
};

/* Processing queue */
results.queue = {
init: function() {
    var that = this;
    this.items = [];
    this.$next = function() {
        that.next();
    }
},
add: function(item) {
    this.items.push(item);
    if (!this.active && !this.stopped) {
        this.next();
    }
},
next: function() {
    var item = this.items.shift();
    if (item) item();
    if (this.active = this.items.length !== 0) {
        this.timer = setTimeout(this.$next, 30);
    }
},
stop: function() {
    clearTimeout(this.timer);
    this.stopped = true;
},
resume: function() {
    this.stopped = false;
    this.next();
}
};

/* Message */
results.message = {
init: function() {
    this.el = $('#results-message');
    this.content = this.el.find('.rm-content');
    this.loading = $('#rm-loading');
    this.empty = $('#rm-empty');
},
update: function() {
    this.content.width(this.loading.find('.rmt-text').width());
    var height = this.content.height();
    this.el.find('.rm-half').css('margin-bottom', 30 - Math.round(height / 2));
    this.el.css('min-height', height + 150);
    this.update = $.noop;
},
toggle: function(mode) {
    this.loading.toggle(mode === 'loading');
    this.empty.toggle(mode === 'empty');
},
show: function() {
    this.el.show();
    this.update();
}
};

/* Fixed book button */
results.fixed = {
init: function() {
    var that = this, state, tedge, bedge;
    if (browser.ios) {
        this.update = function() {};
        this.move = function() {};
        return false;
    }
    this.toggle = function() {
        var st = $w.scrollTop(), s = 1
        if (st > tedge) {
            s = 2;
        } else if (st < bedge) {
            s = 0;
        }
        if (s !== state) {
            that.el.toggleClass('ob-fixed', s !== 1);
            that.el.toggleClass('ob-tfixed', s === 2);
            that.el.toggleClass('ob-bfixed', s === 0);
            state = s;
        }
    };
    this.count = function() {
        var offset = that.el.find('.o-details').offset().top;
        tedge = offset - 128 - 52;
        bedge = offset - $w.height() + Queries.height;
        that.toggle();
    };
    this.reset = function() {
        state = false;
    };
},
move: function() {
    if (this.el) {
        this.count();
    }
},
bind: function() {
    this.count();
    $w.bind('scroll', this.toggle).bind('resize', this.count);
},
unbind: function() {
    $w.unbind('scroll', this.toggle).unbind('resize', this.count);
    this.el.removeClass('ob-fixed ob-tfixed ob-bfixed');
    this.reset();
},
update: function() {
    if (this.el) {
        this.unbind();
        delete this.el;
    }
    if (this.el = this.getOfferEl()) {
        this.bind();
        this.el.find('.o-book').css({
            position: '',
            bottom: '',
            top: ''
        });
    }
},
getOfferEl: function(visible) {
    if ((visible || results.visible) && results.ready) {
        var tab = results[results.content.selected];
        return tab.offer && tab.offer.el;
    }
},
preview: function() {
    return;
    var el = this.getOfferEl();
    if (el) {
        var book = el.find('.o-book');
        var rtop = results.content.position() + $w.height() - book.outerHeight() - page.history.height;
        var btop = el.find('.o-book').position().top;
        if (btop > rtop) {
            book.css({
                position: 'absolute',
                bottom: 'auto',
                top: rtop
            });
            el.addClass('fixed-book');
        }
    }
}
};

/* Subscription form */
results.subscription = {
init: function(el) {
    var that = this;
    this.el = el.find('form');
    this.button = this.el.find('.rsf-submit').prop('disabled', false);
    this.field = this.el.find('.rsf-field');
    this.error = this.el.find('.rsf-error');
    this.el.submit(function(event) {
        event.preventDefault();
        that.send();
    });
},
send: function() {
    var that = this;
    var value = $.trim(this.field.val());
    if (!value || !/^([^@\s]+)@((?:[-A-Za-z0-9]+\.)+[a-z]{2,})$/.test(value)) {
        this.showError('Введите правильный адрес электронной почты.');
        return false;
    }
    if (!this.like) {
        this.like = $('<div class="rs-like"></div>').hide().insertAfter(that.el);
        this.like.html('<iframe src="//www.facebook.com/plugins/like.php?href=http%3A%2F%2Fwww.facebook.com%2Feviterra&amp;send=false&amp;layout=button_count&amp;width=400&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:450px; height:21px;" allowTransparency="true"></iframe>');    
    }
    this.button.get(0).disabled = true;
    this.error.hide();
    $.ajax({
        url: '/subscribe/',
        data: {
            destination_id: this.el.attr('data-destination'),
            from_iata: this.el.attr('data-from-iata'),
            to_iata: this.el.attr('data-to-iata'),
            rt: this.el.attr('data-rt'),
            email: value
        },
        success: function(s) {
            that.process(s);
        },
        error: function() {
            that.showError();
        },
        timeout: 30000
    });
},
process: function(s) {
    if (s && s.success) {
        this.el.hide();
        this.el.after('<div class="rs-success">Спасибо, подписка создана. Отписаться можно будет по ссылке в письме.</div>');
        this.like.show();
    } else {
        this.error();
    }
},
showError: function(text) {
    this.button.get(0).disabled = false;
    this.error.html(text || 'Не удалось подписаться, попробуйте ещё раз.').show();
}
};
