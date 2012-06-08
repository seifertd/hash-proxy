
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
    proxy.should_not_receive(:convert_value)
  end

  it "should convert values if they are referenced" do
    hash = {foo: 'bar', baz: 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    proxy.should_receive(:convert_value).once.with('bar').and_return('bar')
    proxy.foo.should eq('bar')
  end

end
