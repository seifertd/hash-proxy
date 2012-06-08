hash-proxy
===========

An object that proxies method calls to a Hash object as hash key lookups.
Handles nested hashes and arrays.

Features
--------

* Treat Hash as an object

Examples
--------

    require 'hash-proxy'
    hash = {foo: 'bar', baz: [{key: 'value', key2: 2, key3: [1,2,3]}, {key: 'value2', key2: 22, key3: [4,5,6]}], bip: 'bop'}
    proxy = HashProxy::Proxy.new(hash)
    proxy.baz.key3.should == [4,5,6]

Requirements
------------

* No dependencies

Install
-------

* gem install hash-proxy

Motivation
----------

Used to wrap responses from JSON returning web services to avoid having to write
a bunch of useless objects that have to be updated constantly to match changes and/or
mistakes in the API.

Author
------

Original author: Douglas A. Seifert (doug@dseifert.net)

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
