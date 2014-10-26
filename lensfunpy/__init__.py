from __future__ import absolute_import

from ._version import __version__, __version_info__

import os, sys

import lensfunpy._lensfun
globals().update(lensfunpy._lensfun.__dict__)

# for Windows and Mac we wrap the Database constructor to load the bundled database files
# as lensfun wouldn't find any in the standard search locations like on Linux
if os.name == 'nt' or sys.platform == 'darwin':
    _Database = Database
    del Database
    
    from functools import wraps
    import glob
    
    _ROOT = os.path.abspath(os.path.dirname(__file__))
    _xml_glob = os.path.join(_ROOT, 'db_files', '*.xml')
    
    @wraps(_Database)
    def Database(filenames=None, xml=None, load_all=True):
        if load_all:
            if not filenames:
                filenames = []
            filenames.extend(glob.glob(_xml_glob))
        return _Database(filenames, xml, load_all)
    