macroScript IKEA_AutoMaterial
category:"[IKEA]"
toolTip:"Material"
(

	try(closeRolloutFloater fAutoMaterial)catch()
	local fAutoMaterial = newRolloutFloater "Auto Material" 260 600
	global szVer = "1.0.3"
	
	global szMatPath = @"\\visco.local\resource\ikea\MaterialsMAX2012\"
	global listMat = #()
	global goodChars = "1234567890"

	local fAutoMaterial
	local rAutoMaterialSettings
	local rAutoMaterial
	local rAbout

	fn isGoodChars s =
	(
		c = #()
		c = filterString s goodChars
		
		if(s == "") do return false
		
		return c.count == 0
	)

	fn useSettings k v type:#get =
	(
		f = getThisScriptFilename() + ".ini"
		case type of
		(
			#set: setIniSetting f "SETTINGS" k v
			default: getIniSetting f "SETTINGS" k
		)
	)
	
	rollout rAutoMaterial "Create Material" 
	(	
		group "Material List"
		(			
			listbox lbxPreview height: 20
			spinner spnID "ID:" type: #integer align: #left range: [1, 100, 1] fieldWidth: 30 across: 3
			button brnIncrement "+" align: #left offset:[-15, -2]
			edittext edtMaterialName "Material:" fieldWidth: 85 align: #left offset: [-56, 0]
			
			button btnAddID "Add/Edit Material" across: 2 offset: [0, 5]
			button btnDelID "Delete Material" offset: [0, 5]
		)
		
		group "Create"
		(
			button btnCreatemMat "Create" width: 215 height: 35
			checkbox cbxAutoAssing "Assign to model" checked: true
		)
		
		fn previewMaterials =
		(
			lbxPreview.items = for i in 1 to listMat.count collect (i as string + ": ") + (if(listMat[i] == undefined) then "" else listMat[i])
		)
		
		fn parseItem i =
		(
			s = filterString i ":"
			
			if(s[2] != undefined) do return s[2]
			if(s[1] != undefined) do return s[1]
			return ""
		)
		
		on btnAddID pressed do
		(
			m = edtMaterialName.text
			id = spnID.value
				
			setFocus rAutoMaterial.edtMaterialName
			
			if(m == "" or isGoodChars m == false) do 
			(
				edtMaterialName.text = ""
				
				return messageBox "Please enter correct Material Name!" title: "Warning!"
			)
			
			if(listMat[id] != undefined) do 
			(
				q = queryBox ("Do you really want to replace item: " + lbxPreview.items[id] + " to " + m)
				
				if(not q) do return false
			)
			
			listMat[id] = m
			
			previewMaterials()
			
			edtMaterialName.text = ""
			
			spnID.value += 1
			
			setFocus rAutoMaterial.edtMaterialName
		)
		
		on btnDelID pressed do
		(
			id = lbxPreview.selection
								
			if(id == 0) do return false
			
			q =  queryBox ("Do you really want to delete item: " + lbxPreview.items[id] + " ?")
			
			if(not q) do return false
			
			listMat[id] = undefined
			
			for i in listMat.count to 1 by -1 do 
			(	
				if(listMat[i] == undefined) then deleteItem listMat i else exit
			)
			
			spnID.value = listMat.count + 1
			
			if(lbxPreview.items.count > 0) do lbxPreview.selection = 1
			
			previewMaterials()
		)
		
		on lbxPreview selected x do
		(
			spnID.value = x
		)
		
		on brnIncrement pressed do
		(
			spnID.value += 1
		)
		
		on cbxAutoAssing changed x do
		(
			useSettings "AUTO_ASSIGN" (x as string) type:#set
		)
	
		on rAutoMaterial open do
		(
			autoAssign = useSettings "AUTO_ASSIGN" ""
			cbxAutoAssing.checked = if(autoAssign == "false" ) then false else true						
		)
		
		fn matFile f = szMatPath + f + ".mat"
		
		on btnCreatemMat pressed do
		(						
			if(listMat.count == 0) do return messageBox "Please add materials to list!" title: "Warning"
			
			errorMissingID = for i in 1 to listMat.count where listMat[i] == undefined collect i as string
			if(errorMissingID.count != 0) do
			(
				missingId = ""
				for i in errorMissingID do missingId += " " + i + ","
				missingId[missingId.count] = ""
				
				return messageBox ("Found missing ID's in list!\n\nFix next ID:" + missingId) title: "Warning!"
			)
								
			errorBrokenMat = for i in 1 to listMat.count where (not doesFileExist (matFile listMat[i])) collect listMat[i] + ".mat"
			
			if(errorBrokenMat.count != 0) do 
			(			
				brokenMats = ""
				for i in errorBrokenMat do brokenMats += i + "\n"
				return messageBox ("Not found next materials:\n\n" + brokenMats + "\n\nUsed path:\n" + szMatPath) title: "Warning!"
			)
				
			m = multiMaterial()
			m.numsubs = listMat.count
			m.name = "material"
			
			for i in 1 to listMat.count do
			(
				t = loadTempMaterialLibrary (matFile listMat[i])
				
				id = i as integer
				
				m[id] = t[1]
				m.names[id] = listMat[i]
			)
			
			setMeditMaterial 1 m
			
			if(cbxAutoAssing.checked) do
			(
				mdl = $model*
				if(mdl.count > 0) do for i in mdl do i.material = m
			)
		)
	)
	rollout rAutoMaterialSettings "Settings" 
	(	
		group "Materials Path"
		(
			edittext edtMatPath "" height: 25 readOnly: true
			button btnSelectMatPath "Select Path" 
		)

		on rAutoMaterialSettings open do
		(
			tmpMatPath= useSettings "MAT_PATH" ""
			
			if(tmpMatPath != "") do szMatPath = tmpMatPath		
				
			edtMatPath.text = szMatPath
		)
		
		on btnSelectMatPath pressed do
		(
			f = getSavePath caption:"Choose Materials Path" initialDir: szMatPath
				
			if(f == undefined) do return false
			
			szMatPath = f + "\\"
			edtMatPath.text = szMatPath
			useSettings "MAT_PATH" szMatPath type:#set
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
	addRollout rAutoMaterialSettings fAutoMaterial rolledUp:true 
	addRollout rAbout fAutoMaterial rolledUp:true 
	
	setFocus rAutoMaterial.edtMaterialName
)