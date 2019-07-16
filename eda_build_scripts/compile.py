import os, errno, sys, shutil
from helper import run_cmd, get_files
from paths  import quartus_path

if len(sys.argv) < 2: raise Exception("Provide vhdl source file to compile")
else:                 vhdl_src = sys.argv[1]

root = os.getcwd()
mode = 'none'         # 'none', 'file', 'dir'

print('root directory: ' + root + '\n\n')

try: assert os.path.isfile(root + vhdl_src)
except:
    assert os.path.isdir(root + vhdl_src)
    mode = 'dir'
else:
    mode = 'file'

assert os.path.isdir(quartus_path)

# Thanks http://web.engr.oregonstate.edu/~sllu/tools/vhdl.html
vlib = quartus_path + '\\modelsim_ase\\win32aloem\\vlib.exe'
assert os.path.isfile(vlib)

vcom = quartus_path + '\\modelsim_ase\\win32aloem\\vcom.exe'
assert os.path.isfile(vcom)

quartus_project_dir = root + '\\quartus\\'

cmd = [ vlib, 'work' ]
if run_cmd(quartus_project_dir, cmd) != 0:
    print('vlib failed')
    sys.exit(1)


if mode == 'file':
    cmd = [ vcom, '-93', root + vhdl_src ]
    if run_cmd(quartus_project_dir, cmd) != 0:
        print('vcom failed')
        sys.exit(1)

if mode == 'dir':
    for file in get_files(root + vhdl_src, '.vhd'):
        cmd = [ vcom, '-93', '-check_synthesis', file ]
        if run_cmd(quartus_project_dir, cmd) != 0:
            print('vcom failed')
            sys.exit(1)