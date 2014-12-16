require 'spec_helper'

describe "basic ruby output from the doc parser" do
  @@doc = Rain::Doc.new("basic_rb.rb", File.read(Dir.pwd + '/spec/spec_source_files/basic_rb.rb'), true)
  @@doc.parse

  it "has the correct title" do
    expect(@@doc.title).to eq "Person Routes"
  end

  it "has 1 doc parts" do
    expect(@@doc.parts.length).to eq 1
  end

  it "has the correct method, route" do
    expect(@@doc.parts[0].http_method).to eq "GET"
    expect(@@doc.parts[0].route).to eq "/person/:id"
  end

  it "has one param without a default value" do
    params = @@doc.parts[0].params

    expect(params[0][:name]).to eq "id"
    expect(params[0][:type]).to eq "integer"
  end

  it "has one 200 status response" do
    responses = @@doc.parts[0].responses

    expect(responses[200][:ok].join(' ')).to eq "{ id: 1, name: 'John Smith', age: 22 }"
  end
end