"""
This module uses a quiz to interrupt an external process (game). 
RAM values in the external process are read and altered to change 
in-game results based on the user's response to the quiz.

Functions:

    connector_loop()
    quiz_loop()
    fake_game_loop()

Threads:
    t1 runs connector_loop()
    t2 runs quiz_loop()
    t3 runs fake_game_loop()

Misc global variables:

    mem_exp
    mem_gil
    mem_eob_timer
    quiz_status

Notable Memory Addresses in Game:

gpsp_libretro.dll+001E8A5C	2 bytes		[run 1] Party Member #1 HP (100 on overworld)

gpsp_libretro.dll+001D719C  2 bytes     Party Member 1 EXP
gpsp_libretro.dll+001D71E4      "       
gpsp_libretro.dll+001D722C      
gpsp_libretro.dll+001D7274

gpsp_libretro.dll+001E893E	1 byte		[run 1] Number of Enemies Remaining 
gpsp_libretro.dll+1ECC2E area
                                        (value changes from 0 to 9 at victory)
gpsp_libretro.dll+001E911A	2 bytes		[run 1] EXP to be given (reduced before given)
gpsp_libretro.dll+1ED40A area

gpsp_libretro.dll+001E911C	2 bytes		[run 1] Gil to be given
gpsp_libretro.dll+1ED40C area

gpsp_libretro.dll+001E926A	1 bytes		[run 1] Countdown for end of battle messages 
                                        (129 on overworld)

Quiz External Flag current location (it's moving)      127BA85AB08                                  
"""

# PYLINT WARNING SUPPRESION:
# pylint: disable=C0103,W0401,W0603,W0614,W0622
# C0103 -   warnings about uncapitalized constants
# W0401 -   warnings about using wildcard imports
# W0603 -   warnings about using global variables
# W0614 -   warnings about unused wildcard imports
# W0622 -   warnings about redefining built-ins?

import threading
import psutil
from pymem import *
from pymem.process import *
from pymem.ptypes import RemotePointer

#Constants for game RAM
ENE_LOCA = 0X001E893E
ENE_LOCA2 = 0X001ECC2E
ENE_SIZE = 1
EXP_LOCA = 0X001E911A
EXP_LOCA2 = 0X001ED40A
EXP_SIZE = 2
GIL_LOCA = 0x001E911C
GIL_LOCA2 = 0x001ED40C
GIL_SIZE = 2

PM1_CEXP_LOCA = 0x001D719C
PM1_CEXP_SIZE = 2
PM2_CEXP_LOCA = 0x001D71E4
PM2_CEXP_SIZE = 2
PM3_CEXP_LOCA = 0x001D722C
PM3_CEXP_SIZE = 2
PM4_CEXP_LOCA = 0x001D7274
PM4_CEXP_SIZE = 2

# Constants for quiz RAM
QUIZ_ECF_SIZE = 4

# RAM of external processes
ene_mem_read = None
exp_mem_read = None
gil_mem_read = None
pm1_exp_mem_read = None
pm2_exp_mem_read = None
pm3_exp_mem_read = None
pm4_exp_mem_read = None

on_overworld = True

quiz_ecf_mem_read = None
quiz_flag29_currently_quizzing = None
quiz_flag30_correct_answer = None

old_pm1_exp = None
old_pm2_exp = None
ld_pm3_exp = None
old_pm4_exp = None

# Status of our external quiz
current_quizzing_state = "not currently quizzing"

'''*******************Setting up to READ/WRITE RAM before loop*********************'''

# These will immediately be overwritten
# These will immediately be overwritten
ene_mem_read = 255
exp_mem_read = 0
gil_mem_read = 0 
pm1_exp_mem_read = 0
pm2_exp_mem_read = 0
pm3_exp_mem_read = 0
pm4_exp_mem_read = 0
quiz_ecf_mem_read = 0

quiz_flag29_currently_quizzing  = False
quiz_flag30_correct_answer = True 

current_quizzing_state = "not currently quizzing"

gm = pymem.Pymem("retroarch.exe")
qm = pymem.Pymem("Quiz Program.exe")

gameModule = module_from_name(
    gm.process_handle, "gpsp_libretro.dll").lpBaseOfDll

