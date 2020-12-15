    debug(3).

    // Name of the manager
    manager("Manager").

    // Team of troop.
    team("ALLIED").
    // Type of troop.
    type("CLASS_FIELDOPS").




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
    /*
    ?my_soldier(PrintMySoldier);
    .println("MY SOLDIER: ", PrintMySoldier);
    */
	
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
                                if(((Angle - 0.5) < Angle2) & (Angle2 <= (Angle + 0.5)) & (Dist2 < Dist)){
                                    // .println("Inside the angle...");
                                    -+friendly(1);
                                }
                            }
                        }
                        -+bucle2(J + 1);
                    }
                            
                    ?friendly(Friend);
                    // If there is not an ally near then shoot                 
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

    /////////////////////////////////
    //  LOOK RESPONSE
    /////////////////////////////////
    +look_response(FOVObjects)[source(M)]
        <-  //-waiting_look_response;
            .length(FOVObjects, Length);
            if (Length > 0) {
                ?debug(Mode); if (Mode<=1) { .println("HAY ", Length, " OBJETOS A MI ALREDEDOR:\n", FOVObjects); }
            }
            ?my_position(X,Y,Z);
            .my_team("ALLIED", E);
            .my_name(Me);
            .term2string(Me, S);
            if (objectivePackTaken(on)){
            // SEND MESSAGE TO ALLIED AGENTS AND SAY WE HAVE THE FLAG
                .concat("flag_taken(",X,",",Y,",",Z,")",Content1);
                //We send the message to all the allies.
                .send_msg_with_conversation_id(E,tell,Content1,"INT2");
                -+flag_taken_by_team(1);
                -+flag_taken_by_team_name(S);
            }  
            
            // Check if my team is alive
            ?my_soldier(TheSoldier);
            ?flag_taken_by_team_name(TheFlagTrop);

            // Updating the beliefs of the team member in case they die

            // if my soldier is dead
            if (not (.member(TheSoldier, E))){
                -+my_soldier("None");
            }

            // If the one that has the flag is dead
            if (not (.member(TheFlagTrop, E))){
                -+flag_taken_by_team(0);
                -+flag_taken_by_team_name("None");
            }

            ?my_health(Health);
            if (Health < 80){
                create_medic_pack;
            }
            // Perform threshold action
            !!performThresholdAction;

            // Share my position
            .concat("give_my_position(",X,",",Y,",",Z,")", Content2);

            //We send the message to all the allies.
            .send_msg_with_conversation_id(E,tell,Content2,"INT3");

            -look_response(_)[source(M)];
            -+fovObjects(FOVObjects);
            !look.
        
    +give_my_position(X, Y, Z)[source(A)].

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
    +!perform_aim_action
        <-  // Aimed agents have the following format:
            // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
            ?aimed_agent(AimedAgent);
            ?debug(Mode); if (Mode<=1) { .println("AimedAgent ", AimedAgent); }
            .nth(1, AimedAgent, AimedAgentTeam);
            ?debug(Mode); if (Mode<=2) { .println("BAJO EL PUNTO DE MIRA TENGO A ALGUIEN DEL EQUIPO ", AimedAgentTeam);             }
            ?my_formattedTeam(MyTeam);

            if (AimedAgentTeam == 200) {
        
                    .nth(6, AimedAgent, NewDestination);
                    ?debug(Mode); if (Mode<=1) { .println("NUEVO DESTINO DEBERIA SER: ", NewDestination); }
            
                }
    .

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
	// When they receive the message to follow their soldier this method is performed
    +follow_me(X, Y, Z)[source(A)] <- 
        if (my_health(H) & (H > 0)){
            ?my_soldier(S);
            .my_name(Me);
            .term2string(A, Sender);
            if (Sender = S){
                check_position(pos(X-2, Y, Z-2));
                if(position(valid)){
                    !add_task(task("TASK_FOLLOW", Me, pos(X-2,Y,Z-2), "following"));
                }else{
                    !add_task(task("TASK_FOLLOW", Me, pos(X,Y,Z), "following"));
                }
                -+state(standing);
                -position(_);
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
    +!perform_look_action .
    /// <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_LOOK_ACTION GOES HERE.") }. 

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
    +!perform_injury_action.
            

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
            +task_priority("TASK_GIVE_MEDICPAKS", 0); // Give medic assitance
            +task_priority("TASK_GIVE_AMMOPAKS", 2100); // Give ammo
            +task_priority("TASK_PROTECT", 1300); // When someone has the flag follow him
            +task_priority("TASK_WALKING_PATH", 1400); // When there is a wall in the middle
            +task_priority("TASK_FORCE_MOVEMENT", 1500); // Force the movement of an agent
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
        <- -+fieldopsAction(on).
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
    +!performThresholdAction
        <-
        // ?flag_taken_by_team(T);
        
            ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_TRESHOLD_ACTION GOES HERE.") }
            
            ?my_ammo_threshold(At);
            ?my_ammo(Ar);
            
            ?my_position(X, Y, Z);
            // Check if the fieldops needs ammo
            if (Ar <= At) { 
                /*
                .my_team("fieldops_ALLIED", E1);
                //.println("My teams fieldops: ", E1 );
                .concat("cfa(",X, ", ", Y, ", ", Z, ", ", Ar, ")", Content1);
                .send_msg_with_conversation_id(E1, tell, Content1, "CFA");
                */

                // Give ammo themselves
                create_ammo_pack;
            
            }
            
            ?my_health_threshold(Ht);
            ?my_health(Hr);
            // Check if the fieldops needs life
            /*if (Hr <= Ht) {  
                
                .my_team("medic_ALLIED", E2);
                //.println("My teams medics: ", E2 );
                .concat("cfm(",X, ", ", Y, ", ", Z, ", ", Hr, ")", Content2);
                .send_msg_with_conversation_id(E2, tell, Content2, "CFM");

            }*/
        
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

    // New beliefs are created storing the soldier which corresponds to each fieldops
	// This is done to ease the subgroup task

        .my_name(Me);
        .term2string(Me, S);
        if (S = "A31"){
            //Fieldops 1 with soldier 1
            +my_soldier("A11");
        }else{ 
            if(S = "A32"){
                //Fieldops 2 with soldier 2
                +my_soldier("A12");
            }else{
                +my_soldier("None");
            }
        }
        
        // Other necessary new beliefs to know if the flag has been taken and who has the flag
        
        +flag_taken_by_team(0);
        +flag_taken_by_team_name("None");
        
        // Changed threshold ammo and medic packs so that they can heal and get ammo easier and sooner
        
        -+my_health_threshold(60);
        -+my_ammo_threshold(60);
        /*?my_soldier(A);
        .println("MY soldier", A);*/ 
    .  

