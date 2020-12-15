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
        if(objectivePackTaken(on)){
            !help;
        }

        +bucleAliados(0);
        +distAliadoMin(5000000);

        while(Length > 0 & bucleAliados(X) & X < Length){

            .nth(X, FOVObjects, Object);
            // Object structure
            // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
            .nth(2, Object, Type);
            .nth(1, Object, Team);
            .nth(6, Object, Pos);
            .nth(3, Object, Angle);
            .nth(4, Object, Distance);


            if(Type <= 1000 & Team == 100){

                .concat("aliado", Pos, APos);
                .term2string(ATPost,APos);
                +ATPost;
                ?aliadopos(Xa, Ya, Za);
                ?my_position(Xmy, Ymy, Zmy);
                ?distAliadoMin(DistMin);
                 DistEuclidea =   math.sqrt((Xa - Xmy)*(Xa - Xmy) + (Za - Zmy)*(Za - Zmy));
                 if (DistEuclidea < DistMin ){
                     //.println("Distancia antes: ", DistMin);
                     -+distAliadoMin(DistEuclidea);
                 }


            }


            -+bucleAliados(X+1);
        }

        -bucleAliados(_);


        if (Length > 0) {
		    +bucle(0);

            -+aimed("false");
            -+diparar(true);

            while (aimed("false") & bucle(X) & (X < Length)) {

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

                    if (Team == 200 & not objectivePackTaken(on)) {  // Only if I'm AXIS

                         ?debug(Mode); if (Mode<=2) { .println("Aiming an enemy. . .", MyTeam, " ", .number(MyTeam) , " ", Team, " ", .number(Team)); }
                         .nth(6, Object, PosEnemy);
                         ?my_position(Xmy, Ymy, Zmy);
                         ?distAliadoMin(DistMin);
                        .concat("enemigo", PosEnemy, EPos);
                        .term2string(ETPost,EPos);
                        +ETPost;
                        ?enemigopos(Xe, Ye, Ze);
                        DistEuclideaEnemigo =   math.sqrt((Xe - Xmy)*(Xe - Xmy) + (Ze - Zmy)*(Ze - Zmy));
                        //.println("Posicon enemigo",DistEuclideaEnemigo );
                        if(DistEuclideaEnemigo < DistMin){
                           // .println("---------Disparar Distancia Enemigo: ", DistEuclideaEnemigo, " Distancia del aliado", DistMin);
                            +aimed_agent(Object);
                            -+aimed("true");


                        }else{
                            //.println("---------NOO Disparar Distancia Enemigo: ", DistEuclideaEnemigo, " Distancia del aliado", DistMin);
                            //!add_task(task(4000,"TASK_GOTO_POSITION","Manager",PosEnemy,"INT"));
                            .random(RANDOM);
                            //.println("Cambiando ruta");
                            !moveRand(Xmy, Ymy, Zmy, RANDOM*2);
                        }




                    }

                }

                -+bucle(X+1);

            }

        }

     -bucle(_).



+!help
<- ?my_position(Xp, Yp, Zp);
    if(objectivePackTaken(on)){
        //.println("TEngo la bandera");
        .my_team("ALLIED", ListaCompas);
        .length(ListaCompas, ListaCompasLength);
        +bucleC(0);
        while (bucleC(Xc) & (Xc < ListaCompasLength)){
            .nth(Xc, ListaCompas, Compa);
            .send(Compa, achieve, pos(Xp, Yp, Zp));
            -+bucleC(Xc + 1);
        }
        -bucleC(_);
    }.



/////////////////////////////////
//  LOOK RESPONSE
/////////////////////////////////
+look_response(FOVObjects)[source(M)]
    <-  //-waiting_look_response;
        .length(FOVObjects, Length);
        if (Length > 0) {
            ///?debug(Mode); if (Mode<=1) { .println("HAY ", Length, " OBJETOS A MI ALREDEDOR:\n", FOVObjects); }
        };
        -look_response(_)[source(M)];
        -+fovObjects(FOVObjects);
        //.//;
        !look.


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
                 -+state(target_reached);
                !add_task(task(4000,"TASK_ATTACK","Manager",NewDestination,""));

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
+!perform_no_ammo_action.

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



