import state_models
import setups
import numpy as np
import math
import matplotlib.pyplot as plt
import mmm.MMM as MMM

if __name__ == "__main__":
    params = setups.VehicleSetup()
    m = MMM.MMM(params=params)

    m.generate(15, 15, 15)