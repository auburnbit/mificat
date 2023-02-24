import sys
import numbers


f = open("godot_classes2.txt", "r") 
path = 'output.txt'
sys.stdout = open(path, 'w')
print("var quiz_dict = {")

#initialization for first term
term = "none"
prev_term = "none"
level = 0
prev_level = 0
falls_under = ["none"]

for line in f:
    
    prev_term = term
    term = (line.split("::"))[0]
    term = term.lstrip()
    definition = (line.split("::"))[1]
    definition = definition.rstrip("\n")
    
    level = line.count(' '*4)

    if level > prev_level:
        falls_under.append(prev_term)
    else: 
        while level < prev_level:
            falls_under.pop()
            prev_level -= 1
    prev_level = level

    print("\t\"" + term + "\":{")
    print("\t\t\"Level\": \"" + str(level) + "\",")
    print("\t\t\"Definition\": \"" + definition + "\",")
    print("\t\t\"FallsUnder\": \"" + falls_under[level] + "\",")
    print("\t\t\"UserGrade\": \"0\",")
    print("\t\t\"RepNumber\": \"0\",")
    print("\t\t\"Easiness\": \"0\",")
    print("\t\t\"Interval\": \"0\",")
    print("\t\t\"LastDateAndTime\": \"never\",")
    print("\t}")



sys.stdout.close