+!pos(X, Y, Z)[source(A)]
<-  //.print("SOURCE: ", A);
    //.print("Ir a ayudar a posicion: ", A, "en: X: ", X, " Y: ", Y, " Z: ",Z);
    ?tasks(T);
    .length(T, N);
    if (N > 1){
    -+state(target_reached);
    }else{
    -+state(standing);

    }
    !add_task(task(100000,"TASK_GOTO_POSITION","Manager",pos(X, Y, Z),"")).



    ///<- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_INJURY_ACTION GOES HERE.") }.


/////////////////////////////////
//  SETUP PRIORITIES
/////////////////////////////////
/**  You can change initial priorities if you want to change the behaviour of each agent  **/+!setup_priorities
    <-  +task_priority("TASK_NONE",0);
        +task_priority("TASK_GIVE_MEDICPAKS", 2000);
        +task_priority("TASK_GIVE_AMMOPAKS", 0);
        +task_priority("TASK_GIVE_BACKUP", 0);
        +task_priority("TASK_GET_OBJECTIVE",10000);
        +task_priority("TASK_ATTACK", 1200);
        +task_priority("TASK_RUN_AWAY", 1500);
        +task_priority("TASK_GOTO_POSITION", 1750);
        +task_priority("TASK_PATROLLING", 500);
        +task_priority("TASK_WALKING_PATH", 1750).



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
    <-	?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR UPDATE_TARGETS GOES HERE.") };
    ?my_position(X, Y, Z);
    ?tasks(T);
    .length(T, N);
    if(N <= 0 & not objectivePackTaken(on)){
        //.println("--------------PARADOOOOOOOOOO___________-");
        !moveRand(X, Y, Z, 5);
    }.



/////////////////////////////////
//  CHECK MEDIC ACTION (ONLY MEDICS)
/////////////////////////////////
/**
 * Action to do when a medic agent is thinking about what to do if other agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *jasonAgent_ALLIED_FIELDOPS
 */
 +!checkMedicAction
     <-
     if(objectivePackTaken(on)){
        -+medicAction(off);
     }else{
        -+medicAction(on);
     }.

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
     <-
      if(objectivePackTaken(on)){
       -+fieldopsAction(off);
     }else{
        -+fieldopsAction(on);
     }.

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

       ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_TRESHOLD_ACTION GOES HERE.") }

       ?my_ammo_threshold(At);
       ?my_ammo(Ar);

       if (Ar <= At) {
          ?my_position(X, Y, Z);

         .my_team("fieldops_ALLIED", E1);
         //.println("Mi equipo intendencia: ", E1 );
         .concat("cfa(",X, ", ", Y, ", ", Z, ", ", Ar, ")", Content1);
         .send_msg_with_conversation_id(E1, tell, Content1, "CFA");


       }

       ?my_health_threshold(Ht);
       ?my_health(Hr);

       if (Hr <= Ht) {
          ?my_position(X, Y, Z);
            if(objectivePackTaken(on)){
                create_medic_pack;
            }else{
                .my_team("medic_ALLIED", E2);
                //.println("Mi equipo medico: ", E2 );
                .concat("cfm(",X, ", ", Y, ", ", Z, ", ", Hr, ")", Content2);
                .send_msg_with_conversation_id(E2, tell, Content2, "CFM");
            }


       }
       .

/////////////////////////////////
//  ANSWER_ACTION_CFM_OR_CFA
/////////////////////////////////



+cfm_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_agree GOES HERE.")};
      -cfm_agree.

+cfa_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_agree GOES HERE.")};
      -cfa_agree.

+cfm_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_refuse GOES HERE.")};
      -cfm_refuse.

