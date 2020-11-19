rem Pi-314=ALLIED 3,2,2
rem Rocosos=AXIS 7,0,0
set rutaAxis="src"
set rutaAllied="srcPi314"
set tipoAxis=%rutaAxis%"/jasonAgent_AXIS.asl"
set tipoAllied=%rutaAllied%"/jasonAgent_ALLIED.asl"
set tipoAllied2=%rutaAllied%"/jasonAgent_ALLIED_MEDIC.asl"
set tipoAllied3=%rutaAllied%"/jasonAgent_ALLIED_FIELDOPS.asl"
set fichero="Pi-314Vsrocosos.txt"
set rocososAxis="Corralo:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Lechuga:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Adrian:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Edu:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Elastico:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);LaCosa:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Fuego:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%)"
set EQUIPOAllied="E1:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied%);E2:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied%);E3:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied%);E4:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);E5:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);E6:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied3%);E7:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied3%)"
java -classpath "lib\jade.jar;lib\jadeTools.jar;lib\Base64.jar;lib\http.jar;lib\iiop.jar;lib\beangenerator.jar;lib\jgomas.jar;lib\jason.jar;lib\JasonJGomas.jar;classes;." jade.Boot -container -host localhost %EQUIPOAllied%;%rocososAxis% > %fichero%
 