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
.