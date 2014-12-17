require 'spec_helper'

describe Rain::DocPart do

  before do
    @part = Rain::DocPart.new
  end

  it "initializes with the required defaults for method, responses, doc, route, params & headers" do
    expect(@part.http_method).to eq nil
    expect(@part.responses).to eq []
    expect(@part.doc).to eq []
    expect(@part.route).to eq '//'
    expect(@part.params).to eq []
    expect(@part.headers).to eq []
  end

  # checks to see if multiple response blocks for
  # the same code can be added
  it "can append lines to the specified response code, creating the code array if null" do
    @part.append_response(200, 'success', '{')
    @part.append_response(200, 'success_create', 'hello')

    expect(@part.get_response(200, 'success')).to eq '{'
    expect(@part.get_response(200, 'success_create')).to eq 'hello'
  end

  it "should only allow response codes that are numbers" do
    expect{ @part.append_response('af') }.to raise_error(ArgumentError)
  end

  it "should set the http method" do
    @part.set_method(:GET)
    expect(@part.http_method).to eq :GET
  end

  it "should only allow valid HTTP methods" do
    expect{ @part.set_method(:FOO) }.to raise_error(ArgumentError)
  end

  it "should append documentation that is untagged" do
    @part.append_doc("this route is great it returns a user")
    @part.append_doc("also id")
    expect(@part.get_doc).to eq "this route is great it returns a user also id"
  end

  it "should set and get the route" do
    @part.set_route('/person/:id')
    expect(@part.get_route).to eq '/person/:id'
  end

  it "should add a parameter of each type" do
    @part.append_param('id', 'This is a parameter', 'integer')
    expect(@part.get_param('id')[:type]).to eq 'integer'
    expect(@part.get_param('id')[:text]).to eq 'This is a parameter'
    expect(@part.get_param('name')).to eq nil
  end

  it "should add a parameter with a default value" do
    @part.append_param('length', 'This is a parameter with a default value', 'integer', 10)
    expect(@part.get_param('length')[:default]).to eq 10
  end

  it "should add a HTTP header" do
    @part.append_header('X-Custom-Header', 'This is a custom header.')
    expect(@part.get_header('X-Custom-Header')).to eq 'This is a custom header.'
  end

  it "should convert the doc part into a hash" do
    @part.append_doc("this route is great it returns a user")
    @part.append_doc("also id")
    
    h = @part.to_hash

    expect(h[:doc].length).to eq 2
  end
end