import re
import yaml

def preprocess_yaml(content):
    lines = content.split('\n')
    processed_lines = []
    comments = {}

    for line in lines:
        stripped_line = line.strip()

        # Handle lines like '- index: 0 # Install high quality soundclips'
        match = re.match(r'^\s*-\s*index:\s*(\d+)\s*#\s*(.+)', stripped_line)

        if match:
            index = int(match.group(1))
            comment = match.group(2)
            processed_lines.append(f"    - component_name: '{comment}'")
            processed_lines.append(f"      index: {index}")
            continue

        # Handle lines like '- 0 # Component 1.'
        match = re.match(r'^\s*-\s*(\d+)\s*#\s*(.+)', stripped_line)
        if match:
            index = int(match.group(1))
            comment = match.group(2)
            processed_lines.append(f"    - component_name: '{comment}'")
            processed_lines.append(f"      index: {index}")
            continue

        processed_lines.append(line)

    return '\n'.join(processed_lines), comments

yaml_content2 = """
modules:
  - name: hq_soundclips_bg2ee
    components:
    - index: 0 # Install high quality soundclips for new BG2EE content: 1.2
  - name: HerThiMoney
    description: Heroes Thieves and Moneylenders
    components:
      - 0 # Component 1. Interjections & Mini-quests (by Austin & Arcanecoast Team): 4.2.3
      - 10 # Component 2. First Calimport Bank Pack (by Scheele & Austin & Arcanecoast Team): 4.2.3
      - 20 # Component 3. Shadow-Covered Love & Death (by Alisia & Austin): 4.2.3
      - 30 # Component 4. The Missing Troll Case (by Alisia & Austin): 4.2.3
      - 40 # Component 5. Unlocked original dialogs of all NPC (by Tipun & Austin): 4.2.3
  - name: infinity_ui
    components: ask
    location:
      github_user: Renegade0
      repository: InfinityUI
      branch: main
      refresh: 1week
  - name: turnabout
    components:
      - 0 # Ascension: Turnabout
    location:
      github_user: Pocket-Plane-Group
      repository: Turnabout
      release: v1.8
      asset: turnabout-v1.8.iemod
  - name: c#sodboabri
    description: The Boareskyr Bridge Scene
    components: ask
    location:
      github_user: Gibberlings3
      repository: The_Boareskyr_Bridge_Scene
      release: v6
      asset:  the-boareskyr-bridge-scene-v6.iemod
  - name: ascension
    description: ascension - main component -> WARNs no effects added to SPPR403.spl | SPWI306.spl | spermel.itm
    components:
      - 0     # Rewritten Final Chapter of Throne of Bhaal
    location:
      github_user:  InfinityMods
      repository: Ascension
      release: "2.0.28"
      asset: ascension-2.0.28.iemod
    ignore_warnings: true
"""

processed_yaml2, comments2 = preprocess_yaml(yaml_content2)
print("\nProcessed YAML for yaml_content2:")
print(processed_yaml2)