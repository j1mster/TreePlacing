# 🌲 Tree Spawner Luau Module

This is a LuaU module designed to automate the spawning and placement of trees across a given region of the Roblox world. It uses raycasting to ensure each tree lands properly on terrain and creates a consistent, natural look.

---

## 📦 Features

- Automatically welds and centers tree models.
- Destroys unnecessary transparent parts.
- Uses raycasting to find proper Y-coordinate placement.
- Accepts user-defined regions, folders, and tree counts.
- Gracefully handles errors and optionally silences warnings.
- Designed to be used in both Studio and runtime environments.

---

## 📄 Usage

```lua
local TreeSpawner = require(path.to.treemodule)

-- Example:
TreeSpawner(
    nil,                             -- Trees: Use Studio selection
    50,                              -- Tree Count
    Vector3.new(-1024, -8, -1024),   -- Start Position
    Vector3.new(1024, 16, 1024),     -- End Position
    nil,                             -- Folder (optional)
    true                             -- Silence Warnings (optional)
)
````

If running in a game or automated script, consider using `pcall`:

```lua
pcall(TreeSpawner, nil, 50, Vector3.new(-1024, -8, -1024), Vector3.new(1024, 16, 1024))
```

---

## 📥 Parameters

| Param # | Name            | Required | Description                                                 |
| ------: | --------------- | :------: | ----------------------------------------------------------- |
|       1 | Trees           |    No    | An array of tree models. If `nil`, uses Studio selection.   |
|       2 | TreeCount       |    No    | Number of trees to spawn. If `nil`, uses length of `Trees`. |
|       3 | Start (Vector3) |    Yes   | Bottom corner of the region. Y must be lowest point.        |
|       4 | End (Vector3)   |    Yes   | Opposite corner. Y must be higher than `Start.Y`.           |
|       5 | Folder          |    No    | Folder to store the trees. Creates one if `nil`.            |
|       6 | SilenceWarnings |    No    | If `true`, silences non-critical warnings.                  |

---

## ⚙️ Behind the Scenes

* `cleanupParts(model)`
  Removes transparent parts and destroys existing PrimaryPart if found.

* `createPrimaryPart(model)`
  Adds a red 1x1x1 anchor point at the model's lowest center and welds all parts to it.

* `getY(model, pos, lowestY)`
  Uses raycasting to find the terrain surface Y coordinate.

* `SpawnTrees(...)`
  Core function for spawning trees across the world space. Handles failures gracefully and prints stats if warnings aren't silenced.

---

## ⚠️ Notes

* The “world” refers to the region trees can spawn in. It must have a valid Y range.
* Errors are printed unless silenced. Use `pcall` to prevent runtime crashes.
* Tree models must be reasonably constructed; improper parts may be cleaned up automatically.

---

## 📚 License

MIT License. Use freely in personal or commercial Roblox projects.

---

Happy planting! 🌳

