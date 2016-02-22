#!/usr/bin/env python
# encoding: utf-8
"""
dash.py

Look up a term in Dash.

Copyright (c) 2016 Dale Davis. All rights reserved.
"""
import os
import sys
from six import moves


def main():  # pragma: no cover
    """
    Main method for dash.py

    """
    args = moves.quote_plus(' '.join(sys.argv[1:]).strip())
    cl = 'open dash://%s' % args
    os.system(cl)
    return 0


if __name__ == '__main__':  # pragma: no cover
    sys.exit(main())