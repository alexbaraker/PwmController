import os, errno, sys, shutil
from helper import run_cmd
from paths  import quartus_path

if not sys.argv: option = 0
else:            option = int(sys.argv[1])

root = os.getcwd()

assert os.path.isdir(quartus_path)

quartus_tools_path = quartus_path + '\\quartus\\bin64\\'
assert os.path.isdir(quartus_tools_path)

qsys_generate = quartus_path + '\\quartus\\sopc_builder\\bin\\qsys-generate.exe'
assert os.path.isfile(qsys_generate)

quartus_sh = quartus_path + '\\quartus\\bin64\\quartus_sh.exe'
assert os.path.isfile(quartus_sh)

quartus_pgm = quartus_path + '\\quartus\\bin64\\quartus_pgm.exe'
assert os.path.isfile(quartus_pgm)

nios2_bsp_generate_files = quartus_path + '\\nios2eds\\sdk2\\bin\\nios2-bsp-generate-files.exe'
assert os.path.isfile(nios2_bsp_generate_files)

try: os.remove(root + '\\NIOS\\nios_sys_generation.rpt')
except: pass

# Make QSYS stuff
if option <= 0:
    cmd = [ qsys_generate, '--synthesis=VHDL', 'nios_sys.qsys' ]
    if run_cmd(root + '\\nios', cmd) != 0:
        print('qsys_generate failed')
        sys.exit(1)


# Synthesize
if option <= 1:
    cmd = [ quartus_sh, '-t', 'compile.tcl' ]
    if run_cmd(root + '\\quartus', cmd) != 0:
        print('quartus_sh failed')
        sys.exit(1)

    with open(root + '\\quartus\\project.tmp', 'r') as f: name = f.read()
    #os.remove(root + '\\quartus\\project.tmp')

    try: os.remove(root + '\\NIOS\\software\\' + name)
    except: pass

    try: os.makedirs(root + '\\NIOS\\software\\' + name)
    except OSError as e:
        if e.errno != errno.EEXIST: raise

    try: os.makedirs(root + '\\NIOS\\software\\' + name + '_bsp')
    except OSError as e:
        if e.errno != errno.EEXIST: raise

try: name
except: 
    with open(root + '\\quartus\\project.tmp', 'r') as f: name = f.read()

# Upload
if option <= 2:
    cmd = [ quartus_pgm, '-c', 'USB-Blaster', '-m', 'JTAG', '-o', 'P;' + name + '.sof' ]
    if run_cmd(root + '\\Quartus\\output', cmd) != 0:
        print('quartus_pgm failed')
        sys.exit(1)

'''
# Generate BSP
if option <= 3:
    # TODO: Create it if it doesn't exist
    assert os.path.isfile(root + '\\nios\\settings.bsp')

    cmd = [ nios2_bsp_generate_files, '--bsp-dir', '.', '--settings', '..\\..\\settings.bsp' ]
    if run_cmd(root + '\\nios\\software\\' + name + '_bsp', cmd) != 0:
        print('quartus_pgm failed')
        sys.exit(1)
'''

# TODO: Generate BSP
#   <command to set up default bsp>
#   nios2-swexample-create --describeAll --cpu-name=nios2_qsys_0 --sopc-file=path+name.sopcinfo
#   ./create-this-bsp --cpu-name nios2_qsys_0 --no-make 
#   nios2-bsp-create-settings --sopc path+name.sopcinfo --type hal --settings ./settings.bsp --bsp-dir . --script quartus_path+nios2eds/sdk2/bin/bsp-set-defaults.tcl  --cpu-name nios2_qsys_0
#   nios2-bsp-generate-files --bsp-dir . --settings settings.bsp

# TODO Setup project
#   ./create-this-app --no-make
#   nios2-app-generate-makefile --bsp-dir ../Lab_6_bsp --set QUARTUS_PROJECT_DIR=../../ --elf-name Lab_6.elf --no-src --set OBJDUMP_INCLUDE_SOURCE 1
#   nios2-app-update-makefile --app-dir C:\Users\abraker\Documents\C++\Repos\EDA_new\Lab_6\nios\software\Lab_6 --add-src-files ../../../src/nios/main.c
#   nios2-app-update-makefile --app-dir C:\Users\abraker\Documents\C++\Repos\EDA_new\Lab_6\nios\software\Lab_6 --remove-src-files ../../../src/nios/main.c
#   nios2-app-update-makefile --list-src-files --app-dir C:\Users\abraker\Documents\C++\Repos\EDA_new\Lab_6\nios\software\Lab_6

# TODO: Compile
#   <nios compiler> make all

# TODO: Run
#   <command for running on NIOS>

# TODO: Debug
#   <command for debugging on NIOS>