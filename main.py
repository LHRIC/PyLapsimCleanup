#!/usr/bin/env python3
import yaml

import os, sys;
sys.path.insert(0, __file__.rsplit(os.sep,3)[0])

from yaml_prop import PropertyLoader

# %%
def main():
    MODULE_PATH = __file__.rsplit(os.sep,1)[0]
    with open(os.path.join(MODULE_PATH, 'vehicle_params.yml'), 'r') as file:
        data = yaml.load_all(file, Loader=PropertyLoader)
        for doc in data:
            for subsys in doc:
                for key, val in doc[subsys].items():
                    try:
                        print(key, val.unit, val.value)
                    except:
                        pass # not a constant param


if __name__ == '__main__':
    main()