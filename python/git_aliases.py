#!/usr/bin/env python
# encoding: utf-8
"""
git_aliases.py

Custom thefuck rules for prezto and custom git aliases.

Copyright (c) 2016 Dale Davis. All rights reserved.
"""


def match(command):
    return 'gbx' in command.script


def get_new_command(command):
    return command.script.replace("gbx", "gbX", 1)

# Optional:
requires_output = True
enabled_by_default = True
priority = 1000  # Lower first, default is 1000
