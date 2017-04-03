#!/usr/bin/env python
# encoding: utf-8
"""
IntelliJ Dropbox Shared File Symbolic Linker

This program creates symlinks from the Preferences folders of various IntelliJ
IDE's to a shared directory on Dropbox. This allows settings to be shared
without having to resort to the buggy Settings Repository plugin.

Usage:
    intellij-symlinks
    intellij-symlinks (-d | --dry-run)

Options:
    -h --help       Show this screen
    -d --dry-run    Execute and log, but don't make any actual changes
"""
import sys
try:
    # noinspection PyUnresolvedReferences
    from plumbum import local, colors
except ImportError:
    print("intellij-symlinks.py requires plumbum")
    sys.exit(1)
try:
    # noinspection PyUnresolvedReferences
    from docopt import docopt
except ImportError:
    print('intellij-symlinks requires docopt')
    sys.exit(1)

__author__ = "Dale Davis"
__copyright__ = "Copyright (c) 2016 Dale Davis. All rights reserved."
__credits__ = ["Dale Davis", ]
__license__ = "BSD-2-Clause"
__version_info__ = (1, 0)
__version__ = '.'.join([str(v) for v in __version_info__])
__maintainer__ = "Dale Davis"
__email__ = "dmdavis.net@gmail.com"
__status__ = "Production"


def link(source, target, dry_run):
    """Symlink the specified directory."""
    if target.exists():
        if target.is_symlink():
            # noinspection PyUnresolvedReferences
            print(colors.warn | "Unlinking existing " + target)
            if not dry_run:
                target.unlink()
        else:
            # noinspection PyUnresolvedReferences
            print(colors.warn | "Deleting existing " + target)
            if not dry_run:
                target.delete()
    if not dry_run:
        source.symlink(target)
    # noinspection PyUnresolvedReferences
    print(colors.info | "Symlinking " + source + " to " + target)


JETBRAINS_IDE_FOLDERS = (
    'AppCode2017.1',
    'CLion2017.1',
    'DataGrip2017.1',
    'IntelliJIdea2017.1',
    'PyCharm2017.1',
    'PhpStorm2017.1',
    'RubyMine2017.1',
    'WebStorm2017.1',
)

TEMPLATE_FOLDERS = dict(zip(JETBRAINS_IDE_FOLDERS, (
    'appcode',
    'clion',
    'datagrip',
    'idea',
    'pycharm',
    'phpstorm',
    'rubymine',
    'webstorm'
)))


def main():  # pragma: no cover
    """
    Main method for intellij-symlinks.py

    """
    arguments = docopt(__doc__, version='intellij-symlinks {0}'
                       .format(__version__))
    dry_run = arguments['--dry-run']
    home = local.env.home
    dbjb = home / 'Dropbox/Jetbrains'
    libp = home / 'Library/Preferences'
    for d in libp:
        if d.is_dir():
            i = 0
            for f in JETBRAINS_IDE_FOLDERS:
                if d.endswith(f):
                    templates = 'templates/{0}'.format(TEMPLATE_FOLDERS[f])
                    for g in ('colors', 'codestyles', 'keymaps', 'templates'):
                        link(dbjb / (templates if g == 'templates' else g),
                             d / g,
                             dry_run)
                    continue
                i += 1
    if dry_run:
        # noinspection PyUnresolvedReferences
        print(colors.green | 'Dry run. No directories changes.')
    return 0

if __name__ == '__main__':  # pragma: no cover
    sys.exit(main())
