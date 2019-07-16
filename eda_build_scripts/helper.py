import os, subprocess, queue
import pathlib
from threading import Thread

# Thanks http://eyalarubas.com/python-subproc-nonblock.html
class NonBlockingStreamReader:

    def __init__(self, stream):
        # stream: the stream to read from. Usually a process' stdout or stderr.
        self._s = stream
        self._q = queue.Queue()

        def _populateQueue(stream, queue):
            # Collect lines from 'stream' and put them in 'quque'.
            while True:
                line = stream.readline()
                if line: queue.put(line)
                else: break

        self._t = Thread(target = _populateQueue, args = (self._s, self._q))
        self._t.start() #start collecting lines from the stream
        

    def readline(self):
        try: return self._q.get(block=False)
        except queue.Empty: return ''


def run_cmd(cwd, cmd):
    p = subprocess.Popen(cmd, cwd=cwd, stdout=subprocess.PIPE, shell=False)
    nbsr = NonBlockingStreamReader(p.stdout)

    while True:
        line = nbsr.readline() # 0.1 secs to let the shell output the result
        if not line.strip(): 
            if p.poll() != None: break # Check if application is still alive
            continue
        
        print(line)

    nbsr._t.join()

    print('\"' + ' '.join(cmd) + '\" returned with code ' + str(p.returncode) + 
          '\n\n------------------------------------------------------------\n\n')
    return p.returncode


def get_files(path, extention):
    files = []
    for found in pathlib.Path(path).iterdir():
        if found.is_file():
            if str(found).endswith(extention): files.append(str(found))
        elif found.is_dir(): 
            for file in get_files(found, extention): files.append(file)

    return files