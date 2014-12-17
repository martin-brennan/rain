require 'spec_helper'

describe Rain::Doc do

  before do
    @doc = Rain::Doc.new("basic_md.md", File.read(Dir.pwd + '/spec/spec_source_files/basic_md.md'))
  end

  it "should initialize with a rain parser" do
    expect(@doc.parser.kind_of? Rain::Parser).to eq true
  end

  it "should set the doc's title to the file name by default, replacing underscores and proper casing" do
    expect(@doc.title).to eq "Basic Md"
  end

  it "should need a file name and contents to initialize" do
    expect(@doc.file_name).to eq "basic_md.md"
    expect(@doc.file_contents).to eq "# Basic Markdown Test\nThis is a _basic_ **markdown** test doc."
  end

  it "should store the type of file it is parsing for later checks" do
    expect(@doc.file_ext).to eq ".md"
    expect(@doc.type).to eq :MARKDOWN
    doc = Rain::Doc.new("basic_rb.rb", File.read(Dir.pwd + '/spec/spec_source_files/basic_rb.rb'))
    expect(doc.file_ext).to eq ".rb"
    expect(doc.type).to eq :RUBY
  end

  it "should store multiple doc parts for the file, and store the current doc part" do
    expect(@doc.parts.length).to eq 0
  end

  it "should set the current doc part and add the old one to the parts array" do
    @doc.current_part = Rain::DocPart.new
    @doc.new_part
    expect(@doc.parts.length).to eq 1
    expect(@doc.current_part.kind_of? Rain::DocPart).to eq true
  end

  it "should loop through each line of the file, using the parser to analyse each" do
    @doc.parse
    expect(@doc.parts.length).to eq 1
    expect(@doc.lines).to eq 2
  end

  it "should convert the doc class into a hash for templating" do
    @doc.parse
    h = @doc.to_hash
    expect(h[:parts].length).to eq 1
  end

end