set srcAxis="default"
set srcAllied="default"
set AxisSoldier=%srcAxis%"/jasonAgent_AXIS_SOLDIER.asl"
set AxisMedic=%srcAxis%"/jasonAgent_AXIS_MEDIC.asl"
set AxisFieldops=%srcAxis%"/jasonAgent_AXIS_FIELDOPS.asl"
set AlliedSoldier=%srcAllied%"/jasonAgent_ALLIED_SOLDIER.asl"
set AlliedMedic=%srcAllied%"/jasonAgent_ALLIED_MEDIC.asl"
set AlliedFieldops=%srcAllied%"/jasonAgent_ALLIED_FIELDOPS.asl"
set AxisAgents="AXIS_SOLDIER_1:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AxisSoldier%);AXIS_SOLDIER_2:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AxisSoldier%);AXIS_SOLDIER_3:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AxisSoldier%);AXIS_FIELDOPS_1:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AxisFieldops%);AXIS_FIELDOPS_2:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AxisFieldops%);AXIS_MEDIC_1:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AxisMedic%);AXIS_MEDIC_2:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AxisMedic%)"
set AlliedAgents="ALLIED_SOLDIER_1:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AlliedSoldier%);ALLIED_SOLDIER_2:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AlliedSoldier%);ALLIED_SOLDIER_3:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AlliedSoldier%);ALLIED_FIELDOPS_1:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AlliedFieldops%);ALLIED_FIELDOPS_2:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AlliedFieldops%);ALLIED_MEDIC_1:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AlliedMedic%);ALLIED_MEDIC_2:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%AlliedMedic%)"
java -classpath "lib\jade.jar;lib\jadeTools.jar;lib\Base64.jar;lib\http.jar;lib\iiop.jar;lib\beangenerator.jar;lib\jgomas.jar;lib\jason.jar;lib\JasonJGomas.jar;classes;." jade.Boot -container -host localhost %AxisAgents%;%AlliedAgents%