
require File.expand_path('../spec_helper', __FILE__)

describe HashProxy do
  it "turns hash keys into method calls" do
    hash = {foo: 'bar', baz: 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    proxy.foo.should eq('bar')
    proxy.baz.should eq('bip')
  end

  it "handles nested hashes" do
    hash = {foo: {bar: 'barvalue', baz: 'bazvalue'}, bip: 'bipvalue'}
    proxy = HashProxy::Proxy.new(hash)
    proxy.foo.bar.should eq('barvalue')
    proxy.foo.baz.should eq('bazvalue')
    proxy.bip.should eq('bipvalue')
  end

  it "handles string keys" do
    hash = {'foo' => 'bar', 'baz' => 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    proxy.foo.should eq('bar')
    proxy.baz.should eq('bip')
  end

  it "handles simple arrays" do
    hash = {'foo' => 'bar', 'arr1' => [1,2,3], 'baz' => 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    proxy.arr1.should eq([1,2,3])
  end

  it "handles complicated arrays" do
    hash = {'foo' => 'bar', 'arr1' => [{'subkey' => 'subkeyval', 'more' => 'moreval'}, 3, {'subkey' => 'subkeyval2', 'more' => 'moreval2'}], 'baz' => 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    proxy.arr1.first.subkey.should eq('subkeyval')
    proxy.arr1.last.subkey.should eq('subkeyval2')
    proxy.arr1[1].should eq(3)
  end

  it "should not convert values if nothing is referenced" do
    hash = {'foo' => 'bar', 'arr1' => [1,2,3], 'baz' => 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    HashProxy::Proxy.should_not_receive(:convert_value)
    proxy.to_s
  end

  it "should convert values if they are referenced" do
    hash = {foo: 'bar', baz: 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    proxy.should_receive(:convert_value).once.with('bar').and_return('bar')
    proxy.foo.should eq('bar')
  end

  it "can be created using the factory method" do
    hash = {foo: 'bar', baz: 'bip'}
    proxy = HashProxy.create_from(hash)
    proxy.foo.should eq('bar')
  end

  it "handles keys that do not exist" do
    hash = {foo: 'bar', baz: 'bip'}
    proxy = HashProxy.create_from(hash)
    proxy.key.does.not.exist.to_s.should eq('')
    proxy.key.does.not.exist.nil?.should eq(true)
    proxy.key.does.not.exist.blank?.should eq(true)
    proxy.key.does.not.exist.empty?.should eq(true)
    proxy.key.does.not.exist.to_a.should eq([])
  end

  # TODO: Am I itching badly enough to make this pass? ....
  #it "should lazily handle nested arrays" do
  #  hash = {:foo => [{:key1 => 'val11', :key2 => 'val12'}, {:key1 => 'val21', :key2 => 'val22'}], :bar => :baz}
  #  proxy = HashProxy.create_from(hash)
  #  proxy.foo.should eq([{:key1 => 'val11', :key2 => 'val12'}, {:key1 => 'val21', :key2 => 'val22'}])
  #end

end
