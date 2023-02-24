import sys
f = open("godot_classes2.txt", "r")

depth = 0
root = { "class": "root", "definition": [], "children": [] }
parents = []
node = root
for line in f:
    definition = (line.split("::"))[1]
    line = (line.split("::"))[0]
    newDepth = len(line) - len(line.lstrip("%")) + 1
    print(newDepth, line)
    # if the new depth is shallower than previous, we need to remove items from the list
    if newDepth < depth:
        parents = parents[:newDepth]
    # if the new depth is deeper, we need to add our previous node
    elif newDepth == depth + 1:
        parents.append(node)
    # levels skipped, not possible
    elif newDepth > depth + 1:
        raise Exception("Invalid file")
    depth = newDepth

    # create the new node
    node = {"txt": line.strip("%"), "definition": definition.strip("\n"), "children":[]}
    # add the new node into its parent's children
    parents[-1]["children"].append(node)

json_list = root["children"]
sys.stdout = open("output.txt")
sys.stdout.close()