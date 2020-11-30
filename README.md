# ATAI Final Work: JGOMAS

## 1. Description:
- ### Subject: Advanced Techniques in Artificial Intelligence
- ### Objective: Modify default ALLIED and AXIS agents to achieve some tasks
- ### Contents: This repository contains jgomas code, jgomas Unity renderer and running scripts
    - `jgomas`: jgomas code containing maps, agents, launchers, manager, renderer...
    - `JGOMAS_Unity_Windows`: jgomas Unity Windows renderer
    - `run`: scripts to run launcher, manager and renderer together
    - `JGomas-Fighters`: code from previous year teams

## 2. Teams:
- ### Final Teams: 6 members, joining 2 teams of 3 memebers.
- ### Specialized sub-teams: ALLIED and AXIS
- ### ALLIED team: Alex Beltrán, Enaitz Berrocal and Oihane Cantero
- ### AXIS team: Jon Ander Almandoz, Julen Etxaniz and Jokin Rodriguez

## 3. Deadlines:
- ### Deadline task 1 and 2 : Before December 1, 2020
- ### Deadline task 3 and 4: December 17, 2020
- ### Competition and presentations: December 17, 2020

## 4. Configuration:
- ### Map: map_04
- ### Number of soldiers per team: 7
- ### Configuration of default ALLIED and AXIS teams: 3 soldiers, 2 medics, 2 fieldops
- ### Default time per match: 10 min.
- ### Default parameters: health, ammo, etc.

## 5. Tasks:
The default agents are in folder `default`. The file to run the default agests is `run_render_defaultVSdefault`.

### 5.1. Implement a winning ALLIED team for the default AXIS team.
The implementation of this task is in folder `simple`. The file to run this task is `run_render_simpleVSdefault`.

### 5.2. Implement a winning AXIS team for the default ALLIED team.
The implementation of this task is in folder `simple`. The file to run this task is `run_render_defaultVSsimple`.

### 5.3. Implement a winning ALLIED team for any AXIS team.
The implementation of this task is in folder `complex`. The files to run this task are `run_render_complexVScomplex` and `run_render_complexVSsimple`.

### 5.4. Implement a winning AXIS team for any ALLIED team.
The implementation of this task is in folder `complex`. The file to run this task is `run_render_complexVScomplex` and `run_render_simpleVScomplex`.