from Vehicle import Vehicle
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from multiprocessing import Pool, cpu_count
import scipy.interpolate as interp

class Engine:

    def __init__(self, AERO, DYN, PTN, trajectory) -> None:
        self._trajectory_path = trajectory
        self._AERO = AERO
        self._DYN = DYN
        self._PTN = PTN
        
        self._sweep_params = []
        self._sweep_classes = []
        self._sweep_bounds = []

        self._run_mode = "ENDURANCE"

    def single_run(self, run_mode="ENDURANCE", plot=False):
        vehicle = Vehicle(AERO=self._AERO, DYN=self._DYN, PTN=self._PTN, trajectory_path=self._trajectory_path)
        vehicle.GGV.generate()
        laptime = 0

        self._run_mode = run_mode.upper()

        if(self._run_mode == "ENDURANCE"):
            laptime = vehicle.simulate_endurance()
        elif(self._run_mode == "ACCEL"):
            laptime = vehicle.simulate_accel()
        else:
            print(f"Invalid run mode: {self._run_mode}, please select either ENDURANCE or ACCEL.")
            return
        print(laptime)
        
        if plot:
            if(self._run_mode == "ENDURANCE"):
                Ax_f = np.zeros(len(vehicle.ax_f))
                Ay_f = np.zeros(len(vehicle.ay_f))

                V_f = np.zeros(len(vehicle.velocity_f))


                for i in range(len(vehicle.ax_f)):
                    if(vehicle.is_shifting[i] != 1):
                        Ax_f[i]  = vehicle.ax_f[i]
                        Ay_f[i]  = vehicle.ay_f[i]
                        V_f[i]  = vehicle.velocity_f[i]

                ploty1, plotz1 = np.meshgrid(np.linspace(np.min(Ay_f), np.max(Ay_f), 60),
                                            np.linspace(np.min(V_f), np.max(V_f), 60))
                
                plotx1 = interp.griddata((Ay_f, V_f), Ax_f, (ploty1, plotz1),
                                        method='linear', fill_value=0.0)
                
                Ax_r = vehicle.ax_r
                Ay_r = vehicle.ay_r

                V_r = vehicle.velocity_r
                # Griddata
                ploty2, plotz2, = np.meshgrid(np.linspace(np.min(Ay_r), np.max(Ay_r), 60),
                                            np.linspace(np.min(V_r), np.max(V_r), 60))
                plotx2 = interp.griddata((Ay_r, V_r), Ax_r, (ploty2, plotz2),
                                        method='linear', fill_value=0.0)

                fig1 = plt.figure()
                ax1 = fig1.add_subplot(projection='3d')
                surf1 = ax1.plot_surface(plotx1, ploty1, plotz1,
                                        cstride=1, rstride=1, cmap='coolwarm',
                                        edgecolor='black', linewidth=0.2,
                                        antialiased=True)
                
                surf2 = ax1.plot_surface(plotx2, ploty2, plotz2,
                                        cstride=1, rstride=1, cmap='coolwarm',
                                        edgecolor='black', linewidth=0.2,
                                        antialiased=True)
                
                # Add a color bar which maps values to colors.
                fig1.colorbar(surf1)

                plt.title("GGV")
                plt.xlabel('Ax [g]')
                plt.ylabel('Ay [g]')
                ax1.set_zlabel('Velocity [m/s]')

                

                fig2, ax2 = plt.subplots()
                ax2.axis('equal')
                ax2.plot(vehicle.ay, vehicle.ax, "o")

                fig3, ax3 = plt.subplots()
                sc = ax3.scatter(vehicle.x, vehicle.y, c=vehicle.velocity)
                cbar = plt.colorbar(sc)
                #cbar.set_label('Velocity [m/s]', rotation=270)

                fig4 = plt.figure()
                ax4 = fig4.add_subplot(projection='3d')
                ax4.plot(vehicle.ay, vehicle.ax, vehicle.velocity, "o", markersize=1)
                ax4.set_xlabel('Lateral Accel. (g)')
                ax4.set_ylabel('Longitudinal Accel (g)')
                ax4.set_zlabel('Velocity (m/s)')
                plt.xlim([-1.5, 1.5])
                plt.ylim([-1.5, 1.5])
                plt.show()
            elif(self._run_mode == "ACCEL"):
                fig, ax = plt.subplots()
                ax.scatter(vehicle.x, vehicle.y, c=vehicle.velocity)

                fig, ax = plt.subplots()
                ax.plot(vehicle.dist, vehicle.ax)
                plt.show()

    def sweep(self, num_steps, run_mode="ENDURANCE", **kwargs) -> None:
        self._run_mode = run_mode.upper()
        
        self._sweep_params = list(kwargs.keys())
        for param in self._sweep_params:
            self._sweep_bounds.append(kwargs[param])
            if getattr(self._AERO, param, None) is not None:
                self._sweep_classes.append("AERO")
            elif getattr(self._DYN, param, None) is not None:
                self._sweep_classes.append("DYN")
            elif getattr(self._PTN, param, None) is not None:
                self._sweep_classes.append("PTN")
            else:
                print(f'ERROR: Parameter "{param}" not found')
                return
        
        if(len(kwargs) == 1):
            # Single variable sweep
            sweep_range = np.linspace(self._sweep_bounds[0][0], self._sweep_bounds[0][1], num=num_steps)
            times = []

            num_processes = cpu_count() * 2
            with Pool(num_processes) as p:
                times = p.map(self.compute_task, sweep_range)
                        

            fig, ax = plt.subplots()
            ax.plot(sweep_range, list(times), "o-")
            plt.show()
        elif(len(kwargs) == 2):
            sweep_range_x = np.linspace(self._sweep_bounds[0][0], self._sweep_bounds[0][1], num=num_steps)
            sweep_range_y = np.linspace(self._sweep_bounds[1][0], self._sweep_bounds[1][1], num=num_steps)
            xx, yy = np.meshgrid(sweep_range_x, sweep_range_y)
            R = np.sin(np.sqrt(xx**2 + yy**2))

            Z = np.zeros_like(xx)

            comb_params = []
            for i in range(num_steps):
                for j in range(num_steps):
                    x = xx[i][j]
                    y = yy[i][j]
                    comb_params.append((x, y))
            
            num_processes = cpu_count() * 2
            with Pool(num_processes) as p:
                times = p.map(self.compute_task, comb_params)

            c = 0
            for i in range(num_steps):
                for j in range(num_steps):
                    Z[i][j] = times[c]
                    c += 1


            # Plot the surface.
            fig, ax = plt.subplots(subplot_kw={"projection": "3d"})
            surf = ax.plot_surface(xx, yy, Z, cmap="coolwarm",
                       linewidth=0, antialiased=False)
            fig.colorbar(surf, shrink=0.5, aspect=5)

            plt.show()
        else:
            print(f"WARN: Parameter sweeps with {len(kwargs)} variables are not supported.")
            return
        '''
        if(len(kwargs) > 1):
            
        else:
            sweep_range = kwargs[self._sweep_param]
            sweep_range = np.linspace(sweep_range[0], sweep_range[1], num=num_steps)
            times = []

            num_processes = cpu_count() * 2
            with Pool(num_processes) as p:
                times = p.map(self.compute_task, sweep_range)
                        

            fig, ax = plt.subplots()
            ax.plot(sweep_range, list(times), "o-")
            plt.show()
        '''
    
        
    def compute_task(self, p):
        vehicle = Vehicle(AERO=self._AERO, DYN=self._DYN, PTN=self._PTN, trajectory_path=self._trajectory_path)
        if(type(p) == tuple):
            # Coupled parameter sweep
            for i in range(len(p)):
                sweep_model = getattr(vehicle, self._sweep_classes[i])
                setattr(sweep_model, self._sweep_params[i], p[i])
                sweep_model.unit_conv()
        else:
            # Single param sweep
            sweep_model = getattr(vehicle, self._sweep_classes[0])
            setattr(sweep_model, self._sweep_params[0], p)
            sweep_model.unit_conv()
        
        vehicle.GGV.generate()

        laptime = 0
        if(self._run_mode == "ENDURANCE"):
            laptime = vehicle.simulate_endurance()
        elif(self._run_mode == "ACCEL"):
            laptime = vehicle.simulate_accel()
        return laptime

