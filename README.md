# ATAI Final Work: JGOMAS

## 1. Description:
- ### Subject: Advanced Techniques in Artificial Intelligence
- ### Objective: Modify default ALLIED and AXIS agents to achieve some tasks
- ### Contents:
    - `jgomas`: jgomas code containing maps, agents, launchers, manager, renderer...
    - `JGOMAS_Unity_Windows`: jgomas Unity Windows renderer
    - `run`: scripts to run launcher, manager and renderer together
    - `JGomas-Fighters`: code from previous year teams: https://github.com/amujika/JGomas-Fighters

## 2. Teams:
- ### Final Teams: 6 members, joining 2 teams of 3 memebers.
- ### Specialized sub-teams: ALLIED and AXIS
- ### ALLIED team: Alex Beltrán, Enaitz Berrocal and Oihane Cantero
- ### AXIS team: Jon Ander Almandoz, Julen Etxaniz and Jokin Rodriguez

## 3. Deadlines:
- ### Deadline task 1 and 2 : Before December 1, 2020
- ### Deadline task 3 and 4: December 14, 2020
- ### Competition: December 14 and 15, 2020
- ### Presentations: December 17, 2020

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



## Final work implementations:

Few changes have been made for this last project:

AXIS team:
- Decrease the radio of the axis team.
    
    As the agents change the direction more times it is easier to detect an enemy.
```java
patrollingRadius(25).
```

- Make all agents soldiers

    We realised that we did not need healing or ammo. It was more important to kill allied agents as fast as possible.

- Implement no friendly fire.

```java
+!get_agent_to_aim
    <-  ?debug(Mode); if (Mode<=2) { .println("Looking for agents to aim."); }
        ?fovObjects(FOVObjects);
        .length(FOVObjects, Length);
    
        ?debug(Mode); if (Mode<=1) { .println("El numero de objetos es:", Length); }
    
        if (Length > 0) {
            +bucle(0);

        -+youCanShoot("false");
        -+found_enemy("false");
        -+found_allied("false");
        

        while (bucle(X) & (X < Length)) {

            //.println("En el bucle, y X vale:", X);
            
            .nth(X, FOVObjects, Object);
            // Object structure 
            // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
            .nth(2, Object, Type);
            
            ?debug(Mode); if (Mode<=2) { .println("Objeto Analizado: ", Object); }
            
            if (Type > 1000) {
                ?debug(Mode); if (Mode<=2) { .println("I found some object."); }
            } else {
                // Object may be an enemy
                .nth(1, Object, Team);
                ?my_formattedTeam(MyTeam);
    
                if (Team == 200) {  // Only if I'm AXIS
                    -+found_enemy("true");
                    -+found_enemy_obj(Object);
                }
                if(Team == 100){
                    -+found_allied("true");
                    -+found_allied_obj(Object);
                }
                
            }
        
            -+bucle(X+1);
            
        }
        if(found_enemy("true")){
            ?found_enemy_obj(EnemyObj);
            .nth(4, EnemyObj, DistToEnemy);
            if(found_allied("true")){
                ?found_allied_obj(AlliedObj);
                .nth(4, AlliedObj, DistToAlly);
                if(DistToAlly>DistToEnemy){
                    -+youCanShoot("true");
                }
                else{
                    -+youCanShoot("false");
                }
            }
            else{
                -+youCanShoot("true");
            }
            if(youCanShoot("true")){
                +aimed_agent(EnemyObj);
            }
        }
                

    }

-bucle(_).
```

ALLIED team:
- Make all the agents medics

    We found out with this little change, the enemies should make good strategies to counter this.

- Change the medic agents behaviour
```java
+!fw_distance( pos( A, B, C ), pos( X, Y, Z ) )
	<-
	D = math.sqrt( ( A - X ) * ( A - X ) + ( B - Y ) * ( B - Y ) + ( C - Z ) * ( C - Z ) );
	-+fw_distance( D );
	.
+!follow(pos( X, Y, Z ), DistObjetivo )
<-	?my_position( A, B, C );
	Vx = X - A;
	Vz = Z - C;
	Modulo = math.sqrt(Vx * Vx + Vz * Vz);
	-+destinoX(A + (Vx/Modulo) * DistObjetivo);
	-+destinoZ(C + (Vz/Modulo) * DistObjetivo);
	.println((Vx/Modulo) * DistObjetivo);

+followFlag(X, Y, Z)[source(M)] 
<-	?priority(P);
!add_task(task(P, "TASK_GOTO_POSITION", "Manager", pos(X, Y, Z), ""));
-+state(standing);            			
-+priority(P+1);
create_medic_pack;
.

+!get_agent_to_aim
<-  ?fovObjects(FOVObjects);
	.length(FOVObjects, Length);
	
	if (objectivePackTaken(on)) {
		if (returnHome(RH) & (RH == 0)) {
			!add_task(task(5000, "TASK_GOTO_POSITION", M, pos(30, 0, 240), ""));
			-+task_priority("TASK_GIVE_MEDICPAKS", 0);
			-+returnHome(1);
		}
		?my_position(X, Y, Z);
          
     	.my_team("medic_ALLIED", E2);
     	.concat("followFlag(",X, ", ", Y, ", ", Z, ")", Content2);
     	.send_msg_with_conversation_id(E2, tell, Content2, "FLAG");
	}
	if (Length > 0) {
	    +bucle(0);
	    -+aimed("false");
	    
	    while (aimed("false") & bucle(X) & (X < Length)) {
	        .nth(X, FOVObjects, Object);
	        // Object structure
	        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
	        .nth(2, Object, Type);
	        
	        ?debug(Mode); if (Mode<=2) { .println("Objeto Analizado: ", Object); }
	        
	        if (Type > 1000) {
	            ?debug(Mode); if (Mode<=2) { .println("I found some object."); }
	        } else {
	            // Object may be an enemy
	            .nth(1, Object, Team);
	            ?my_formattedTeam(MyTeam);
	            
	            /*if (Team == 200) {  // Only if I'm ALLIED				
	                ?debug(Mode); if (Mode<=2) { .println("Aiming an enemy. . .", MyTeam, " ", .number(MyTeam) , " ", Team, " ", .number(Team)); }
	                +aimed_agent(Object);
	                -+aimed("true");
	            }*/
	        }
	        -+bucle(X+1);
	    }
	}
	-bucle(_).

+!init
<- ?my_position(X, Y, Z);   
   !fw_distance(pos(X, Y, Z), pos(184, 0, 240));
   ?fw_distance(D1);
   !fw_distance(pos(X, Y, Z), pos(30, 0, 240));
   ?fw_distance(D2);

   if(D1 > D2) {
   		!add_task(task(5000, "TASK_GOTO_POSITION", M, pos(30, 0, 240), ""));
   } else {
   		!add_task(task(5000, "TASK_GOTO_POSITION", M, pos(184, 0, 240), ""));
   }    
```