def getPointerAddress(base, offsets):
    remote_pointer = RemotePointer(qm.process_handle, base)
    for offset in offsets:
        if offset != offsets[-1]:
            remote_pointer = RemotePointer(qm.process_handle, remote_pointer.value + offset)
        else:
            return remote_pointer.value + offset

process = filter(lambda p: p.name() == "retroarch.exe",
                    psutil.process_iter())
for i in process:
    ra_pid = i.pid

psutil.Process(pid=ra_pid).resume()

while True:

    '''*******************coordinating quiz and RAM editing logic*********************'''

    if 1 <= ene_mem_read <= 8 :

        #to revert the total exp if later they fail quiz
        old_pm1_exp = pm1_exp_mem_read
        old_pm2_exp = pm2_exp_mem_read
        old_pm3_exp = pm3_exp_mem_read
        old_pm4_exp = pm4_exp_mem_read

    if current_quizzing_state == "not currently quizzing" and \
        ene_mem_read == 9 and \
        (exp_mem_read > 0 or
        gil_mem_read > 0):
        # if the above are true the last enemy just died
        # but the EXP/gil hasn't been rewarded yet
        psutil.Process(pid=ra_pid).suspend()
        ########Hmmmm#########
        # Maybe I can't set bit 31 because it's the integer sign bit?
        #####################
        qm.write_int(getPointerAddress(qm.base_address + 0x03F3D388, offsets=[0xB0, 0x150, 0x1C8, 0x2B8, 0x70, 0x28, 0x8]), 0X20000000)
        quiz_flag29_currently_quizzing = 1
        current_quizzing_state = "started and waiting on user"

    elif current_quizzing_state == "started and waiting on user":
        # external process is suspended at this point
        # to prevent game from rewarding EXP/gil yet
        if quiz_flag29_currently_quizzing == 0:
            if quiz_flag30_correct_answer == 1:
                current_quizzing_state = "answer was correct"
            else:
                current_quizzing_state = "answer was incorrect"        

    elif current_quizzing_state == "answer was incorrect":
        psutil.Process(pid=ra_pid).resume()          
        # punish with no EXP/gil.
        if on_overworld == True:
            gm.write_bytes(gameModule + EXP_LOCA,
                            (0).to_bytes(EXP_SIZE, 'little'), EXP_SIZE)
        else:
            gm.write_bytes(gameModule + EXP_LOCA2,
                            (0).to_bytes(EXP_SIZE, 'little'), EXP_SIZE)
        
        # have to revert the EXP values as they're added too early
        gm.write_bytes(gameModule + PM1_CEXP_LOCA,
                    (old_pm1_exp).to_bytes(PM1_CEXP_SIZE, 'little'), PM1_CEXP_SIZE)        
        gm.write_bytes(gameModule + PM2_CEXP_LOCA,
                    (old_pm2_exp).to_bytes(PM2_CEXP_SIZE, 'little'), PM2_CEXP_SIZE)       
        gm.write_bytes(gameModule + PM3_CEXP_LOCA,
                    (old_pm3_exp).to_bytes(PM3_CEXP_SIZE, 'little'), PM3_CEXP_SIZE)        
        gm.write_bytes(gameModule + PM4_CEXP_LOCA,
                    (old_pm4_exp).to_bytes(PM4_CEXP_SIZE, 'little'), PM4_CEXP_SIZE)
        if on_overworld == True:
            gm.write_bytes(gameModule + GIL_LOCA,
                            (0).to_bytes(GIL_SIZE, 'little'), GIL_SIZE)
        else:
            gm.write_bytes(gameModule + GIL_LOCA2,
                            (0).to_bytes(GIL_SIZE, 'little'), GIL_SIZE)
        psutil.Process(pid=ra_pid).resume()
        # and make sure eob timer is done counting
        if ene_mem_read != 9:
            current_quizzing_state = "not currently quizzing"

    elif current_quizzing_state == "answer was correct":
        # leave exp message and gil as they are
        # and make sure eob timer is done counting
        psutil.Process(pid=ra_pid).resume()
        if ene_mem_read != 9:
            current_quizzing_state = "not currently quizzing"

    '''****************reading relevant RAM values from external process*******************'''

    prev_ene = ene_mem_read
    prev_exp = exp_mem_read
    prev_gil = gil_mem_read

    prev_pm1_exp = pm1_exp_mem_read
    prev_pm2_exp = pm2_exp_mem_read
    prev_pm3_exp = pm3_exp_mem_read
    prev_pm4_exp = pm4_exp_mem_read

    prev_ecf = quiz_ecf_mem_read

    # Read RAM values (converting to int from byte values)
    ene_mem_read = int.from_bytes(gm.read_bytes(
        gameModule + ENE_LOCA, ENE_SIZE), "little")
    exp_mem_read = int.from_bytes(gm.read_bytes(
        gameModule + EXP_LOCA, EXP_SIZE), "little")
    gil_mem_read = int.from_bytes(gm.read_bytes(
        gameModule + GIL_LOCA, GIL_SIZE), "little")
    on_overworld = True
    
    if ene_mem_read > 9:

        ene_mem_read = int.from_bytes(gm.read_bytes(
            gameModule + ENE_LOCA2, ENE_SIZE), "little")
        exp_mem_read = int.from_bytes(gm.read_bytes(
            gameModule + EXP_LOCA2, EXP_SIZE), "little")
        gil_mem_read = int.from_bytes(gm.read_bytes(
            gameModule + GIL_LOCA2, GIL_SIZE), "little")
        on_overworld = False
        
        
    # reading individual total exp values from game
    pm1_exp_mem_read = int.from_bytes(gm.read_bytes(
        gameModule + PM1_CEXP_LOCA, PM1_CEXP_SIZE), "little")
    pm2_exp_mem_read = int.from_bytes(gm.read_bytes(
        gameModule + PM2_CEXP_LOCA, PM2_CEXP_SIZE), "little")
    pm3_exp_mem_read = int.from_bytes(gm.read_bytes(
        gameModule + PM3_CEXP_LOCA, PM3_CEXP_SIZE), "little")
    pm4_exp_mem_read = int.from_bytes(gm.read_bytes(
        gameModule + PM4_CEXP_LOCA, PM4_CEXP_SIZE), "little")  
    
    #qm.write_int(getPointerAddress(qm.base_address + 0x03F35120, offsets=[0x2b8, 0x388, 0x108, 0x1a0, 0x70, 0x28, 0x8]), 0x8000000)
    quiz_ecf_mem_read = int.from_bytes(qm.read_bytes(getPointerAddress(qm.base_address \
                        + 0x03F3D388, offsets=[0xB0, 0x150, 0x1C8, 0x2B8, 0x70, 0x28, 0x8]),QUIZ_ECF_SIZE), "little")
    
    quiz_flag29_currently_quizzing = (quiz_ecf_mem_read & 0b00100000000000000000000000000000) >> 29
    quiz_flag30_correct_answer = (quiz_ecf_mem_read & 0b01000000000000000000000000000000) >> 30
    
    if current_quizzing_state == "not currently quizzing" and (prev_ene != ene_mem_read or
                                                    prev_exp != exp_mem_read or
                                                    prev_gil != gil_mem_read or
                                                    prev_ecf != quiz_ecf_mem_read or
                                                    prev_pm1_exp != pm1_exp_mem_read or
                                                    prev_pm2_exp != pm2_exp_mem_read or
                                                    prev_pm3_exp != pm3_exp_mem_read or
                                                    prev_pm4_exp != pm4_exp_mem_read):

        print("Enemies: " + f"{ene_mem_read:03d}" + ", " +
                "EXP: " + f"{exp_mem_read:05d}" + ", " +
                "Gil: " + f"{gil_mem_read:05d}" + ", " +
                "ECF: " + f"{quiz_ecf_mem_read:08x}" + ", " +
                "Flag29: " + f"{quiz_flag29_currently_quizzing:1d}" + ", " +
                "Flag30: " + f"{quiz_flag30_correct_answer:1d}" + ", " +
                "PM1 EXP: " + f"{pm1_exp_mem_read:05d}" + ", " +
                "PM2 EXP: " + f"{pm2_exp_mem_read:05d}" + ", " +
                "PM3 EXP: " + f"{pm3_exp_mem_read:05d}" + ", " +
                "PM4 EXP: " + f"{pm4_exp_mem_read:05d}")

#NEXT refactor all this mess into something more readable
#NEXT2 I feel like this should be possible without the two separate threads
#NEXT3 Figure out what's making it not connect to the quiz program sometimes (pointer is not always right?)    