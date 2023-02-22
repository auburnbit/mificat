"""window_position"""

import win32gui

hwnd1 = win32gui.FindWindow("retroarch", None)
rect = win32gui.GetWindowRect(hwnd1)
x_coord = rect[0]
y_coord = rect[1]
width = rect[2] - x_coord
height = rect[3] - y_coord
print("Window %s:" % win32gui.GetWindowText(hwnd1))
print("\tLocation: (%d, %d)" % (x_coord, y_coord))
print("\t    Size: (%d, %d)" % (width, height))

hwnd2 = win32gui.FindWindow(None, "Quiz Program")
win32gui.MoveWindow(hwnd2, x_coord,y_coord+22,width,height, True)
#win32gui.SetFocus(hwnd1)
#SetFocus requires the window to be attached to this python script's message queue
#I'll just use the controller and keyboard separately for now