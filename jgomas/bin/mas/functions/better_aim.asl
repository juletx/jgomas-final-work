{ include("../jgomas.asl") }

agent_half_way( _ ). // Is there an angent half way. Boolean.

/* 
* A better aiming system that tries to avoid shooting 
* team members if they are sitting between the enemy and
* the allied shooter.
*
* The plan is to overdrive the general plan of defaults agents.
* (Aka, make them actually better.)
* These new functions are way more complex and include a 
* good ammount of lines each.
*
* Welcome to the caos of trying that units dont kill 
* each other every 2 seconds.
*
* Debbuging this is gonna be a mess. Might have based
* this on some random code i found. But the idea is good.
*   - NotName.
*/




/*
* This function tries to recognise friendly units on the agent FOV.
* And checks if ANY of them are in the middle.
*
* This can be improved if you exit as soon as you find a
* friendly unit in the middle. But cant be really bothered.
* Right now it just cicles the entire list anyway.
*   -NotName
*/
+!agent_half_way( Xa, Ya, Za )
<-
    // Create a friendly agent list.
    // A friendly agent is one the agent isnt supposed to hurt.
    // This will be usefull later. We need to know what 
    // "friendly" agents the agent has on sigh.
    +friendly( [] );

    // Grab the "agents"/"items" in the field of view.
    ?fovObjects( FOVObjects ); 
	.length( FOVObjects, lenObjList );

    // We start supposing there aint any agent in the middle.
    -+agent_half_way( "false" ); 

    // Standart cicle procedure.
    -+bucle( 0 ); 

    while(bucle(i) & (i < lenObjList)){
        .nth(i, FOVObjects, Object);
        // Object structure
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
        .nth(1, Object, objTeam);

        if (team("ALLIED")) { // Aiming agent is an ally. 
            if(objTeam == 100) { // Team 1
                // Add our ally to our friendly list
                ?friendly( Ally );
                .concat( Ally, [Object], Friendly );
				-+friendly( Friendly );
            }   
        }
        else { // Aiming agent is axis.
            if(objTeam == 200) { // Team 2
                 // Add our ally to our friendly list
                ?friendly( Ally );
                .concat( Ally, [Object], Friendly );
				-+friendly( Friendly );
            }
        }
        -+bucle(i+1);
    }

    // Now hear me out: the plan is to cycle throught the
    // "friendly" list and try to calculate if any friend
    // is actually in the middle.
    ?friendly( Friendlies );
    .length(Friendlies, friendLenght);
    +bucle2( 0 );

    while( bucle2(t) & t<friendLenght){
        .nth(t, Friendlies, Target);
        // Object structure
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
        .nth(6,Target, friendPos);
        -+midPos(friendPos);
        ?midPos(pos(Xmp, Ymp, Zmp));
        ?my_position(Xc,Yc,Zc);
        //Now, with both positions, its time for 
        //the scary maths to come in.
        // remember Y is actually worthless.
        if ( math.abs( ( Zmp - Zc ) * ( Xmp - Xc ) - ( Xmp - Xc ) * ( Zmp - Zc ) ) <= 0 ) {
		    //Agent in the middle!
		    -+agent_half_way( "true" );
	    }
        -+bucle2( the + 1 );
    }
    -bucle( _ );
    -bucle2( _ ).

/*
* New plan that overloads the old get_agent_to_aim.
* This new plan uses the boolean we calculated before:
* "agent_half_way".
*
* The idea is pretty simiral to the previous function,
* Where we get a list of possible "targets", but this time
* we "filter" it with the knowledge we grabbed by knowing
* if there are friends in the middle.
*   -NotName
*/

+!get_agent_to_aim
    <- 
    ?fovObjects(FOVObjects);
    .length(FOVObjects, Length);
    +possibleTargets( [] ); // We need a list of possible targets.
    if (Length > 0) {
        +bucle(0);
        -+aimed("false");
        while (aimed("false") & bucle(X) & (X < Length)) {
            .nth(X, FOVObjects, Object);
            // Object structure
            // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
            .nth(2, Object, Type);
            if (Type > 1000) {
                //Why is this check coded so weirdly everywhere?
            } 
            else {
                // Object may be an enemy
                .nth(1, Object, Team);
                ?my_formattedTeam(MyTeam);
                /*
                * I refuse to use this monstrosity.
                if (Team == 200) {  // Only if I'm ALLIED
                    +aimed_agent(Object);
                    -+aimed("true");
                }
                */
                // We check teams.
                // And add the posible targets to our list.
                if ( team( "ALLIED" ) ) {
						if ( Team == 200 ) {
							?enemies( Target );
							.concat( Target, [Object], Targets );
							-+possibleTargets( Targets );
						}
					} else {
						if ( Team == 100 ) { 
							?possibleTargets( Target );
							.concat( Target, [Object], Targets );
							-+possibleTargets( Targets );
						}
					}

            }
        -+bucle(X+1);
        }
        // Now we just apply the check over the target list.
        ?possibleTargets( Target);
			.length( Target, lenTarget );
			if( lenTarget > 0 ) {
				!nearest( Target );
				?nearest( tAgent, PosAgent, D );
				.nth( 6, tAgent, destination );
				-+newDest( destination );
				?newDest( pos( Xv, Y, Z ) );
				!agent_half_way( Xv, Y, Z );
				?agent_half_way( agentHalfWay );
				if ( agentHalfWay == "false" ) {
					+aimed_agent( tAgent );
					-+aimed( "true" );
				}
			}
		}
	}
	-bucle( _ );
	.

/*
* New plan that overloads the old perform_aim_action.
* We just use the new knowledge we got with
* agent_half_way. Kinda same as the previous function.
*
* This function lacks proper testing. But in theory it 
* SHOULD work.
*   - Notname.
*/
+!perform_aim_action
    <-  
    // Aimed agents have the following format:
    // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
    ?aimed_agent(AimedAgent);
    if ( team( "AXIS" ) ) {
		-+auxTeam( 100 );
	} else {
		-+auxTeam( 200 )
	}
    .nth(1, AimedAgent, AimedAgentTeam);
    ?my_formattedTeam(MyTeam);
    if ( auxTeam( T ) & AimedAgentTeam == T ) { {
        .nth(6, AimedAgent, destination);
        // Same exact check as in the last function.
        // Should work?
        -+newDest( destination );
		?newDest( pos( Xv, Y, Z ) );
		!agent_half_way( Xv, Y, Z );
		?agent_half_way( agentHalfWay );
        if ( agentHalfWay == "true" ) {
			-aimed_agent( _ );
			-+aimed( "false" );
		}
    }
 .


