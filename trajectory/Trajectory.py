import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

class Trajectory:
    '''Racing Line Generation'''
    def __init__(self, file, r_min, r_max) -> None:
        self.num_points = 0
        self.points = [[], []]
        self._curvature = None
        self.radii = None

        self.load(file)
        self.calc_curvature(self.points[0], self.points[1])
        self._curvature[self._curvature == 0] = 1e-12
        self.radii = np.divide(1, np.abs(self._curvature))

        # Clamp the trajectory turn radii to the GGV limits
        self.radii[self.radii > r_max] = r_max
        self.radii[self.radii < r_min] = r_min


    def load(self, file):
        '''For now, load Trajectory from csv'''
        df = pd.read_excel(file)
        #normalize to meters
        self.points[0] = np.divide(df["X"].to_numpy(), 1000)
        self.points[1] = np.divide(df["Y"].to_numpy(), 1000)
        self.num_points = len(self.points[0])

    def calc_curvature(self, X, Y):
        x_t = np.gradient(X)
        y_t = np.gradient(Y)

        vel = np.array([ [x_t[i], y_t[i]] for i in range(x_t.size)])
        speed = np.sqrt(x_t * x_t + y_t * y_t)

        xx_t = np.gradient(x_t)
        yy_t = np.gradient(y_t)

        self._curvature = (xx_t * y_t - x_t * yy_t) / (x_t * x_t + y_t * y_t)**1.5
        
        


if __name__ == "__main__":
    import itertools
    t = Trajectory("./trajectory/17_lincoln_endurance_track_highres.xls", 4.5, 36)
    #plt.scatter(t.points[0], t.points[1], c=abs(t._curvature))
    x = []
    y = []
    curv = []
    for i in range(len(t.points[0])):
        if abs(t._curvature[i]) > 1e-12:
            x.append(t.points[0][i])
            y.append(t.points[1][i])
            curv.append(t._curvature[i])
    plt.scatter(x, y, c=list(map(lambda x: abs(x), curv)))
    plt.colorbar()
    plt.show()

    curv = list(map(lambda x: abs(x), curv))
    print(len(curv) / sum(curv))
    print(len(t._curvature) / sum(abs(t._curvature)))
    #print(len(list(itertools.groupby(t._curvature, lambda x: x > 0))))