booking.form.process = function(s) {
    this.footer.hide();
    this.footer.find('.bff-progress').hide();
    this.button.removeClass('bfb-sending');
    var that = this;
    this.result = $(s).insertAfter(this.el);
    var back = this.result.find('.bfr-back');
    if (back.length) {  
        this.back = true;
        back.click(function() {
            that.result.hide();
            that.footer.show();
            delete that.back;
        });
    }
};