import os, errno, sys, shutil
from helper import run_cmd
from paths import quartus_path

if len(sys.argv) < 2: raise Exception("Provide sim.do relative path")
else:                 sim_path = sys.argv[1]

root = os.getcwd()
assert os.path.isdir(root + sim_path)

assert os.path.isdir(quartus_path)

vsim = quartus_path + '\\modelsim_ase\\win32aloem\\vsim.exe'
assert os.path.isfile(vsim)

cmd = [ vsim, '-do', 'sim.do' ]
if run_cmd(root + sim_path, cmd) != 0:
    print('vsim failed')
    sys.exit(1)