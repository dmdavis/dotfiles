#!/usr/bin/env python
# encoding: utf-8
"""
intellij-symlinks.py

Configure Intellij symlinks.

Copyright (c) 2016 Dale Davis. All rights reserved.
"""
import sys
try:
    from plumbum import local, colors
except ImportError:
    print("intellij-symlinks.py requires plumbum")
    sys.exit(1)


def link(source, target):
    """Symlink the specified directory."""
    if target.exists():
        if target.is_symlink():
            return
        print(colors.warn | "Deleting " + target)
        target.delete()
    source.symlink(target)
    print(colors.info | "Symlinking " + source + " to " + target)


JETBRAINS_IDE_FOLDERS = (
    'AppCode2016.1',
    'CLion2016.1',
    'DataGrip2016.1',
    'IntelliJIdea2016.1',
    'PyCharm2016.2',
    'PhpStorm2016.1',
    'RubyMine2016.1',
    'WebStorm2016.2',
)


def main():  # pragma: no cover
    """
    Main method for intellij-symlinks.py

    """
    home = local.env.home
    dbjb = home / 'Dropbox/Jetbrains'
    libp = home / 'Library/Preferences'
    for d in libp:
        if d.is_dir() and d.endswith(JETBRAINS_IDE_FOLDERS):
            for f in ('colors', 'codestyles', 'keymaps', 'templates'):
                link(dbjb / f, d / f)
    return 0

if __name__ == '__main__':  # pragma: no cover
    sys.exit(main())
