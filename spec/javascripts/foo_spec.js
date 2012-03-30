// open /evergreen in your browser!

describe('foo', function() {

  require('/assets/foo.js')

  it("should be == 'foo'", function() {
    expect( foo() ).toEqual('foo')
  })

})


describe('jquery and dom', function() {

  require('/assets/jquery.js')
  template('foo.html')

  it("should fetch content of span using jquery", function() {
    expect( $('#inner').text() ).toEqual('hey')
  })
})
