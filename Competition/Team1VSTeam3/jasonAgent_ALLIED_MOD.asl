    debug(3).

    // Name of the manager
    manager("Manager").

    // Team of troop.
    team("ALLIED").
    // Type of troop.
    type("CLASS_SOLDIER").




    { include("jgomas.asl") }




    // Plans


    /*******************************
    *
    * Actions definitions
    *
    *******************************/

    /////////////////////////////////
    //  GET AGENT TO AIM 
    /////////////////////////////////  
    /**
    * Calculates if there is an enemy at sight.
    * 
    * This plan scans the list <tt> m_FOVObjects</tt> (objects in the Field
    * Of View of the agent) looking for an enemy. If an enemy agent is found, a
    * value of aimed("true") is returned. Note that there is no criterion (proximity, etc.) for the
    * enemy found. Otherwise, the return value is aimed("false")
    * 
    * <em> It's very useful to overload this plan. </em>
    * 
    */  
    +!get_agent_to_aim
    <-  ?debug(Mode); if (Mode<=2) { .println("Looking for agents to aim."); }
    ?fovObjects(FOVObjects);
    .length(FOVObjects, Length);

    ?debug(Mode); if (Mode<=1) { .println("El numero de objetos es:", Length); }

    .my_name(Me);

    // ?tasks(Tasks);
    // .println("TASKS: ", Me, "             ", Tasks);
    
    //?my_medic(PrintMedic);
    //?my_fieldops(PrintFieldOps);
    //.println("MY MEDIC: ", PrintMedic, " MY FIELDOPS: ", PrintFieldOps);
    
    // We check the visualized objects by the agent in case it's an enemy.
	// If there's an enemy the agent will shoot as long as there is not an ally
	// in the precaution area where it might get shot
	
    if (Length > 0) {
        +bucle(0);
        
        -+aimed("false");
        
        while (aimed("false") & bucle(X) & (X < Length)) {
            
            //.println("Inside while, X value is:", X);
            
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
                
                if (Team == 200) {  // Only if I'm ALLIED
                    ?debug(Mode); if (Mode<=2) { .println("Aiming an enemy. . .", MyTeam, " ", .number(MyTeam) , " ", Team, " ", .number(Team)); }
                    +aimed_agent(Object);
                    .nth(3, Object, Angle);
                    .nth(4, Object, Dist);
                    +bucle2(0);
                    +friendly(0);
                    // .println("Enemy Spotted: ", Object);
                    while(friendly(F) & F == 0 & bucle2(J) & (J < Length)){
                        .nth(J, FOVObjects, Object2);
                        .nth(2, Object2, Type2);
                        if(not(Type2 > 1000)){
                            .nth(1,Object2,Team2);
                            if (Team2 == 100){
                                // .println("Ally near: ", Object2);
                                .nth(3, Object2, Angle2);
                                .nth(4, Object2, Dist2);	
                                 // Check the precaution angle...
                                if(((Angle - 0.3) < Angle2) & (Angle2 <= (Angle + 0.3)) & (Dist2 < Dist)){
                                    // .println("Inside the angle...");
                                    -+friendly(1);
                                }
                            }
                        }
                        -+bucle2(J + 1);
                    }
                    // If there is not an ally near then shoot
                    ?friendly(Friend);                
                    if(Friend == 0){
                        // .println("Shoots");
                        +aimed_agent(Object);
                        -+aimed("true");
                    }else{
                        // .println("Doesn't shoot");
                    }
                            
                    -friendly(_);
                    -bucle2(_);
                    
                }
                
            }
            
            -+bucle(X+1);
            
        }
        
        
    }

    -bucle(_).

    // Spreadout functions is called when the formed subgroups are not separeted enough
	// It changes the position they need to go slightly in order to separate them.
	// A new type of task is used for this: TASK_FORCE_MOVEMENT

    +!spreadOut <-  
        ?my_position(X,Y,Z);
        .random(R1);
        .random(R2);
        RX = R1*2.5;
        RZ = R2*2.5;

        if(X+RX > 255){
            RX = - RX;
        }

        if(Z+RZ > 255){
            RZ = - RZ;
        }

        check_position(pos(X+RX, Y, Z+RZ));
        // If the position is valid separate them
        if(position(valid)){
            // .println("Sending the agents to a position");
            .my_name(MyName);
            !add_task(task("TASK_FORCE_MOVEMENT", MyName, pos(X+RX, Y, Z+RZ), ""));
            -+state(standing);
        }else{
            // .println("Not a valid position");
        }
        -position(_);
        .

    // Function to get the positions of the soldiers medic and fieldops
	// Updates the corresponding beliefs
    +give_my_position(X, Y, Z)[source(A)] <-
        .term2string(A, Sender);
        if (my_health(H) & (H > 0)){
            ?my_medic(TheMedic);
            if (Sender = TheMedic){
                -+my_medic_pos(pos(X, Y, Z));
            }

            ?my_fieldops(TheFieldOps);
            if (Sender = TheFieldOps){
                -+my_fieldops_pos(pos(X, Y, Z));
            }
        }
    .

    /////////////////////////////////
    //  LOOK RESPONSE
    /////////////////////////////////
    +look_response(FOVObjects)[source(M)]
        <-  //-waiting_look_response;
            .length(FOVObjects, Length);
            if (Length > 0) {
                ?debug(Mode); if (Mode<=1) { .println("HAY ", Length, " OBJETOS A MI ALREDEDOR:\n", FOVObjects); }
            }
            .my_name(Me);
            .term2string(Me, S);
            ?my_position(X,Y,Z);
            .my_team("ALLIED", E);
            if (objectivePackTaken(on)){
                // SEND MESSAGE TO ALLIED AGENTS AND SAY WE HAVE THE FLAG               
                .concat("flag_taken(",X,",",Y,",",Z,")", Content1);
                //We send the message to all the allies.
                .send_msg_with_conversation_id(E,tell,Content1,"INT2");
                -+flag_taken_by_team(1);
                -+flag_taken_by_team_name(S);
            }
            // Check if my team is alive
            ?my_medic(TheMedic);
            ?my_fieldops(TheFieldOps);
            ?flag_taken_by_team_name(TheFlagTrop);
            
            // Checking flag_taken_by_team_name value
			// .println("flag_taken_by_team_name value is: ", TheFlagTrop);

            // Updating the beliefs of the team members in case they die

            // if my medic is dead
            if (not (.member(TheMedic, E))){
                -+my_medic("None");
            }
            // If my fieldops is dead
            if (not (.member(TheFieldOps, E))){
                -+my_fieldops("None");
            }

            // If the one that has the flag is dead
            if (not (.member(TheFlagTrop, E))){
                -+flag_taken_by_team(0);
                -+flag_taken_by_team_name("None");
            }

            // Generate ammo pack
            ?my_ammo(Ammo);
            if (Ammo < 80){
                create_ammo_pack;
            }
            // Generate medic packs
            ?my_health(Health);
            if (Health < 80){
                create_medic_pack;
            }

            // Perform threshold action
            !!performThresholdAction;

            //follow_me message is sent to keep the subgroups and make the medic and fieldops follow its soldiers
            .concat("follow_me(",X,",",Y,",",Z,")", Content2);
            .send_msg_with_conversation_id(E, tell, Content2, "INT1");
            -look_response(_)[source(M)];
            -+fovObjects(FOVObjects);
            !look.

    //method for following the ally with the flag
    +flag_taken(X,Y,Z)[source(A)] <-
        .term2string(A, Sender);
        if (my_health(H) & (H > 0)){ //if the agent is still alive
            if(not(objectivePackTaken(on))){
                .my_name(Me);
                // update / add the task "TASK_PROTECT" with the position of the agent with the flag
                !add_task(task("TASK_PROTECT", Me, pos(X,Y,Z), "Protect"));
                -+state(standing);
                // .println("I will follow ", A);
            }
            // Update who has the flag
            -+flag_taken_by_team(1);
            -+flag_taken_by_team_name(Sender);
        }
        .

    +follow_me(X, Y, Z)[source(A)].
    /////////////////////////////////
    //  PERFORM ACTIONS
    /////////////////////////////////
    /**
    * Action to do when agent has an enemy at sight.
    * 
    * This plan is called when agent has looked and has found an enemy,
    * calculating (in agreement to the enemy position) the new direction where
    * is aiming.
    *
    *  It's very useful to overload this plan.
    * 
    */

    // The perform_aim_action has been updated in order to make the agent shoot 10 bullets fast and follow them.
	// This way soldiers do enough damage to kill an enemy and don't waste more ammo (soldier bullets deal 10 of damage)
    +!perform_aim_action
        <-  // Aimed agents have the following format:
            // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
            ?aimed_agent(AimedAgent);
            ?debug(Mode); if (Mode<=1) { .println("AimedAgent ", AimedAgent); }
            .nth(1, AimedAgent, AimedAgentTeam);
            ?debug(Mode); if (Mode<=2) { .println("BAJO EL PUNTO DE MIRA TENGO A ALGUIEN DEL EQUIPO ", AimedAgentTeam);             }
            ?my_formattedTeam(MyTeam);

            .my_name(Me);
            ?my_ammo(Ammo);
            ?flag_taken_by_team(T);
            ?tasks(TaskList);
            ?scare_the_enemy(Scare);

            // Perform a critic attack to the enemy
            if (Scare == 1){
                .my_team("AXIS", Axis);
                .concat("shooting_to_me(99)", Content1);
                .send_msg_with_conversation_id(Axis, tell, Content1, "INT1");
                -+scare_the_enemy(0);
            }
            if (not(Ammo == 0)){
                if (AimedAgentTeam == 200) {
                    .nth(6, AimedAgent, NewDestination);
                    if(not (objectivePackTaken(on))){
                        // Follow the enemy
                        if (T == 0){
                            !add_task(task("TASK_ATTACK", Me, NewDestination, ""));
                        }else{
                            !add_task(task("TASK_PROTECT_ATTACK", Me, NewDestination, ""));  
                        }
                        -+state(standing);
                    }

                    // Shoot 10 bullets  		
                    +actual_ammo(Ammo);
                    while (actual_ammo(K) & (K > Ammo-10) & (K > 0)){
                        !!shot(0);
                        -+actual_ammo(K-1);
                    }
                    -actual_ammo(_);
                }
            }
    .

    /**
    * Action to do when the agent is looking at.
    *
    * This plan is called just after Look method has ended.
    * 
    * <em> It's very useful to overload this plan. </em>
    * 
    */
    +!perform_look_action <-
        
        ?fovObjects(FOVObjects);
        .length(FOVObjects, Length);

        +bucle(0);
        ?my_ammo(Ammo);
        ?flag_taken_by_team(Flag);
        while (bucle(X) & (X < Length)) {
            .nth(X, FOVObjects, Object);
            // Object structure
            // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
            .nth(1, Object, Team);
            .nth(2, Object, Type);
            // .println("OBJECT", Object);
            if (Team == 100 & Type == 1){
                // .println("OBJECT", Object);
                // soldier is an ally
                .nth(3, Object, Angle);
                .nth(4, Object, Dist);
                // .println("Distance with another agent: ", Dist, " Angle: ", Angle );
                // Spread out if they are too close
                if ((Flag == 0) & (Ammo > 0)){
                    if(((Dist < 3) & (Angle < 0.9)) | ((Dist < 8) & (Angle < 0.5))){
                        // .println("Spreading out");
                        !spreadOut;
                    }
                }
            }
            -+bucle(X+1);
        }
        -bucle(_);
    .   

    /**
    * Action to do if this agent cannot shoot.
    * 
    * This plan is called when the agent try to shoot, but has no ammo. The
    * agent will spit enemies out. :-)
    * 
    * <em> It's very useful to overload this plan. </em>
    * 
    */  
    +!perform_no_ammo_action . 
    /// <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_NO_AMMO_ACTION GOES HERE.") }.
        
    /**
        * Action to do when an agent is being shot.
        * 
        * This plan is called every time this agent receives a messager from
        * agent Manager informing it is being shot.
        * 
        * <em> It's very useful to overload this plan. </em>
        * 
        */
    +!perform_injury_action <-
        ?flag_taken_by_team(T);
        ?my_ammo(Ammo);
        if ((Ammo > 0) & (aimed(Ag)) & (not(Ag=="true"))){
            Move = math.floor(math.random(4));
            ?my_position(X, Y, Z);
            .my_name(Me);

            //we are setting a new position to move in order to make the agent turn around
            if (Move == 0) {
                check_position(pos(X, Y, Z+1));
                if ((position(valid)) & (not (objectivePackTaken(on))) & (T==1)){
                    !add_task(task("TASK_PROTECT_SHOT", Me, pos(X,Y,Z+1), "checking surroundings"));
                }else{
                    if ((position(valid)) & (T==0)){
                        !add_task(task("TASK_FORCE_MOVEMENT_RANDOM", Me, pos(X,Y,Z+1), "checking surroundings"));
                    }
                }
            }
            if (Move == 1) {
                check_position(pos(X+1, Y, Z));
                if ((position(valid)) & (not (objectivePackTaken(on))) & (T==1)){
                    !add_task(task("TASK_PROTECT_SHOT", Me, pos(X+1,Y,Z), "checking surroundings"));
                }else{
                    if ((position(valid)) & (T==0)){
                        !add_task(task("TASK_FORCE_MOVEMENT_RANDOM", Me, pos(X+1,Y,Z), "checking surroundings"));
                    }
                }
            } 
            if (Move == 2) {
                check_position(pos(X-1, Y, Z));
                if ((position(valid)) & (not (objectivePackTaken(on))) & (T==1)){
                    !add_task(task("TASK_PROTECT_SHOT", Me, pos(X-1,Y,Z), "checking surroundings"));
                }else{
                    if ((position(valid)) & (T==0)){
                        !add_task(task("TASK_FORCE_MOVEMENT_RANDOM", Me, pos(X-1,Y,Z), "checking surroundings"));
                    }
                }
            }
            if (Move == 3) {
                check_position(pos(X, Y, Z-1));
                if ((position(valid)) & (not (objectivePackTaken(on))) & (T==1)){
                    !add_task(task("TASK_PROTECT_SHOT", Me, pos(X,Y,Z-1), "checking surroundings"));
                }else{
                    if ((position(valid)) & (T==0)){
                        !add_task(task("TASK_FORCE_MOVEMENT_RANDOM", Me, pos(X,Y,Z-1), "checking surroundings"));
                    }
                }
            }
            -+state(standing);
        }
    .
        ///<- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_INJURY_ACTION GOES HERE.") }. 
            

    /////////////////////////////////
    //  SETUP PRIORITIES
    /////////////////////////////////
    /**  You can change initial priorities if you want to change the behaviour of each agent  **/
    +!setup_priorities
        <-  

        	// New tasks are used so their priorities are initialized here

            +task_priority("TASK_NONE", 0);
            +task_priority("TASK_GET_OBJECTIVE", 1000); // Default get objective
            +task_priority("TASK_ATTACK", 1100); // Attack to the enemy
            +task_priority("TASK_FOLLOW", 1100); // Follow in groups of 3
            +task_priority("TASK_GIVE_MEDICPAKS", 2100); // Give medic assitance
            +task_priority("TASK_GIVE_AMMOPAKS", 2100); // Give ammo
            +task_priority("TASK_PROTECT", 1300); // When someone has the flag follow him
            +task_priority("TASK_WALKING_PATH", 1400); // When there is a wall in the middle
            +task_priority("TASK_FORCE_MOVEMENT_RANDOM", 1500); // Force the movement of an agent
            +task_priority("TASK_FORCE_MOVEMENT", 1501); // Force the movement of an agent
            +task_priority("TASK_GET_MEDICPAKS", 2200); // Go near the medic
            +task_priority("TASK_GET_AMMOPAKS", 2200); // Go near the fieldops 
            +task_priority("TASK_PROTECT_SHOT", 1310); // Make a random movement when we have the flag
            +task_priority("TASK_PROTECT_ATTACK", 1320); // Attack someone when we have the flag
        .


    /////////////////////////////////
    //  UPDATE TARGETS
    /////////////////////////////////
    /**
    * Action to do when an agent is thinking about what to do.
    *
    * This plan is called at the beginning of the state "standing"
    * The user can add or eliminate targets adding or removing tasks or changing priorities
    *
    * <em> It's very useful to overload this plan. </em>
    *
    */

    +!update_targets
        <-	?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR UPDATE_TARGETS GOES HERE."); }.
        
        
        
    /////////////////////////////////
    //  CHECK MEDIC ACTION (ONLY MEDICS)
    /////////////////////////////////
    /**
    * Action to do when a medic agent is thinking about what to do if other agent needs help.
    *
    * By default always go to help
    *
    * <em> It's very useful to overload this plan. </em>
    *
    */
    +!checkMedicAction
        <-  -+medicAction(on).
        // go to help
        
        
    /////////////////////////////////
    //  CHECK FIELDOPS ACTION (ONLY FIELDOPS)
    /////////////////////////////////
    /**
    * Action to do when a fieldops agent is thinking about what to do if other agent needs help.
    *
    * By default always go to help
    *
    * <em> It's very useful to overload this plan. </em>
    *
    */
    +!checkAmmoAction
        <-  -+fieldopsAction(on).
        //  go to help



    /////////////////////////////////
    //  PERFORM_TRESHOLD_ACTION
    /////////////////////////////////
    /**
    * Action to do when an agent has a problem with its ammo or health.
    *
    * By default always calls for help
    *
    * <em> It's very useful to overload this plan. </em>
    *
    */
    +!performThresholdAction <-

    // Threshold action has been updated so that the soldiers get only ammo and healing from their corresponding group
	// medic and fieldops agents, if any soldier has not a medic or fieldops because he has no subgroup or they have died
	// they will ask for healing or ammo as they used to do before, asking to any agent.
	
	// When an agent has no medic or fieldops its beliefs are "None"

        ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_TRESHOLD_ACTION GOES HERE."); }
        ?flag_taken_by_team(T);
            //we get the medic and fieldops corresponding to the one of the soldier subgroup
            ?my_medic(TheMedic);
            ?my_fieldops(TheFieldOps);
            .my_name(Me);
            .term2string(Me, S);
            if (not (S = "A13") ){
                // .println("PERFORM THRESHOLD ACTION", Me);
                .my_team("ALLIED", E);

                // if my medic is dead
                if (not (.member(TheMedic, E))){
                    -+my_medic("None");
                }
                // If my fieldops is dead
                if (not (.member(TheFieldOps, E))){
                    -+my_fieldops("None");
                }

                ?my_medic(TheMedic2);
                ?my_fieldops(TheFieldOps2);

                // .println("MY MEDIC: ", TheMedic, " ", FoundMedic, " MY FIELDOPS: ", TheFieldOps, " ", FoundFieldOps);
                // .println("Threshold action: The field ops: ", TheFieldOps, " THE MEDIC ", TheMedic);
                ?my_ammo_threshold(At);
                ?my_ammo(Ar);
                ?my_position(X, Y, Z);

                // Check if the soldier needs ammo
                if (Ar <= At) { 
                    //.println("My teams fieldops: ", E1 );
                    .my_team("fieldops_ALLIED", EFieldops);
                    .concat("cfa(",X, ", ", Y, ", ", Z, ", ", Ar, ")", Content1);
                    if (TheFieldOps2 = "None"){
                        // .println("I ask anyone");
                        .send_msg_with_conversation_id(EFieldops, tell, Content1, "CFA");
                    }else{
                        // .println("I ask my FieldOps");
                        .send_msg_with_conversation_id(TheFieldOps2, tell, Content1, "CFA");
                        // Go to my fieldops if my ammo is to low
                        if (Ar == 0){
                            ?my_fieldops_pos(pos(OpsX, OpsY, OpsZ));
                            !add_task(task("TASK_GET_AMMOPAKS", Me, pos(OpsX, OpsY, OpsZ), ""));
                            -+state(TaskPriority, standing);
                        }
                    }
                }
                
                ?my_health_threshold(Ht);
                ?my_health(Hr);
                // Check if the soldier needs life
                if (Hr <= Ht) { 
                    //.println("My teams medics: ", E2 );
                    .my_team("medic_ALLIED", EMedic);
                    .concat("cfm(",X, ", ", Y, ", ", Z, ", ", Hr, ")", Content2);
                    if(TheMedic2 = "None"){
                        // .println("I ask anyone (Medic)");
                        .send_msg_with_conversation_id(EMedic, tell, Content2, "CFM");
                    }else{
                        // .println("I ask my medic");
                        .send_msg_with_conversation_id(TheMedic2, tell, Content2, "CFM");
                        // Go to my medic if my life is to low
                        if (Hr < 10){
                            ?my_medic_pos(pos(MedX, MedY, MedZ));
                            !add_task(task("TASK_GET_MEDICPAKS", Me, pos(MedX, MedY, MedZ), ""));
                            -+state(standing);
                        }
                    }
                }
            }
        
        .
    /////////////////////////////////
    //  ANSWER_ACTION_CFM_OR_CFA
    /////////////////////////////////

        

        
    +cfm_agree[source(M)]
    <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_agree GOES HERE.");}
        -cfm_agree.  

    +cfa_agree[source(M)]
    <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_agree GOES HERE.");}
        -cfa_agree.  

    +cfm_refuse[source(M)]
    <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_refuse GOES HERE.");}
        -cfm_refuse.  

    +cfa_refuse[source(M)]
    <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_refuse GOES HERE.");}
        -cfa_refuse.  

    /////////////////////////////////
    //  Initialize variables
    /////////////////////////////////

    +!init
    <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR init GOES HERE.");}

        // During initialization new beliefs are created in order to control the subgroups of the allied team

        .my_name(Me);
        .term2string(Me, S);
        if (S = "A11"){

      		// if i'm soldier 1

            +my_medic("A21");
            +my_fieldops("A31");
            +scare_the_enemy(0);
        }else{
            if(S = "A12"){
                
                // soldier 2

                +my_medic("A22");
                +my_fieldops("A32");
                +scare_the_enemy(0);
            }else{

                // soldier 3

                +my_medic("None");
                +my_fieldops("None");
                +scare_the_enemy(1);
            }
        }

		// Other beliefs are created also to store the position of the subgroups, if the flag has been taken and who has the flag.
        +my_medic_pos(pos(0,0,0));
        +my_fieldops_pos(pos(0,0,0));
        +flag_taken_by_team(0);
        +flag_taken_by_team_name("None");
        // Changed threshold ammo and medic packs so that they can heal and get ammo easier and sooner
        -+my_health_threshold(90);
        -+my_ammo_threshold(90);
        /*?my_medic(A);
        ?my_fieldops(B);
        .println("MY MEDIC", A);
        .println("MY FIELDOPS", B);

        ?my_medic_pos(pos(X, Y, Z));
        .println("My medic pos: ", X, " ", Y, " ", Z);
        */
        // For testing:
        // -+my_ammo(0);
        // -+my_health(1);
    .  
