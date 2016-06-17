#!/usr/bin/env python
# encoding: utf-8
"""
yolk2.py

A simple replacement for yolk that works with all versions of Python.

https://pypi.python.org/pypi/yolk

The MIT License (MIT)

Copyright (c) 2011-2016 Dale Davis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""
try:
    import xmlrpc.client as xmlrpclib
except ImportError:
    import xmlrpclib
import pip

pypi = xmlrpclib.ServerProxy('https://pypi.python.org/pypi')
for dist in pip.get_installed_distributions():
    available = pypi.package_releases(dist.project_name)
    if not available:
        # Try to capitalize pkg name
        available = pypi.package_releases(dist.project_name.capitalize())

    if not available:
        msg = 'no releases at pypi'
    elif available[0] != dist.version:
        msg = '{} available'.format(available[0])
    else:
        msg = 'up to date'
    pkg_info = '{dist.project_name} {dist.version}'.format(dist=dist)
    print('{pkg_info:40} {msg}'.format(pkg_info=pkg_info, msg=msg))
