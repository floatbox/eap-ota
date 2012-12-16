describe('russian i18n', function() {

  require('/assets/i18n_init')

  // зависит от порядка, к сожалению.
  it("should translate russian messages with default locale", function() {
    expect( I18n.t('errors.messages.equal_to', {count: 5}) )
      .toEqual('может иметь лишь значение, равное 5')
  })

  it("should translate russian messages", function() {
    I18n.locale = 'ru'
    expect( I18n.t('errors.messages.equal_to', {count: 5}) )
      .toEqual('может иметь лишь значение, равное 5')
  })

  it("should translate english messages", function() {
    I18n.locale = 'en'
    expect( I18n.t('errors.messages.equal_to', {count: 5}) )
      .toEqual('must be equal to 5')
  })

  describe('pluralization', function() {

    beforeEach(function() {
      I18n.locale = 'ru'
    })

    it("should pluralize russian messages for count 2", function() {
      expect( I18n.t('errors.messages.too_long', {count: 2}) )
        .toEqual('слишком большой длины (не может быть больше чем 2 символа)')
    })

    it("should pluralize russian messages for count 0", function() {
      expect( I18n.t('errors.messages.too_long', {count: 0}) )
        .toEqual('слишком большой длины (не может быть больше чем 0 символов)')
    })

    it("should pluralize russian messages for count 21", function() {
      expect( I18n.t('errors.messages.too_long', {count: 21}) )
        .toEqual('слишком большой длины (не может быть больше чем 21 символ)')
    })

    it("should pluralize russian messages using scope", function() {
      expect( I18n.t('too_long', {scope: 'errors.messages', count: 2}) )
        .toEqual('слишком большой длины (не может быть больше чем 2 символа)')
    })

  })

})
