import re
import json

allRecipes = {}
scope = re.compile("^[ \ta-zA-Z\.]*\(")
tagPattern = "{.*}"
cookPattern = "^(campfire|furnace|blastFurnace|smoker)"

with open("recipes.txt", "r") as f:
  recipeType = ""
  recipes = {}
  for line in f.readlines():
    line = line.strip()

    # Clean up recipe types
    if line.startswith("'"):
      if len(recipes) > 0:
        allRecipes[recipeType] = recipes
      recipeType = line.lstrip("'<recipetype:").rstrip(">'")
      recipes = {}
      continue

    # Remove the beginning of the line
    match = scope.search(line)
    if not match:
      continue

    # Used to skip adding a recipe
    skip = False
    recipe = {}
    # Pull out the recipe part and split it up into parts
    recipeParts = [i.strip().strip('"') for i in line[len(match[0]):].rstrip(");").split(", ")]
    res = [i.strip() for i in recipeParts[1].split("*")]
    result = res[0][6:].rstrip(">")
    if re.search(tagPattern, result):
      continue
    recipes[result] = recipe

    recipe["name"] = recipeParts[0].strip()
    recipe["count"] = int(res[1]) if len(res) == 2 else 1

    tableType = match[0].strip()
    cook = re.search(cookPattern, tableType)
    # Parse cooking recipes
    if cook:
      # Get valid components for the recipe
      recipe["components"] = [i.strip("<>")[5:] for i in recipeParts[2].split(" | ")]
      recipe["xp"] = float(recipeParts[3])
      # This is in ticks
      recipe["time"] = int(recipeParts[4])

    if "craftingTable" in tableType:
      components = [i.strip("[<>]") for i in recipeParts[2:]]
      slots = []
      if "Shaped" in tableType:
        length = len(components)
        if length == 2:
          slots = [1,3]
        elif length == 3:
          slots = [1,2,3]
        elif length == 4:
          slots = [1,2,5,6]
        elif length == 6:
          slots = [1,2,3,5,6,7]
        else:
          slots = [1,2,3,5,6,7,9,10,11]
      else:
        slots = ((i*4//3)+1 for i in range(len(components)))

      newComponents = {}
      for component, slot in zip(components, slots):
        # Remove item from the beginning of the word
        if component.startswith("item:"):
          component = component[5:]
        
        # Try to see if it has a tag
        res = re.search(tagPattern, component)
        if res:
          # Since I can't figure out how to handle it, just drop that recipe
          skip = True
          break

        # Replace this empty slot with a None
        if component == "IIngredientEmpty.getInstance()":
          component = None

        if newComponents.get(component) is None:
          newComponents[component] = [slot]
        else:
          newComponents[component].append(slot)
        recipe["components"] = newComponents
    
    if skip:
      del recipes[result]
  if len(recipes) > 0:
    allRecipes[recipeType] = recipes

with open("recipes.json", "w") as f:
  f.write(json.dumps(allRecipes, indent=2))