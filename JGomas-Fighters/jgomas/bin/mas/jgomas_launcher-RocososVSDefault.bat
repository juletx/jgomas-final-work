set rutaAxis="srcDefault"
set rutaAllied="src"
set tipoAxis=%rutaAxis%"/jasonAgent_AXIS.asl"
set tipoAxis2=%rutaAxis%"/jasonAgent_AXIS_MEDIC.asl"
set tipoAxis3=%rutaAxis%"/jasonAgent_AXIS_FIELDOPS.asl"
set tipoAllied=%rutaAllied%"/jasonAgent_ALLIED_MEDIC.asl"
set fichero="RocososVsDefault.txt"
set rocososAllied="Corralo:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied%);Lechuga:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied%);Adrian:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied%);Edu:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied%);Elastico:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied%);LaCosa:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied%);Fuego:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied%)"
java -classpath "lib\jade.jar;lib\jadeTools.jar;lib\Base64.jar;lib\http.jar;lib\iiop.jar;lib\beangenerator.jar;lib\jgomas.jar;lib\jason.jar;lib\JasonJGomas.jar;classes;." jade.Boot -container -host localhost "T1:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);T2:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);T3:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);T4:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis2%);T5:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis2%);T6:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis3%);T7:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis3%);"%rocososAllied%>%fichero%