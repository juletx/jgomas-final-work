rem DEA=AXIS 0,7,0
rem Rocosos=ALLIED 7,0,0
set rutaAxis="src"
set rutaAllied="srcDEA"
set tipoAxis=%rutaAxis%"/jasonAgent_AXIS.asl"
set tipoAxis2=%rutaAxis%"/jasonAgent_AXIS_MEDIC.asl"
set tipoAxis3=%rutaAxis%"/jasonAgent_AXIS_FIELDOPS.asl"
set tipoAllied=%rutaAllied%"/jasonAgent_ALLIED.asl"
set tipoAllied2=%rutaAllied%"/jasonAgent_ALLIED_MEDIC.asl"
set tipoAllied3=%rutaAllied%"/jasonAgent_ALLIED_FIELDOPS.asl"
set fichero="DEAVsRocosos.txt"
set rocososAxis="Corralo:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Lechuga:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Adrian:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Edu:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Elastico:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);LaCosa:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Fuego:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%)"
java -classpath "lib\jade.jar;lib\jadeTools.jar;lib\Base64.jar;lib\http.jar;lib\iiop.jar;lib\beangenerator.jar;lib\jgomas.jar;lib\jason.jar;lib\JasonJGomas.jar;classes;." jade.Boot -container -host localhost "A1:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);A2:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);A3:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);A4:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied22%);A5:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);A6:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);A7:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);%rocososAxis% > %fichero%
 