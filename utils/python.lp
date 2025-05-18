% ==============================================================================
% CASPER version v1.0.0
% Author: Yvon K. Awuklu
% Description: Clingo, python embedded utility functions for CASPER
% ==============================================================================

#script (python)

import time
from clingo import Control, Number
import itertools
import hashlib

# Global generator with default start at 1
_gen = itertools.count(1)
_used_ids = set()

def get_id(*args):
    """Returns a unique identifier based on arguments.
    
    Args:
        *args: Components that should uniquely identify the event
               (e.g., N, P, E, T1, T2)
               
    Returns:
        Number: A unique numeric ID that's consistent for same inputs
    """
    global _gen, _used_ids
    
    # Create a hash-based ID if arguments are provided
    if args:
        # Create a consistent string representation
        arg_str = "|".join(str(arg) for arg in args)
        # Generate hash (using first 8 digits for reasonable size)
        hash_id = int(hashlib.sha1(arg_str.encode()).hexdigest()[:8], 16)
        
        # Ensure it's positive and hasn't been used by the counter
        hash_id = hash_id % (10**8)  # Keep to 8 digits max
        while hash_id in _used_ids:
            hash_id = (hash_id + 1) % (10**8)
            
        _used_ids.add(hash_id)
        return Number(hash_id)
    
    # Fall back to counter if no args provided
    new_id = next(_gen)
    _used_ids.add(new_id)
    return Number(new_id)

def ongoing_time():
    """Returns the current time."""
    return Number(int(time.time() + 43200))

def convert_time_to_date(time):
    return time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time))

#end.

