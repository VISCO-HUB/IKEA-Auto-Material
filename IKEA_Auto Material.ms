try(closeRolloutFloater fAutoMaterial)catch()
global fAutoMaterial = newRolloutFloater "Auto Material" 260 520
global szVer = "1.0.0"

rollout rAutoMaterial "Create Material" 
(	
	group "Create"
	(
		button btnCreatemat "Create" width: 215 height: 35
		checkbox cbxAutoAssing "Assign to model" checked: true
	)
	group "Material List"
	(
		listbox lbxPreview height: 9
		button btnEdit "Edit List" across: 2
		button btnUpdate "Update"
	)
)
rollout rAutoMaterialSettings "Settings" 
(	
	group "ID's Path"
	(
		edittext edtIDPath "" height: 25 readOnly: true
		button btnSelectIDPath "Select Path" 
	)
	group "Materials Path"
	(
		edittext edtMatPath "" height: 25 readOnly: true
		button btnSelectMatPath "Select Path" 
	)
)
rollout rAbout "About" 
(
	local c = color 200 200 200 
	
	label lbl2 "Auto Material" 
	label lbl3 szVer
	
	label lbl5 "by MastaMan" 
	label lbl6 "" 

		
	hyperLink href2 "IKEA" address: "http://www.ikea.com/" align: #center hoverColor: c visitedColor: c
	hyperLink href "ViscoCG" address: "http://www.viscocg.com/" align: #center hoverColor: c visitedColor: c
)

addRollout rAutoMaterial fAutoMaterial rolledUp:false 
addRollout rAutoMaterialSettings fAutoMaterial rolledUp:false 
addRollout rAbout fAutoMaterial rolledUp:true 