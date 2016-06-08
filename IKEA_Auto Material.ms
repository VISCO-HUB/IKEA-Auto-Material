macroScript IKEA_AutoMaterial
category:"[IKEA]"
toolTip:"Material"
(

	try(closeRolloutFloater fAutoMaterial)catch()
	local fAutoMaterial = newRolloutFloater "Auto Material" 260 380
	global szVer = "1.0.2"

	global szIDPath = ""
	global szMatPath = @"\\visco.local\resource\ikea\MaterialsMAX2012\"
	global listID = #()
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
			listbox lbxPreview height: 9
			edittext edtIDPath "" height: 25 readOnly: true
			button btnSelectIDPath "Open List ID's" across: 2
			button btnUpdateList "Update List"
		)
		
		group "Create"
		(
			button btnCreatemMat "Create" width: 215 height: 35
			checkbox cbxAutoAssing "Assign to model" checked: true
		)
			
		fn checkErrorChars =
		(
			szError = ""
			for i in 1 to listID.count do
			(
				if(isGoodChars listID[i] == false or isGoodChars listMat[i] == false) do szError +=  listID[i] + "=" + listMat[i] + "\n"
			)
			
			return szError
		)
		
		fn openList =
		(
			edtIDPath.text = szIDPath
			lbxPreview.items  = #()
			
			if(szIDPath == "" or not doesFileExist szIDPath) do return messageBox ("File " + szIDPath + " not found!") title: "Warning!"
			
			useSettings "ID_PATH" szIDPath type:#set
					
			listID = getIniSetting szIDPath "IKEA"		
			
			if(listID.count == 0) do return messageBox "You selected wrong Materials ID file!" title: "Warning!"
			
			listMat = for i in listID collect getIniSetting szIDPath "IKEA" i
			
			showError = checkErrorChars()
			if(showError != "") do return messageBox ("Please check next lines for errors:\n\n" + showError) title: "Warning"
			
			lbxPreview.items = for i in 1 to listID.count collect (listID[i] + ": " + listMat[i])
		)
		
		on cbxAutoAssing changed x do
		(
			useSettings "AUTO_ASSIGN" (x as string) type:#set
		)
		
		on btnUpdateList pressed do
		(
			openList()
		)
		
		on rAutoMaterial open do
		(
			szIDPath = useSettings "ID_PATH" ""
			
			if(szIDPath != "") do openList()		

			autoAssign = useSettings "AUTO_ASSIGN" ""
			cbxAutoAssing.checked = if(autoAssign == "false" ) then false else true
		)
		
		on btnSelectIDPath pressed do
		(
			f = getOpenFileName caption:"Open Materials ID" types: "INI(*.ini)|*.ini"
			
			if(f == undefined) do return false
			szIDPath = f
						
			openList()
		)
		
		fn matFile f = szMatPath + f + ".mat"
		
		on btnCreatemMat pressed do
		(			
			showError = checkErrorChars()
			if(showError != "") do return messageBox ("Please check next lines for errors:\n\n" + showError) title: "Warning"		 
			if(listID.count == 0 or listMat.count == 0) do return messageBox "ID's not found!" title: "Warning"
			
			errorMissingID = for i in 1 to listID.count where findItem listID (i as string) == 0 collect i as string
			if(errorMissingID.count != 0) do
			(
				missingId = ""
				for i in errorMissingID do missingId += " " + i + ","
				missingId[missingId.count] = ""
				
				return messageBox ("Found missing ID's in list!\n\nFix next ID:" + missingId) title: "Warning!"
			)
			
			errorOverflow = for i in listID where (i as integer) > 10 collect i
			if(errorOverflow.count != 0) do return messageBox "Plese check your ID's list, you have ID greather then 10!" title: "Warning!"
					
			errorBrokenMat = for i in 1 to listMat.count where (not doesFileExist (matFile listMat[i])) collect listMat[i] + ".mat"
			
			if(errorBrokenMat.count != 0) do 
			(			
				brokenMats = ""
				for i in errorBrokenMat do brokenMats += i + "\n"
				return messageBox ("Not found next materials:\n\n" + brokenMats + "\n\nUsed path:\n" + szMatPath) title: "Warning!"
			)
				
			m = multiMaterial()
			m.numsubs = listID.count
			m.name = "material"
			
			for i in 1 to listID.count do
			(
				t = loadTempMaterialLibrary (matFile listMat[i])
				
				id = listID[i] as integer
				
				m[id] = t[1]
				m[id].name = listMat[i]
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
)