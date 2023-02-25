import sys

f = open("godot_classes2.txt", "r") 
path = 'output2.txt'
sys.stdout = open(path, 'w')
print("var quiz_dict = {")

#initialization for first term
term = "none"
prev_term = "none"
level = 0
prev_level = 0
catagory = ["none"]

for line in f:
    
    prev_term = term
    term = (line.split("::"))[0]
    term = term.lstrip()
    definition = (line.split("::"))[1]
    definition = definition.rstrip("\n")
    
    level = line.count(' '*4)

    if level > prev_level:
        catagory.append(prev_term)
    else: 
        while level < prev_level:
            catagory.pop()
            prev_level -= 1
    prev_level = level

    print("\t\"" + term + "\":{")
    print("\t\t\"Definition\": \"" + definition + "\",")
    print("\t\t\"Catagory\": \"" + catagory[level] + "\",")
    print("\t\t\"UserGrade\": \"0\",")
    print("\t\t\"RepNumber\": \"0\",")
    print("\t\t\"Easiness\": \"0\",")
    print("\t\t\"Interval\": \"0\",")
    print("\t\t\"LastDateAndTime\": \"never\",")
    print("\t},")

sys.stdout.close
