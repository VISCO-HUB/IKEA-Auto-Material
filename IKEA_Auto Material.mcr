/*
[INFO]

NAME = Auto Material
AUTHOR = MastaMan
DEV = ViscoCG
HELP = \help\
CAT=ARCHVIZ
LAUNCH=\\visco.local\data\Instal_Sync\scripts\scripts\_IKEA\Auto Material.ms

[ABOUT]

Toolbar button for Auto Material=

[SCRIPT]

*/

macroScript IKEA_AutoMaterial
category:"[IKEA]"
toolTip:"Material"
(
	try(fileIn(getIniSetting (getThisScriptFilename()) "INFO" "LAUNCH"))catch(messageBox "Lost network connection!" title: "Warning!")	
)