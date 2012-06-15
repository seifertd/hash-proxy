
require File.expand_path('../spec_helper', __FILE__)

describe HashProxy do

  it "handles booleans" do
    proxy = HashProxy.create_from(:indexed => false, :followed => true)
    proxy[:indexed].should == false
    proxy[:followed].should == true
  end

  it "does not get confused by methods defined on Kernel" do
    proxy = HashProxy::Proxy.new({})
    lambda { proxy[:format] }.should_not raise_error
    proxy[:format].should be_nil
  end

  it "supports enumerable" do
    hash = {foo: 'bar', baz: 'bip', smee: 'cree'}
    proxy = HashProxy::Proxy.new(hash)
    iterator = proxy.each
    iterator.to_a.should eq([[:foo, 'bar'], [:baz, 'bip'], [:smee, 'cree']])

    proxy.take(1).should eq([[:foo, 'bar']])
  end

  it "behaves kind of like a hash" do
    hash = {foo: 'bar', baz: 'bip', smee: 'cree'}
    proxy = HashProxy::Proxy.new(hash)
    proxy.size.should eq(3)
    proxy.each.to_a.size.should eq(3)
    proxy.each.to_a.map{|a| a.first}.should eq([:foo, :baz, :smee])
    proxy.each.to_a.map{|a| a.last}.should eq(['bar', 'bip', 'cree'])
    proxy[:foo].should eq('bar')
  end

  it "can call setters" do
    proxy = HashProxy::Proxy.new({})
    proxy.foo = 'foo val'
    proxy.bar = {:bip => :baz, :smoo => :smee}

    proxy.size.should eq(2)
    proxy[:bar].class.should eq(HashProxy::Proxy)
  end

  it "handles crappy method calls" do
    proxy = HashProxy::Proxy.new({})
    lambda { proxy.send(:'=', 'crap') }.should raise_error(NoMethodError)
  end

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