+cfa_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_refuse GOES HERE.")};
      -cfa_refuse.

+!moveRand(X, Y, Z, N)
        <-
        .my_name(Name);
	?task_priority("TASK_GOTO_POSITION", PRIORITY);

    +position(invalid);

	while (position(invalid)) {

		-position(invalid);
        .random(RANDOM);
        //UP
		if (RANDOM >= 0 & RANDOM<0.125) {
			check_position(pos(X,Y,Z-N));
            -+newPosition(X,Z-N);
            if (position(valid)) {
                /*.println("-----------------------------------------------------------------------------------------------");
                .print("Going up");
                .println("-----------------------------------------------------------------------------------------------");*/

            }


        }

        //DOWN
        if (RANDOM >= 0.125 & RANDOM<0.25) {

			check_position(pos(X,Y,Z+N));
			-+newPosition(X,Z+N);
            if (position(valid)) {
                /*.println("-----------------------------------------------------------------------------------------------");
                .println("Going down.");
                .println("-----------------------------------------------------------------------------------------------");*/

            }

        }

        //RIGHT
        if (RANDOM >= 0.25 & RANDOM<0.375) {

            check_position(pos(X+N,Y,Z));
            -+newPosition(X+N,Z);
            if (position(valid)) {
                /*.println("-----------------------------------------------------------------------------------------------");
                .println("Going right.");
                .println("-----------------------------------------------------------------------------------------------");*/

            }

        }

        //LEFT
        if (RANDOM >= 0.375 & RANDOM < 0.5) {

			check_position(pos(X-N,Y,Z));
			-+newPosition(X-N,Z);
			if (position(valid)) {
                /*.println("-----------------------------------------------------------------------------------------------");
                .println("Going left.");
                .println("-----------------------------------------------------------------------------------------------");*/

            }
        }

        //UPRIGHT
        if (RANDOM >= 0.5 & RANDOM < 0.625) {

			check_position(pos(X+N,Y,Z-N));
			-+newPosition(X+N,Z-N);
			if (position(valid)) {
                /*.println("-----------------------------------------------------------------------------------------------");
                .println("Going UP RIGHT .");
                .println("-----------------------------------------------------------------------------------------------");*/

            }
        }//DOWNRIGHT
        if (RANDOM >= 0.625 & RANDOM < 0.75) {

			check_position(pos(X+N,Y,Z+N));
			-+newPosition(X+N,Z+N);
			if (position(valid)) {
                /*.println("-----------------------------------------------------------------------------------------------");
                .println("Going DOWN RIGHT .");
                .println("-----------------------------------------------------------------------------------------------");*/

            }
        }

        //UPLEFT
        if (RANDOM >= 0.75 & RANDOM < 0.875) {

			check_position(pos(X-N,Y,Z-N));
			-+newPosition(X-N,Z-N);
			if (position(valid)) {
                /*.println("-----------------------------------------------------------------------------------------------");
                .println("Going UP LEFT .");
                .println("-----------------------------------------------------------------------------------------------");*/

            }
        }

        //DOWNLEFT
        if (RANDOM >= 0.875 & RANDOM <=1) {

			check_position(pos(X-N,Y,Z+N));
			-+newPosition(X-N,Z+N);
			if (position(valid)) {
                /*.println("-----------------------------------------------------------------------------------------------");
                .println("Going UP RIGHT .");
                .println("-----------------------------------------------------------------------------------------------");*/

            }
        }

    }

    ?newPosition(Xnew,Znew);
    //.println("Posicion: X: ", Xnew,"  Z: ", Znew);
    -+state(standing);
	!add_task(task(5000,"TASK_GOTO_POSITION",Name,pos(Xnew,Y,Znew),""));
    -newPosition(Xnew,Znew).

/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR init GOES HERE.")};
   .my_name(Name);
   -+state(standing);
   !add_task(task(5000,"TASK_GOTO_POSITION",Name,pos(224,0,150),"")).
