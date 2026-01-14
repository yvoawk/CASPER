% ==============================================================================
% CASPER version v1.0.2
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

def get_shift(unit='seconds'):
    """
    Returns the value of a 12-hour shift, converted to the specified unit.
    """

    unit = str(unit).strip().lower()

    seconds_in_unit = {
        'seconds': 1,
        'minutes': 60,
        'hours': 3600,
        'days': 86400
    }

    if unit not in seconds_in_unit:
        raise ValueError(f"Invalid unit '{unit}'. Choose from: seconds, minutes, hours, days.")

    # 12 hours in seconds, then convert to the desired unit
    twelve_hours_in_seconds = 12 * 3600
    shift_in_unit = twelve_hours_in_seconds / seconds_in_unit[unit]

    return Number(int(shift_in_unit))

def ongoing_time(unit='seconds'):
    """
    Returns the current time shifted by 12 hours, converted to the specified unit,
    and wrapped in a Number object.

    Parameters:
    - unit (str): 'seconds', 'minutes', 'hours', or 'days'

    Returns:
    - Number: current time + 12h, expressed in the given unit (rounded down)
    """
    unit = str(unit).strip().lower()

    seconds_in_unit = {
        'seconds': 1,
        'minutes': 60,
        'hours': 3600,
        'days': 86400
    }

    now_seconds = time.time()
    now_in_unit = now_seconds / seconds_in_unit[unit]
    shift = get_shift(unit).number

    return Number(int(now_in_unit + shift))

#end.

