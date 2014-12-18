require 'spec_helper'

describe Rain::Parser do

  before do
    @parser = Rain::Parser.new(:RUBY)
  end

  it "should initialize knowing what type of file it is parsing" do
    expect(@parser.type).to eq :RUBY
  end

  it "should begin to parse a single line" do
    @parser.parse("    # this is the current line ")
  end

  it "strips the line and if ruby removes the # from the start of the line" do
    result = @parser.strip_current_line("    # this is the current line ")
    expect(result).to eq "this is the current line"
  end

  it "should determine if the current line has a title tag" do
    expect(@parser.is_title?("{title Page Title}")).to eq true
  end

  it "should extract the title from the tag" do
    expect(@parser.extract_title("{title Page Title}")).to eq 'Page Title'
  end

  it "should return the title based on the tag passed in" do
    result = @parser.parse("    # {title Page Title} ")

    expect(result[:title]).to eq "Page Title"
  end

  it "should determine if the current line has a method tag" do
    expect(@parser.is_method?("{method GET}")).to eq true
  end

  it "should extract the method from the tag" do
    expect(@parser.extract_method("{method GET}")).to eq 'GET'
  end

  it "should return the method based on the tag passed in" do
    result = @parser.parse("    # {method GET} ")

    expect(result[:method]).to eq "GET"
  end

  it "should determine if the current line has a route tag" do
    expect(@parser.is_route?("{route /person/:id/contacts}")).to eq true
  end

  it "should extract the route from the tag" do
    expect(@parser.extract_route("{route /person/:id/contacts}")).to eq '/person/:id/contacts'
  end

  it "should return the route based on the tag passed in" do
    result = @parser.parse("    # {route /person/:id/contacts} ")

    expect(result[:route]).to eq "/person/:id/contacts"
  end

  it "should determine if the current line has a response tag" do
    expect(@parser.is_response?("{response 200 ok}")).to eq true
    expect(@parser.is_response?("{/response}")).to eq true
  end

  it "should get the response status code" do
    expect(@parser.extract_response_code("{response 404 badrequest}")).to eq '404'
  end

  it "should return the response tag and whether it is open or closed" do
    result = @parser.parse("  # {response 404 badrequest} ")
    expect(result[:code]).to eq "404"
    expect(result[:id]).to eq "badrequest"
    expect(result[:open]).to eq true
  end

  it "should extract a simple doc line. doc lines do not fit any of the tags" do
    result = @parser.parse(" # simple doc line ")
    expect(result[:text]).to eq "simple doc line"
  end

  it "should determine if the current line has a param tag" do
    expect(@parser.is_param?("{param id integer}")).to eq true
    expect(@parser.is_param?("{/param}")).to eq true
  end

  it "should get the param name" do
    expect(@parser.extract_param_name("{param limit integer 200}")).to eq 'limit'
  end

  it "should get the param type" do
    expect(@parser.extract_param_type("{param limit integer}")).to eq 'integer'
  end

  it "should get the param default" do
    expect(@parser.extract_param_default("{param limit integer 200}")).to eq '200'
  end

  it "should return the param tag and whether it is open or closed" do
    result = @parser.parse("  # {param id integer 100} ")
    expect(result[:name]).to eq "id"
    expect(result[:type]).to eq "integer"
    expect(result[:default]).to eq "100"
  end

  it "should return nil if the current line has no documentation" do
    expect(@parser.parse("   ")).to eq nil
  end

  it "should return the signature if the line with no documentation starts with def, get, put, post or delete" do
    expect(@parser.parse("def html_out(rendered)", true)).to eq({ tag: :signature, text: "def html_out(rendered)" })
  end
end