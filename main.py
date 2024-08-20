#!/usr/bin/env python3
import yaml

import os, sys;
sys.path.insert(0, __file__.rsplit(os.sep,3)[0])

from .yaml_prop.yaml_prop import PropertyLoader

# %%
def main():
    EXAMPLE_PATH = __file__.rsplit(os.sep,1)[0]
    with open(os.path.join(EXAMPLE_PATH, 'conf.yml'), 'r') as file:
        data = yaml.load_all(file, Loader=PropertyLoader)
        for doc in data:
            _pause = True

if __name__ == '__main__':
    main()