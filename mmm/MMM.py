import setups
import numpy as np
import math
from scipy.optimize import least_squares
from statistics import mean

class MMM:
    def __init__(self, params: setups.VehicleSetup):
        self.params = params
        
        self.step_size = 1
    
    def generate(self, velocity, max_bodyslip_angle, max_steered_angle):
        beta_range = np.arange(-max_bodyslip_angle, max_bodyslip_angle + self.step_size, self.step_size)
        delta_range = np.arange(-max_steered_angle, max_steered_angle + self.step_size, self.step_size)

        beta = beta_range[0]
        delta = delta_range[0]

        



    
    
