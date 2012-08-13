hash-proxy
===========

An object that proxies method calls to a Hash object as hash key lookups.
Handles nested hashes and arrays.

Features
--------

* Treat Hash as an object
* Lazily turns nested Hash objects into proxies as they are referenced
* TODO: Lazily turn array elements into proxies.  Currently, if an array
  is referenced, all of it's elements that are Hashes are turned into
  proxies and what's worse, if the Array contains sub-arrays, all the
  nested sub Array objects recursively have their own elements converted
  to proxies.  This can have bad performance implications:

          h = {:foo => [{:key1 => 'val1'}, {:key1 => 'val2'}, ... MANY MORE ..., {:key1 => 'val2'}]}
          p = HashProxy.create_from(h)
          # Even though we only look at the first two objects in the Array,
          # we silently convert all of the Array's contained Hash objects to
          # HashProxy::Proxy instances just by referencing the foo key.
          p.foo[0..1]

Examples
--------

    require 'hash_proxy'
    hash = {foo: 'bar', baz: [{key: 'value', key2: 2, key3: [1,2,3]}, {key: 'value2', key2: 22, key3: [4,5,6]}], bip: 'bop'}
    proxy = HashProxy.create_from(hash)
    proxy.baz.last.key3.should == [4,5,6]

Also supports hash like semantics:

    proxy[:foo]    => 'bar'
    proxy[:newkey] = 'new value'

    proxy.each do |k, v|
      puts "#{k}: #{v}"
    end

Limitations
-----------

Because it mixes in Enumerable, the Proxy class doesn't play nice with keys whose names correspond to
methods on Enumerable.  The work around: for keys that are methods on Enumerable, use the hash accessor
instead of the method call notation:

    proxy = HashProxy.create_from(:size => 42)
    proxy.size    => 1 (the number of key-value pairs in the proxied Hash)
    proxy[:size]  => 42 (the value pointed to by the :size key)

Requirements
------------

* No runtime dependencies
* To build and test, run bundle install after cloning from github

Install
-------

* gem install hash-proxy

Source
------

https://github.com/seifertd/hash-proxy

Motivation
----------

Used to wrap responses from JSON returning web services to avoid having to write
a bunch of useless objects that have to be updated constantly to match changes and/or
mistakes in the API.

Author
------

Original author: Douglas A. Seifert (doug@dseifert.net)

History
-------

### Version 0.1.3 / 2012-08-13
* Support to_ary method on NullObject

### Version 0.1.2 / 2012-06-15
* Fix bug with hashes with false as a value

### Version 0.1.1 / 2012-06-12
* Work around weird behavior when using [] method
  to access keys which are methods defined on Kernel,
  like Kernel#format. TODO: inherit from BasicObject to
  avoid this?

### Version 0.1.0 / 2012-06-12
  * include Enumerable in Proxy
  * Add some hash-like semantics to Proxy

### Version 0.0.4 / 2012-06-08
  * Add #to_str to NullObject to avoid some rspec errors

### Version 0.0.3 / 2012-06-08
  * Fix homepage in gemspec

### Version 0.0.2 / 2012-06-08
  * Convert to yard doc for "rake doc" task.
  * Handle respond_to? in a sensible fashion.

### Version 0.0.1 / 2012-06-07
  * First release of hash-proxy
  * Handle respond_to? in a sensible fashion.

License
-------

(The MIT License)

Copyright (c) 2012 Douglas A. Seifert

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
