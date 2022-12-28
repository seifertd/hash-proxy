
require File.expand_path('../spec_helper', __FILE__)

describe HashProxy do
  it "can be serialized and deserialized" do
    proxy = HashProxy.create_from(:size => 42, :bar => :foo)
    data = Marshal.dump(proxy)
    proxy2 = Marshal.load(data)
    expect(proxy.keys).to eq(proxy2.keys)
    expect(proxy.values).to eq(proxy2.values)
  end

  it "works with null values" do
    proxy = HashProxy.create_from(:null => nil)
    expect(proxy.size).to eq(1)
    expect(proxy.null).to be_nil
    expect(proxy.null.class).to eq(HashProxy::NullObject)
    expect(proxy.null.to_a).to eq([])
    expect(proxy.null.to_ary).to eq([])
  end

  it "works with keys called size" do
    proxy = HashProxy.create_from(:size => 42, :bar => :foo)
    expect(proxy.size).to eq(2)
    expect(proxy[:size]).to eq(42)
  end


  it "handles booleans" do
    proxy = HashProxy.create_from(:indexed => false, :followed => true)
    expect(proxy.indexed).to eq(false)
    expect(proxy.followed).to eq(true)
  end

  it "does not get confused by methods defined on Kernel" do
    proxy = HashProxy::Proxy.new({})
    expect{proxy[:format]}.to_not raise_error
    expect(proxy.format).to be_nil
  end

  it "supports enumerable" do
    hash = {foo: 'bar', baz: 'bip', smee: 'cree'}
    proxy = HashProxy::Proxy.new(hash)
    iterator = proxy.each
    expect(iterator.to_a).to eq([[:foo, 'bar'], [:baz, 'bip'], [:smee, 'cree']])

    expect(proxy.take(1)).to eq([[:foo, 'bar']])
  end

  it "behaves kind of like a hash" do
    hash = {foo: 'bar', baz: 'bip', smee: 'cree'}
    proxy = HashProxy::Proxy.new(hash)
    expect(proxy.size).to eq(3)
    expect(proxy.each.to_a.size).to eq(3)
    expect(proxy.each.to_a.map{|a| a.first}).to eq([:foo, :baz, :smee])
    expect(proxy.each.to_a.map{|a| a.last}).to eq(['bar', 'bip', 'cree'])
    expect(proxy[:foo]).to eq('bar')
  end

  it "can call setters" do
    proxy = HashProxy::Proxy.new({})
    proxy.foo = 'foo val'
    proxy.bar = {:bip => :baz, :smoo => :smee}

    expect(proxy.size).to eq(2)
    expect(proxy[:bar].class).to eq(HashProxy::Proxy)
  end

  it "handles crappy method calls" do
    proxy = HashProxy::Proxy.new({})
    expect do
      proxy.send(:'=', 'crap')
    end.to raise_error(NoMethodError)
  end

  it "turns hash keys into method calls" do
    hash = {foo: 'bar', baz: 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    expect(proxy.foo).to eq('bar')
    expect(proxy.baz).to eq('bip')
  end

  it "handles nested hashes" do
    hash = {foo: {bar: 'barvalue', baz: 'bazvalue'}, bip: 'bipvalue'}
    proxy = HashProxy::Proxy.new(hash)
    expect(proxy.foo.bar).to eq('barvalue')
    expect(proxy.foo.baz).to eq('bazvalue')
    expect(proxy.bip).to eq('bipvalue')
  end

  it "handles string keys" do
    hash = {'foo' => 'bar', 'baz' => 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    expect(proxy.foo).to eq('bar')
    expect(proxy.baz).to eq('bip')
  end

  it "handles simple arrays" do
    hash = {'foo' => 'bar', 'arr1' => [1,2,3], 'baz' => 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    expect(proxy.arr1).to eq([1,2,3])
  end

  it "handles complicated arrays" do
    hash = {'foo' => 'bar', 'arr1' => [{'subkey' => 'subkeyval', 'more' => 'moreval'}, 3, {'subkey' => 'subkeyval2', 'more' => 'moreval2'}], 'baz' => 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    expect(proxy.arr1.first.subkey).to eq('subkeyval')
    expect(proxy.arr1.last.subkey).to eq('subkeyval2')
    expect(proxy.arr1[1]).to eq(3)
  end

  it "should not convert values if nothing is referenced" do
    hash = {'foo' => 'bar', 'arr1' => [1,2,3], 'baz' => 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    expect(HashProxy::Proxy).to_not receive(:convert_value)
    proxy.to_s
  end

  it "should convert values if they are referenced" do
    hash = {foo: 'bar', baz: 'bip'}
    proxy = HashProxy::Proxy.new(hash)
    expect(proxy).to receive(:convert_value).once.with('bar').and_return('bar')
    expect(proxy.foo).to eq('bar')
  end

  it "can be created using the factory method" do
    hash = {foo: 'bar', baz: 'bip'}
    proxy = HashProxy.create_from(hash)
    expect(proxy.foo).to eq('bar')
  end

  it "handles keys that do not exist" do
    hash = {foo: 'bar', baz: 'bip'}
    proxy = HashProxy.create_from(hash)
    expect(proxy.key.does.not.exist.to_s).to eq('')
    expect(proxy.key.does.not.exist.nil?).to eq(true)
    expect(proxy.key.does.not.exist.blank?).to eq(true)
    expect(proxy.key.does.not.exist.empty?).to eq(true)
    expect(proxy.key.does.not.exist.to_a).to eq([])
  end

  describe "json conversion" do
    it "should work when no keys are converted" do
      hash = {foo: 'bar', baz: {subkey: 'sub1', subkey2: 'sub2'}}
      proxy = HashProxy.create_from hash
      expect(proxy.to_json).to eq(hash.to_json)
    end
    it "should work when normal value has been converted" do
      orig = {foo: 'bar', baz: {subkey: 'sub1', subkey2: 'sub2'}}
      hash = Marshal.load(Marshal.dump(orig))
      proxy = HashProxy.create_from hash
      expect(proxy.foo).to eq('bar')
      # Need to parse back to ruby arrays so we can use the ruby == operator
      # to compare
      expect(JSON.parse(proxy.to_json)).to eq(JSON.parse(orig.to_json))
    end
    it "should work when nested value has been converted" do
      orig = {foo: 'bar', baz: {subkey: 'sub1', subkey2: 'sub2'}}
      hash = Marshal.load(Marshal.dump(orig))
      proxy = HashProxy.create_from hash
      proxy.baz.each do |key, val|
        expect(orig[:baz][key]).to eq(val)
      end
      # Need to parse back to ruby arrays so we can use the ruby == operator
      # to compare
      expect(JSON.parse(proxy.to_json)).to eq(JSON.parse(orig.to_json))
    end
  end

  # TODO: Am I itching badly enough to make this pass? ....
  #it "should lazily handle nested arrays" do
  #  hash = {:foo => [{:key1 => 'val11', :key2 => 'val12'}, {:key1 => 'val21', :key2 => 'val22'}], :bar => :baz}
  #  proxy = HashProxy.create_from(hash)
  #  proxy.foo.should eq([{:key1 => 'val11', :key2 => 'val12'}, {:key1 => 'val21', :key2 => 'val22'}])
  #end

end
